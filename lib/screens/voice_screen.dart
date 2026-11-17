import 'package:audioplayers/audioplayers.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import '../logic/decision_engine.dart';
import '../logic/voice_parser.dart';
import '../models/crop_model.dart';
import '../services/mandi_service.dart';
import '../services/voice_service.dart';
import '../theme/app_colors.dart';
import 'price_result_screen.dart';

class VoiceScreen extends StatefulWidget {
  final bool isHindi;
  final double? userLat;
  final double? userLng;

  const VoiceScreen({
    super.key,
    this.isHindi = false,
    this.userLat,
    this.userLng,
  });

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _recording = false;
  bool _busy = false;
  bool _working = false;
  bool _speaking = false;

  String _transcript = '';
  String _error = '';
  String? _crop;
  double? _qty;
  String _unit = '';
  bool _spokenEnglish = false;

  String _answer = '';
  String _answerLang = 'hi-IN';
  bool _sample = false;
  CropPrice? _best;
  List<CropPrice> _prices = [];

  void _understand(String text) {
    final q = VoiceParser.parse(text);
    _crop = q.crop;
    _qty = q.quantity;
    _unit = q.unit;
    _spokenEnglish = q.spokenEnglish;
  }

  Future<void> _toggle() async {
    if (_busy || _working) return;
    if (_recording) {
      await _stopAndTranscribe();
    } else {
      await _start();
    }
  }

