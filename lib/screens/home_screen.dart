import 'package:flutter/material.dart';
import '../services/mandi_service.dart';
import '../models/crop_model.dart';
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

  final List<String> _popularCrops = [
    'Mango', 'Rice', 'Wheat', 'Tomato',
    'Potato', 'Onion', 'Cotton', 'Soybean'
  ];

  Future<void> _search() async {
    if (_cropController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a crop name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prices = await MandiService.fetchPrices(
        cropName: _cropController.text.trim(),
        state: _stateController.text.trim(),
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PriceResultScreen(
              cropName: _cropController.text.trim(),
              prices: prices,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

              // Header
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AgroPredict',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'AI Crop Price Intelligence',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF52B788),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '● LIVE MANDI PRICES',
                  style: TextStyle(
                    color: Color(0xFF52B788),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4332).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF52B788).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Text('💡', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Enter any crop to see live mandi prices and get AI-powered sell advice.',
                        style: TextStyle(
                          color: Color(0xFF95D5B2),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Crop input
              const Text(
                'CROP NAME',
                style: TextStyle(
                  color: Color(0xFF52B788),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _cropController,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'e.g. Mango, Rice, Wheat',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: const Color(0xFF1A2744),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF52B788), width: 1.5),
                  ),
                  prefixIcon: const Icon(Icons.grass,
                      color: Color(0xFF52B788)),
                ),
              ),

              const SizedBox(height: 16),

              // State input
              const Text(
                'STATE (OPTIONAL)',
                style: TextStyle(
                  color: Color(0xFF52B788),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _stateController,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'e.g. Odisha, Maharashtra',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: const Color(0xFF1A2744),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF52B788), width: 1.5),
                  ),
                  prefixIcon: const Icon(Icons.location_on,
                      color: Color(0xFF52B788)),
                ),
              ),

              const SizedBox(height: 24),

              // Search button
              GestureDetector(
                onTap: _isLoading ? null : _search,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF52B788),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.black)
                        : const Text(
                            'CHECK MANDI PRICES',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Popular crops
              const Text(
                'POPULAR CROPS',
                style: TextStyle(
                  color: Color(0xFF52B788),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularCrops.map((crop) {
                  return GestureDetector(
                    onTap: () {
                      _cropController.text = crop;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2744),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF52B788)
                                .withOpacity(0.3)),
                      ),
                      child: Text(
                        crop,
                        style: const TextStyle(
                          color: Color(0xFF95D5B2),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Data source
              Center(
                child: Text(
                  'Data source: AGMARKNET • Ministry of Agriculture',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 11,
                  ),
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
    super.dispose();
  }
}

PriceResultScreen({required String cropName, required List<CropPrice> prices}) {
}