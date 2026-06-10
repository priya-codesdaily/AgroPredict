import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/crop_model.dart';
import '../logic/decision_engine.dart';

class PriceResultScreen extends StatefulWidget {
  final String cropName;
  final List<CropPrice> prices;
  final bool isHindi;
  final double? userLat;
  final double? userLng;

  const PriceResultScreen({
    super.key,
    required this.cropName,
    required this.prices,
    this.isHindi = false,
    this.userLat,
    this.userLng,
  });

  @override
  State<PriceResultScreen> createState() => _PriceResultScreenState();
}

class _PriceResultScreenState extends State<PriceResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPerKg = false;
  CropPrice? _selectedMandiForCalc;
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initTts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage(widget.isHindi ? 'hi-IN' : 'en-IN');
    await _tts.setSpeechRate(0.65);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speakResult(Map<String, dynamic> decision) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    final String advice = decision['advice'] as String;
    final CropPrice? best = decision['bestMandi'] as CropPrice?;
    Map<String, dynamic>? nearest;
    if (widget.userLat != null && widget.userLng != null) {
      nearest = DecisionEngine.getNearestMandi(widget.prices, widget.userLat!, widget.userLng!);
    }
    String text = '';
    if (widget.isHindi) {
      if (advice == 'SELL') {
        text = '${widget.cropName} के लिए अभी बेचना फायदेमंद है. ';
        if (best != null) {
          text += '${best.market} मंडी में सबसे अच्छा दाम है. ';
          text += 'कीमत ${best.modalPrice.toStringAsFixed(0)} रुपये प्रति क्विंटल है. ';
        }
        if (nearest != null) {
          final p = nearest['price'] as CropPrice;
          final d = nearest['distance'] as double?;
          text += 'आपके पास की मंडी ${p.market} है. ';
          if (d != null) text += 'अनुमानित दूरी ${d.toStringAsFixed(0)} किलोमीटर है. ';
        }
        text += 'अभी बेचना सही रहेगा.';
      } else if (advice == 'WAIT') {
        text = '${widget.cropName} के लिए अभी इंतजार करना बेहतर हो सकता है. ';
        if (nearest != null) {
          final p = nearest['price'] as CropPrice;
          text += '${p.market} मंडी में भाव ${p.modalPrice.toStringAsFixed(0)} रुपये प्रति क्विंटल है. ';
        }
        text += 'दाम बेहतर होने पर बेचें.';
      } else {
        text = '${widget.cropName} के दाम अभी लगभग एक जैसे हैं. कुछ दिन नज़र रखें.';
      }
    } else {
      if (advice == 'SELL') {
        text = 'Good time to sell ${widget.cropName}. ';
        if (best != null) {
          text += '${best.market} has the best price at ${best.modalPrice.toStringAsFixed(0)} rupees per quintal. ';
        }
        if (nearest != null) {
          final p = nearest['price'] as CropPrice;
          final d = nearest['distance'] as double?;
          text += 'Nearest mandi is ${p.market}. ';
          if (d != null) text += 'Estimated distance is ${d.toStringAsFixed(0)} kilometres. ';
        }
        text += 'Sell now.';
      } else if (advice == 'WAIT') {
        text = 'It may be better to wait before selling ${widget.cropName}. ';
        if (nearest != null) {
          final p = nearest['price'] as CropPrice;
          text += '${p.market} mandi price is ${p.modalPrice.toStringAsFixed(0)} rupees per quintal. ';
        }
        text += 'Monitor prices before selling.';
      } else {
        text = 'Prices for ${widget.cropName} are similar across mandis. Monitor for a few more days.';
      }
    }
    await _tts.setLanguage(widget.isHindi ? 'hi-IN' : 'en-IN');
    setState(() => _isSpeaking = true);
    await _tts.speak(text);
  }

  double _getPrice(double q) => _showPerKg ? q / 100 : q;

  String _unit() => _showPerKg
      ? (widget.isHindi ? 'प्रति किलो' : 'per kg')
      : (widget.isHindi ? 'प्रति क्विंटल' : 'per quintal');

  double? _getMandiDistance(CropPrice? mandi) {
    if (mandi == null || widget.userLat == null || widget.userLng == null) return null;
    final list = DecisionEngine.getMandisWithDistance(widget.prices, widget.userLat!, widget.userLng!);
    final match = list.where((m) => (m['price'] as CropPrice) == mandi).toList();
    if (match.isNotEmpty) return match.first['distance'] as double?;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final decision = DecisionEngine.analyze(widget.prices);
    final String advice = decision['advice'] as String;
    final CropPrice? best = decision['bestMandi'] as CropPrice?;
final List<String> reasons = List<String>.from(
  widget.isHindi && decision['reasonsHindi'] != null
      ? decision['reasonsHindi'] as List
      : decision['reasons'] as List
);    final int count = decision['mandiCount'] as int;
    final double avg = decision['avgPrice'] as double;
    final double pct = decision['percentAboveAvg'] as double;
    final String smartLine = decision['smartLine'] as String;
    final String smartLineHindi = decision['smartLineHindi'] as String;
    final String lastUpdate = widget.prices.isNotEmpty ? widget.prices.first.arrivalDate : '';

    if (_selectedMandiForCalc == null && best != null) {
      _selectedMandiForCalc = best;
    }

    Color ac = advice == 'SELL'
        ? Colors.redAccent
        : advice == 'WAIT'
            ? const Color(0xFF52B788)
            : Colors.orangeAccent;

    String title = advice == 'SELL'
        ? (widget.isHindi ? 'अभी बेचो' : 'SELL NOW')
        : advice == 'WAIT'
            ? (widget.isHindi ? 'इंतजार करें' : 'WAIT')
            : (widget.isHindi ? 'नज़र रखो' : 'MONITOR');

    String sub = advice == 'SELL'
        ? (widget.isHindi
            ? '${best?.market ?? ""} में सबसे अच्छा दाम\nवहाँ जाकर बेचो'
            : 'Best price at ${best?.market ?? ""}\nSell your crop there now')
        : advice == 'WAIT'
            ? (widget.isHindi
                ? 'दाम अभी कम हैं\nबेहतर दाम का इंतजार करें'
                : 'Prices below average\nMonitor before selling')
            : (widget.isHindi
                ? 'दाम एक जैसे हैं\n2-3 दिन देखो'
                : 'Prices stable\nMonitor 2-3 days');

    double diff = best != null ? best.modalPrice - avg : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.cropName.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            overflow: TextOverflow.ellipsis),
        actions: [
          GestureDetector(
            onTap: () => setState(() => _showPerKg = !_showPerKg),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF52B788).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF52B788).withOpacity(0.4)),
              ),
              child: Text(
                _showPerKg
                    ? (widget.isHindi ? '₹/किलो' : '₹/kg')
                    : (widget.isHindi ? '₹/क्विंटल' : '₹/qtl'),
                style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF52B788),
          indicatorWeight: 2,
          labelColor: const Color(0xFF52B788),
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
          tabs: [
            Tab(text: widget.isHindi ? 'सारांश' : 'OVERVIEW'),
            Tab(text: widget.isHindi ? 'लाभ' : 'PROFIT'),
            Tab(text: widget.isHindi ? 'मंडियां' : 'MARKETS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [

          // ── TAB 1 OVERVIEW ──────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Decision card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ac.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ac.withOpacity(0.4), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(advice == 'SELL' ? '📉' : advice == 'WAIT' ? '📈' : '➡️',
                          style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 10),
                      Text(title, style: TextStyle(color: ac, fontSize: 28, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(sub, textAlign: TextAlign.center,
                          style: TextStyle(color: ac.withOpacity(0.8), fontSize: 15, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Smart line
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ac.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Text('🧠 ', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.isHindi ? smartLineHindi : smartLine,
                        style: TextStyle(color: ac.withOpacity(0.9), fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    widget.isHindi
                        ? 'AGMARKNET डेटा के आधार पर सुझाव'
                        : 'Based on AGMARKNET govt data',
                    style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 10),
                  ),
                ),
                const SizedBox(height: 12),

                // Speak button
                GestureDetector(
                  onTap: () => _speakResult(decision),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _isSpeaking ? Colors.redAccent.withOpacity(0.15) : const Color(0xFF1A2744),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSpeaking ? Colors.redAccent.withOpacity(0.5) : const Color(0xFF52B788).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up,
                          color: _isSpeaking ? Colors.redAccent : const Color(0xFF52B788),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSpeaking
                              ? (widget.isHindi ? 'रोकें ⏹' : 'Stop ⏹')
                              : (widget.isHindi ? '🔊 सलाह सुनें' : '🔊 Hear Advice'),
                          style: TextStyle(
                            color: _isSpeaking ? Colors.redAccent : const Color(0xFF52B788),
                            fontSize: 14, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // GPS Nearest mandi
                if (widget.userLat != null && widget.userLng != null) ...[
                  _buildNearestMandiCard(),
                  const SizedBox(height: 16),
                ],

                // Why card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ac.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ac.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.psychology, color: ac, size: 18),
                        const SizedBox(width: 8),
                        Text(widget.isHindi ? 'यह सलाह क्यों?' : 'WHY THIS ADVICE?',
                            style: TextStyle(color: ac, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ]),
                      const SizedBox(height: 12),
                      ...reasons.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_outline, color: ac, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(r,
                                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, height: 1.4))),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Best price card
                if (best != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF52B788).withOpacity(0.15),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Text(
                        widget.isHindi ? '🔥 सबसे ज़्यादा फायदे वाली मंडी' : '🔥 BEST PROFIT OPTION',
                        style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2744),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                      border: Border.all(color: const Color(0xFF52B788).withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFF52B788).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.store, color: Color(0xFF52B788), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(best.market, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('${best.district}, ${best.state}',
                                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('₹${_getPrice(best.modalPrice).toStringAsFixed(_showPerKg ? 1 : 0)}',
                                    style: const TextStyle(color: Color(0xFF52B788), fontSize: 24, fontWeight: FontWeight.w900)),
                                Text(_unit(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            widget.isHindi
                                ? '👉 यहाँ बेचने पर औसत से ₹${_getPrice(diff).toStringAsFixed(0)} ज़्यादा मिलेगा'
                                : '👉 Sell here to earn ₹${_getPrice(diff).toStringAsFixed(0)} more than average',
                            style: const TextStyle(color: Color(0xFF52B788), fontSize: 12, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _stat('${pct.toStringAsFixed(0)}%', widget.isHindi ? 'औसत से ज़्यादा' : 'above avg', Icons.trending_up),
                            Container(width: 1, height: 30, color: Colors.white12),
                            _stat('$count', widget.isHindi ? 'मंडियां देखी' : 'mandis checked', Icons.store_mall_directory),
                            Container(width: 1, height: 30, color: Colors.white12),
                            _stat(widget.isHindi ? '✅ सही' : '✅ YES', widget.isHindi ? 'बेचो यहाँ' : 'sell here', Icons.verified),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Auto profit widget
                  _buildAutoProfit(best, avg),
                ],
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => _tabController.animateTo(2),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.isHindi ? 'सभी मंडियों की तुलना करें' : 'Compare All Mandis',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios, color: Color(0xFF52B788), size: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2744),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF52B788).withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.verified, color: Color(0xFF52B788), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.isHindi
                            ? '$count मंडियों के आधार पर · AGMARKNET सरकारी डेटा${lastUpdate.isNotEmpty ? " · $lastUpdate" : ""}'
                            : 'Based on $count mandis · AGMARKNET Govt Data${lastUpdate.isNotEmpty ? " · Updated $lastUpdate" : ""}',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),

          // ── TAB 2 PROFIT ────────────────────────────────────────────
          StatefulBuilder(
            builder: (context, setTabState) {
              final autoDist = _getMandiDistance(_selectedMandiForCalc);
              final distC = TextEditingController(text: autoDist != null ? autoDist.toStringAsFixed(0) : '');
              final qtyC = TextEditingController();
              final resultN = ValueNotifier<String>('');

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isHindi ? 'मंडी चुनें — जानें यात्रा फायदेमंद है या नहीं' : 'Pick a mandi — know if travel is worth it',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2744),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF52B788).withOpacity(0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CropPrice>(
                          value: _selectedMandiForCalc,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1A2744),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          hint: Text(widget.isHindi ? 'मंडी चुनें' : 'Select a mandi',
                              style: TextStyle(color: Colors.white.withOpacity(0.4))),
                          items: widget.prices.map((p) {
                            final d = _getMandiDistance(p);
                            return DropdownMenuItem(
                              value: p,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(p.market, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                        if (d != null)
                                          Text('📍 ~${d.toStringAsFixed(0)} km',
                                              style: const TextStyle(color: Colors.blueAccent, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Text('₹${_getPrice(p.modalPrice).toStringAsFixed(0)}',
                                      style: const TextStyle(color: Color(0xFF52B788), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedMandiForCalc = val);
                            setTabState(() {});
                          },
                        ),
                      ),
                    ),
                    if (autoDist != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.gps_fixed, color: Colors.blueAccent, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.isHindi
                                  ? 'अनुमानित दूरी: ${autoDist.toStringAsFixed(0)} किमी · मात्रा डालें और लाभ देखें'
                                  : 'Estimated distance: ${autoDist.toStringAsFixed(0)} km · Enter quantity to calculate profit',
                              style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
                            ),
                          ),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (_selectedMandiForCalc != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2744),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF52B788).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Text('🚛 ', style: TextStyle(fontSize: 18)),
                              Text(
                                widget.isHindi ? 'परिवहन लाभ कैलकुलेटर' : 'TRANSPORT PROFIT CALCULATOR',
                                style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                              ),
                            ]),
                            const SizedBox(height: 8),
                            Text(
                              '${_selectedMandiForCalc!.market} — ₹${_getPrice(_selectedMandiForCalc!.modalPrice).toStringAsFixed(_showPerKg ? 1 : 0)} ${_unit()}',
                              style: const TextStyle(color: Color(0xFF52B788), fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: distC,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: widget.isHindi ? 'अनुमानित दूरी (किमी)' : 'Estimated distance (km)',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                                filled: true, fillColor: const Color(0xFF0A1628),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.route, color: Color(0xFF52B788), size: 18),
                                suffixIcon: autoDist != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.gps_fixed, color: Color(0xFF52B788), size: 14),
                                            SizedBox(width: 3),
                                            Text('GPS', style: TextStyle(color: Color(0xFF52B788), fontSize: 10)),
                                          ],
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: qtyC,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: widget.isHindi ? 'मात्रा (क्विंटल में) — जैसे: 5, 10, 50' : 'Quantity in quintals — e.g. 5, 10, 50',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                                filled: true, fillColor: const Color(0xFF0A1628),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.scale, color: Color(0xFF52B788), size: 18),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                double dist = double.tryParse(distC.text) ?? autoDist ?? 0;
                                double qty = double.tryParse(qtyC.text) ?? 0;
                                if (dist == 0 || qty == 0) {
                                  resultN.value = widget.isHindi ? 'कृपया दूरी और मात्रा दर्ज करें' : 'Please enter distance and quantity';
                                  return;
                                }
                                final r = DecisionEngine.calculateProfit(price: _selectedMandiForCalc!.modalPrice, quantity: qty, distance: dist);
                                bool wi = r['worthIt'] as bool;
                                double np = r['netProfit'] as double;
                                double tc = r['transportCost'] as double;
                                double ppq = r['profitPerQuintal'] as double;
                                resultN.value = wi
                                    ? (widget.isHindi
                                        ? 'यात्रा फायदेमंद है ✅\n\n₹${np.toStringAsFixed(0)}\nकुल लाभ\n\nप्रति क्विंटल: ₹${ppq.toStringAsFixed(0)}  •  यात्रा खर्च: ₹${tc.toStringAsFixed(0)}'
                                        : 'Worth the travel ✅\n\n₹${np.toStringAsFixed(0)}\nNet Profit\n\nPer quintal: ₹${ppq.toStringAsFixed(0)}  •  Travel cost: ₹${tc.toStringAsFixed(0)}')
                                    : (widget.isHindi
                                        ? 'यात्रा फायदेमंद नहीं ❌\n\nयात्रा खर्च: ₹${tc.toStringAsFixed(0)}\nनजदीकी मंडी में बेचना बेहतर है'
                                        : 'Not worth the travel ❌\n\nTravel cost: ₹${tc.toStringAsFixed(0)}\nSell at local mandi instead');
                              },
                              child: Container(
                                width: double.infinity, height: 52,
                                decoration: BoxDecoration(color: const Color(0xFF52B788), borderRadius: BorderRadius.circular(12)),
                                child: Center(child: Text(
                                  widget.isHindi ? 'लाभ की गणना करें' : 'CALCULATE NET PROFIT',
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14),
                                )),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ValueListenableBuilder<String>(
                              valueListenable: resultN,
                              builder: (context, result, _) {
                                if (result.isEmpty) return const SizedBox();
                                bool pos = result.contains('✅');
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: pos ? const Color(0xFF52B788).withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: pos ? const Color(0xFF52B788).withOpacity(0.4) : Colors.redAccent.withOpacity(0.4)),
                                  ),
                                  child: Text(result,
                                      style: TextStyle(color: pos ? const Color(0xFF52B788) : Colors.redAccent, fontSize: 14, height: 1.8, fontWeight: FontWeight.bold)),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // ── TAB 3 MARKETS ───────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.isHindi ? 'मंडी भाव तुलना' : 'MANDI PRICE COMPARISON',
                    style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1A2744), borderRadius: BorderRadius.circular(16)),
                  child: BarChart(BarChartData(
                    backgroundColor: Colors.transparent,
                    gridData: FlGridData(show: true, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1), drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 45,
                          getTitlesWidget: (v, m) => Text('₹${_getPrice(v).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white38, fontSize: 8)))),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: widget.prices.asMap().entries.map((e) => BarChartGroupData(
                      x: e.key,
                      barRods: [BarChartRodData(
                        toY: _getPrice(e.value.modalPrice),
                        color: e.value == best ? const Color(0xFF52B788) : const Color(0xFF52B788).withOpacity(0.4),
                        width: 18,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                      )],
                    )).toList(),
                  )),
                ),
                const SizedBox(height: 24),
                Text(widget.isHindi ? 'सभी मंडियां' : 'ALL MANDIS',
                    style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                ...widget.prices.map((p) {
                  final dist = _getMandiDistance(p);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2744),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: p == best ? const Color(0xFF52B788).withOpacity(0.5) : Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(child: Text(p.market, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                                if (p == best)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFF52B788).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                    child: Text(widget.isHindi ? '✅ सबसे अच्छा' : '✅ BEST',
                                        style: const TextStyle(color: Color(0xFF52B788), fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                              ]),
                              Text(p.district, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                              if (dist != null)
                                Text('📍 ~${dist.toStringAsFixed(0)} km',
                                    style: const TextStyle(color: Colors.blueAccent, fontSize: 11)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${_getPrice(p.modalPrice).toStringAsFixed(_showPerKg ? 1 : 0)}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(_unit(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoProfit(CropPrice best, double avg) {
    final dist = _getMandiDistance(best);
    final qtyC = TextEditingController();
    final resultN = ValueNotifier<String>('');

    void calculate(String qtyStr) {
      double qty = double.tryParse(qtyStr) ?? 0;
      double d = dist ?? 50;
      if (qty > 0) {
        final r = DecisionEngine.calculateProfit(price: best.modalPrice, quantity: qty, distance: d);
        bool wi = r['worthIt'] as bool;
        double np = r['netProfit'] as double;
        double tc = r['transportCost'] as double;
        resultN.value = '${wi ? "✅" : "❌"}|${np.toStringAsFixed(0)}|${tc.toStringAsFixed(0)}';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2744),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF52B788).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.calculate_outlined, color: Color(0xFF52B788), size: 16),
            const SizedBox(width: 8),
            Text(
              widget.isHindi ? '⚡ क्या यात्रा फायदेमंद है?' : '⚡ IS TRAVEL WORTH IT?',
              style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ]),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(best.market, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    if (dist != null)
                      Text('📍 ~${dist.toStringAsFixed(0)} km',
                          style: const TextStyle(color: Colors.blueAccent, fontSize: 11))
                    else
                      Text(widget.isHindi ? 'दूरी उपलब्ध नहीं' : 'Enter distance in Profit tab',
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                  ],
                ),
              ),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: qtyC,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                  onChanged: calculate,
                  decoration: InputDecoration(
                    hintText: widget.isHindi ? 'क्विंटल' : 'quintals',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                    filled: true,
                    fillColor: const Color(0xFF0A1628),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<String>(
            valueListenable: resultN,
            builder: (context, result, _) {
              if (result.isEmpty) return const SizedBox();
              final parts = result.split('|');
              if (parts.length < 3) return const SizedBox();
              bool pos = parts[0].contains('✅');
              String profit = parts[1];
              String cost = parts[2];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: pos ? const Color(0xFF52B788).withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: pos ? const Color(0xFF52B788).withOpacity(0.4) : Colors.redAccent.withOpacity(0.4)),
                ),
      child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pos
              ? (widget.isHindi ? '✅ यात्रा फायदेमंद है' : '✅ Worth the travel')
              : (widget.isHindi ? '❌ यात्रा फायदेमंद नहीं' : '❌ Not worth it'),
          style: TextStyle(color: pos ? const Color(0xFF52B788) : Colors.redAccent,
              fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          widget.isHindi ? 'यात्रा खर्च: ₹$cost' : 'Travel cost: ₹$cost',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
        ),
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('₹$profit',
            style: TextStyle(color: pos ? const Color(0xFF52B788) : Colors.redAccent,
                fontSize: 22, fontWeight: FontWeight.w900)),
        Text(widget.isHindi ? 'कुल लाभ' : 'net profit',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
      ],
    ),
  ],
),        );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNearestMandiCard() {
    final nearest = DecisionEngine.getNearestMandi(widget.prices, widget.userLat!, widget.userLng!);
    final bestNearby = DecisionEngine.getBestNearbyMandi(widget.prices, widget.userLat!, widget.userLng!);
    if (nearest == null) return const SizedBox();

    final CropPrice nearestPrice = nearest['price'] as CropPrice;
    final double? nearestDist = nearest['distance'] as double?;
    final CropPrice? bestPrice = bestNearby?['price'] as CropPrice?;
    final double? bestDist = bestNearby?['distance'] as double?;

    String distText(double? d) => d != null
        ? '~${d.toStringAsFixed(0)} km ${widget.isHindi ? "दूर" : "away"}'
        : widget.isHindi ? 'दूरी अज्ञात' : 'Distance unknown';

    String travelText(double? d) {
      if (d == null) return '';
      int hrs = (d / 60).floor();
      int mins = ((d / 60 - hrs) * 60).round();
      return hrs > 0 ? '~$hrs hr ${mins}min' : '~${mins}min';
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2744),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.near_me, color: Colors.blueAccent, size: 16),
                const SizedBox(width: 8),
                Text(
                  widget.isHindi ? '📍 आपके पास की मंडी' : '📍 NEAREST MANDI',
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nearestPrice.market, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${nearestPrice.district}, ${nearestPrice.state}',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.directions_car, color: Colors.blueAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(distText(nearestDist), style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
                        if (travelText(nearestDist).isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time, color: Colors.blueAccent, size: 14),
                          const SizedBox(width: 4),
                          Text(travelText(nearestDist), style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
                        ],
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${_getPrice(nearestPrice.modalPrice).toStringAsFixed(_showPerKg ? 1 : 0)}',
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 22, fontWeight: FontWeight.w900)),
                    Text(_unit(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                  ],
                ),
              ]),
            ],
          ),
        ),
        if (bestPrice != null && bestPrice.market != nearestPrice.market) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2744),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
            ),
            child: Row(children: [
              const Icon(Icons.trending_up, color: Colors.orangeAccent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isHindi
                      ? '💡 ${bestPrice.market} में ज़्यादा दाम (${distText(bestDist)}) — लाभ टैब में देखें'
                      : '💡 ${bestPrice.market} has higher price (${distText(bestDist)}) — check Profit tab',
                  style: TextStyle(color: Colors.orangeAccent.withOpacity(0.9), fontSize: 11, height: 1.4),
                ),
              ),
            ]),
          ),
        ],
      ],
    );
  }

  Widget _stat(String val, String label, IconData icon) {
    return Column(children: [
      Icon(icon, color: const Color(0xFF52B788), size: 16),
      const SizedBox(height: 4),
      Text(val, style: const TextStyle(color: Color(0xFF52B788), fontSize: 12, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
    ]);
  }
}