  Future<void> _start() async {
    await _player.stop();
    setState(() {
      _error = '';
      _transcript = '';
      _crop = null;
      _qty = null;
      _unit = '';
      _answer = '';
      _best = null;
    });
    if (!await _recorder.hasPermission()) {
      setState(() => _error = 'Microphone permission is needed');
      return;
    }
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: 'speech.wav',
    );
    setState(() => _recording = true);
  }

  Future<void> _stopAndTranscribe() async {
    final path = await _recorder.stop();
    setState(() {
      _recording = false;
      _busy = true;
    });
    if (path == null) {
      setState(() {
        _busy = false;
        _error = 'Nothing was recorded';
      });
      return;
    }
    try {
      final bytes = await XFile(path).readAsBytes();
      final text = await VoiceService.transcribe(bytes);
      if (!mounted) return;
      setState(() {
        _transcript = text;
        _understand(text);
      });
    } catch (e) {
      debugPrint('transcribe failed: $e');
      if (!mounted) return;
      setState(() => _error = 'Could not understand. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _fmt(double v) => v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  String _unitWord(bool hindi) {
    if (_unit == 'kg') return hindi ? 'किलो' : 'kg';
    return hindi ? 'क्विंटल' : 'quintal';
  }

  String _compose(
    CropPrice best,
    String? qtyLabel,
    double? net,
    double? earnings,
    bool hindi,
  ) {
    final price = best.modalPrice.round();
    final amount = net ?? earnings;

    if (hindi) {
      var s = '${best.market} मंडी में बेचना सबसे अच्छा रहेगा। यहाँ भाव $price रुपये प्रति क्विंटल है।';
      if (qtyLabel != null && amount != null) {
        s += ' $qtyLabel के लिए लगभग ${amount.round()} रुपये मिलेंगे';
        s += net != null ? ', यात्रा खर्च घटाने के बाद।' : '।';
      }
      return s;
    }

    var s = 'The best market is ${best.market}. The price there is $price rupees per quintal.';
    if (qtyLabel != null && amount != null) {
      s += ' For $qtyLabel you could earn about ${amount.round()} rupees';
      s += net != null ? ' after travel cost.' : '.';
    }
    return s;
  }

  Future<void> _findBestMarket() async {
    final crop = _crop;
    if (crop == null) return;
    setState(() {
      _working = true;
      _error = '';
    });

    List<CropPrice> prices = [];
    try {
      prices = await MandiService.fetchPrices(cropName: crop);
    } catch (e) {
      debugPrint('price lookup failed: $e');
    }
    final sample =
        prices.isEmpty || prices.every((p) => p.arrivalDate == '10/06/2026');
    if (prices.isEmpty) prices = MandiService.getMockData(crop);
    prices = prices.where((p) => p.modalPrice > 0).toList();

    final qtl = _qty == null ? null : (_unit == 'kg' ? _qty! / 100 : _qty!);

    var best = prices.reduce((a, b) => a.modalPrice > b.modalPrice ? a : b);
    double? net;

    if (qtl != null && widget.userLat != null && widget.userLng != null) {
      final list = DecisionEngine.getMandisWithDistance(
        prices,
        widget.userLat!,
        widget.userLng!,
      );
      double bestNet = double.negativeInfinity;
      for (final m in list) {
        final d = m['distance'] as double?;
        if (d == null) continue;
        final p = m['price'] as CropPrice;
        final n = p.modalPrice * qtl - d * 12.0;
        if (n > bestNet) {
          bestNet = n;
          best = p;
          net = n;
        }
      }
    }

    final earnings = qtl == null ? null : best.modalPrice * qtl;
    final hindi = !_spokenEnglish;
    final label = _qty == null ? null : '${_fmt(_qty!)} ${_unitWord(hindi)}';

    if (!mounted) return;
    setState(() {
      _prices = prices;
      _sample = sample;
      _best = best;
      _answerLang = hindi ? 'hi-IN' : 'en-IN';
      _answer = _compose(best, label, net, earnings, hindi);
      _working = false;
    });

    await _speakAnswer();
  }

  Future<void> _speakAnswer() async {
    if (_answer.isEmpty || _speaking) return;
    setState(() {
      _speaking = true;
      _error = '';
    });
    try {
      final bytes = await VoiceService.speak(_answer, language: _answerLang);
      await _player.stop();
      await _player.play(BytesSource(bytes, mimeType: 'audio/wav'));
    } catch (e) {
      debugPrint('speak failed: $e');
      if (mounted) setState(() => _error = 'Voice reply is not available right now.');
    } finally {
      if (mounted) setState(() => _speaking = false);
    }
  }

  void _openDetails() {
    final crop = _crop;
    if (crop == null || _prices.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PriceResultScreen(
          cropName: crop,
          prices: _prices,
          isHindi: widget.isHindi,
          userLat: widget.userLat,
          userLng: widget.userLng,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Widget _button(String label, VoidCallback? onTap, {bool filled = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _confirmCard() {
    final qtyText = _qty == null ? 'not mentioned' : '${_fmt(_qty!)} $_unit';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'I understood',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text('Crop: $_crop',
              style: const TextStyle(color: AppColors.textDark, fontSize: 18)),
          const SizedBox(height: 4),
          Text('Quantity: $qtyText',
              style: const TextStyle(color: AppColors.textDark, fontSize: 18)),
          const SizedBox(height: 16),
          _button(
            _working ? 'Finding best market...' : 'Yes, find best market',
            _working ? null : _findBestMarket,
          ),
          const SizedBox(height: 10),
          _button('No, try again', _working ? null : _start, filled: false),
        ],
      ),
    );
  }

  Widget _answerCard() {
    final best = _best!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'BEST MARKET',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (_sample)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'SAMPLE DATA',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            best.market,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${best.district}, ${best.state}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs. ${best.modalPrice.round()} per quintal',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _answer,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _button(
            _speaking ? 'Speaking...' : 'Hear answer again',
            _speaking ? null : _speakAnswer,
          ),
          const SizedBox(height: 10),
          _button('See full details', _openDetails, filled: false),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Speak',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _toggle,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _recording ? Colors.redAccent : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _recording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _busy
                  ? 'Listening to your recording...'
                  : _recording
                      ? 'Recording... tap to stop'
                      : 'Tap the mic and speak',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            if (_transcript.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderGreen),
                ),
                child: Text(
                  _transcript,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
              ),
            if (_transcript.isNotEmpty && _crop != null && _best == null)
              _confirmCard(),
            if (_best != null && _answer.isNotEmpty) _answerCard(),
            if (_transcript.isNotEmpty && _crop == null && !_busy)
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Text(
                  'I could not find a crop name. Try saying, for example: "tomato price" or "मेरे पास बीस क्विंटल धान है".',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}