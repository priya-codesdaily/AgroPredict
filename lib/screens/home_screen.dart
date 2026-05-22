import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:geolocator/geolocator.dart';
import '../services/mandi_service.dart';
import '../models/crop_model.dart';
import '../models/crop_varieties.dart';
import 'price_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _cropController = TextEditingController();
  final _stateController = TextEditingController();
  bool _isLoading = false;
  bool _isHindi = false;
  bool _isListening = false;
  final SpeechToText _speech = SpeechToText();
  String _selectedVariety = '';
  bool _showVarieties = false;
  List<String> _currentVarieties = [];
  double? _userLat;
  double? _userLng;
  bool _locationLoaded = false;

  final List<String> _popularCrops = [
    'Mango', 'Rice', 'Wheat', 'Tomato',
    'Potato', 'Onion', 'Cotton', 'Soybean'
  ];

  final Map<String, String> _cropHindi = {
    'Mango': 'आम', 'Rice': 'चावल', 'Wheat': 'गेहूं',
    'Tomato': 'टमाटर', 'Potato': 'आलू', 'Onion': 'प्याज',
    'Cotton': 'कपास', 'Soybean': 'सोयाबीन',
  };

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationLoaded = true);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationLoaded = true);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      setState(() {
        _userLat = position.latitude;
        _userLng = position.longitude;
        _locationLoaded = true;
      });
    } catch (e) {
      setState(() => _locationLoaded = true);
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) => setState(() => _isListening = false),
    );
    if (available) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _cropController.text = result.recognizedWords;
            _updateVarieties(result.recognizedWords);
          });
        },
        localeId: _isHindi ? 'hi_IN' : 'en_IN',
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isHindi ? 'माइक्रोफोन उपलब्ध नहीं है' : 'Microphone not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _updateVarieties(String cropName) {
    final trimmed = cropName.trim();
    setState(() {
      _showVarieties = CropVarieties.hasVarieties(trimmed);
      _currentVarieties = CropVarieties.getVarieties(trimmed);
      _selectedVariety = '';
    });
  }

  Future<void> _search() async {
    if (_cropController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isHindi ? 'कृपया फसल का नाम दर्ज करें' : 'Please enter a crop name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    String baseCrop = _cropController.text.trim();
    String searchCrop = _selectedVariety.isNotEmpty && !_selectedVariety.startsWith('All')
        ? '$baseCrop $_selectedVariety'
        : baseCrop;
    String displayName = _selectedVariety.isNotEmpty && !_selectedVariety.startsWith('All')
        ? '$baseCrop · $_selectedVariety'
        : baseCrop;

    List<CropPrice> prices = [];
    try {
      prices = await MandiService.fetchPrices(
        cropName: searchCrop,
        state: _stateController.text.trim(),
      );
    } catch (e) {
      prices = MandiService.getMockData(searchCrop);
    }
    if (prices.isEmpty) {
      prices = MandiService.getMockData(searchCrop);
    }
    setState(() => _isLoading = false);
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PriceResultScreen(
            cropName: displayName,
            prices: prices,
            isHindi: _isHindi,
            userLat: _userLat,
            userLng: _userLng,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B4332),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🌾', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AgroPredict',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                      Text(
                        _isHindi ? 'AI फसल मूल्य सहायक' : 'AI Crop Price Intelligence',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF52B788)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      _isHindi ? '● लाइव मंडी भाव' : '● LIVE MANDI PRICES',
                      style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Location indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Icon(
                          _userLat != null ? Icons.location_on : Icons.location_off,
                          color: _userLat != null ? const Color(0xFF52B788) : Colors.white38,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _userLat != null
                              ? (_isHindi ? 'GPS चालू' : 'GPS ON')
                              : (_isHindi ? 'GPS बंद' : 'GPS OFF'),
                          style: TextStyle(
                              color: _userLat != null ? const Color(0xFF52B788) : Colors.white38,
                              fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _isHindi = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: !_isHindi ? const Color(0xFF52B788) : Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('EN',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                              color: !_isHindi ? Colors.black : Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _isHindi = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isHindi ? const Color(0xFF52B788) : Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('हिंदी',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                              color: _isHindi ? Colors.black : Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4332).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF52B788).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isHindi
                            ? 'फसल का नाम डालें — किस्म चुनें — GPS से पास की मंडी देखें'
                            : 'Enter crop name — select variety — GPS finds nearest mandi',
                        style: const TextStyle(color: Color(0xFF95D5B2), fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(_isHindi ? 'फसल का नाम' : 'CROP NAME',
                  style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              TextField(
                controller: _cropController,
                onChanged: _updateVarieties,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: _isHindi ? 'जैसे: आम, चावल, गेहूं' : 'e.g. Mango, Rice, Wheat',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: const Color(0xFF1A2744),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF52B788), width: 1.5)),
                  prefixIcon: const Icon(Icons.grass, color: Color(0xFF52B788)),
                  suffixIcon: GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: Icon(_isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.redAccent : const Color(0xFF52B788)),
                  ),
                ),
              ),
              if (_isListening)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mic, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Text(_isHindi ? 'सुन रहा हूँ... बोलिए' : 'Listening... speak now',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                    ],
                  ),
                ),
              if (_showVarieties && _currentVarieties.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2744),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF52B788).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.category, color: Color(0xFF52B788), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            _isHindi ? 'किस्म चुनें (वैकल्पिक)' : 'Select variety (optional)',
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _currentVarieties.map((v) {
                          bool selected = _selectedVariety == v;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedVariety = selected ? '' : v),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFF52B788) : Colors.white10,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: selected ? const Color(0xFF52B788) : Colors.white24),
                              ),
                              child: Text(v,
                                  style: TextStyle(
                                      color: selected ? Colors.black : Colors.white,
                                      fontSize: 12,
                                      fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Text(_isHindi ? 'राज्य (वैकल्पिक)' : 'STATE (OPTIONAL)',
                  style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              TextField(
                controller: _stateController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: _isHindi ? 'जैसे: ओडिशा, महाराष्ट्र' : 'e.g. Odisha, Maharashtra',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: const Color(0xFF1A2744),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF52B788), width: 1.5)),
                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFF52B788)),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _isLoading ? null : _search,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(color: const Color(0xFF52B788), borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(_isHindi ? 'मंडी भाव देखें' : 'CHECK MANDI PRICES',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(_isHindi ? 'लोकप्रिय फसलें' : 'POPULAR CROPS',
                  style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularCrops.map((crop) {
                  return GestureDetector(
                    onTap: () {
                      _cropController.text = crop;
                      _updateVarieties(crop);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2744),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF52B788).withOpacity(0.3)),
                      ),
                      child: Text(_isHindi ? (_cropHindi[crop] ?? crop) : crop,
                          style: const TextStyle(color: Color(0xFF95D5B2), fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  _isHindi ? 'डेटा स्रोत: AGMARKNET • कृषि मंत्रालय, भारत' : 'Data source: AGMARKNET • Ministry of Agriculture',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cropController.dispose();
    _stateController.dispose();
    _speech.stop();
    super.dispose();
  }
}

