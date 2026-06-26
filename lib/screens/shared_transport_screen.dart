import 'package:flutter/material.dart';
import '../models/crop_model.dart';

class SharedTransportScreen extends StatefulWidget {
  final String cropName;
  final List<CropPrice> prices;
  final bool isHindi;

  const SharedTransportScreen({
    super.key,
    required this.cropName,
    required this.prices,
    this.isHindi = false,
  });

  @override
  State<SharedTransportScreen> createState() => _SharedTransportScreenState();
}

class _SharedTransportScreenState extends State<SharedTransportScreen> {
  late TextEditingController distanceController;
  late TextEditingController numFarmersController;
  late TextEditingController totalQtyController;
  late TextEditingController priceController;

  final ValueNotifier<String> resultNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    distanceController = TextEditingController();
    numFarmersController = TextEditingController(text: '2');
    totalQtyController = TextEditingController();
    priceController = TextEditingController();
  }

  @override
  void dispose() {
    distanceController.dispose();
    numFarmersController.dispose();
    totalQtyController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void _calculate() {
    double distance = double.tryParse(distanceController.text) ?? 0;
    int numFarmers = int.tryParse(numFarmersController.text) ?? 1;
    double totalQty = double.tryParse(totalQtyController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0;

    if (distance == 0 || totalQty == 0 || price == 0) {
      resultNotifier.value = widget.isHindi ? 'सभी जानकारी दर्ज करें' : 'Enter all details';
      return;
    }

    const double costPerKm = 12.0;
    double totalCost = distance * costPerKm;
    double costPerFarmer = totalCost / numFarmers;
    double qtyPerFarmer = totalQty / numFarmers;

    double totalEarnings = price * totalQty;
    double profitWithoutSharing = totalEarnings - totalCost;
    double profitWithSharing = totalEarnings - costPerFarmer;
    double savings = totalCost - costPerFarmer;

    resultNotifier.value = widget.isHindi
        ? '🚛 साझा परिवहन बचत\n\n'
          'हर किसान: ${qtyPerFarmer.toStringAsFixed(0)} क्विंटल\n'
          'साझा लागत: ₹${costPerFarmer.toStringAsFixed(0)}\n'
          'कुल कमाई: ₹${totalEarnings.toStringAsFixed(0)}\n\n'
          '❌ बिना साझा: ₹${profitWithoutSharing.toStringAsFixed(0)}\n'
          '✅ साझा करके: ₹${profitWithSharing.toStringAsFixed(0)}\n\n'
          '💰 बचत: ₹${savings.toStringAsFixed(0)} प्रति किसान'
        : '🚛 Shared Transport Savings\n\n'
          'Per farmer: ${qtyPerFarmer.toStringAsFixed(0)} qtl\n'
          'Shared cost: ₹${costPerFarmer.toStringAsFixed(0)}\n'
          'Total earnings: ₹${totalEarnings.toStringAsFixed(0)}\n\n'
          '❌ Without sharing: ₹${profitWithoutSharing.toStringAsFixed(0)}\n'
          '✅ With sharing: ₹${profitWithSharing.toStringAsFixed(0)}\n\n'
          '💰 Saved: ₹${savings.toStringAsFixed(0)} per farmer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isHindi ? '🚛 साझा परिवहन' : '🚛 SHARED TRANSPORT',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1B4332).withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF52B788).withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.isHindi
                          ? 'पड़ोसी किसानों के साथ परिवहन साझा करें और ₹1000+ बचाएं'
                          : 'Share transport with neighbors & save ₹1000+',
                      style: const TextStyle(
                        color: Color(0xFF95D5B2),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.isHindi ? 'विवरण दर्ज करें' : 'ENTER DETAILS',
              style: const TextStyle(
                color: Color(0xFF52B788),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: distanceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.isHindi ? 'दूरी (किमी)' : 'Distance (km)',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: const Color(0xFF0A1628),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.route, color: Color(0xFF52B788)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: numFarmersController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.isHindi ? 'कितने किसान' : 'Number of farmers',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: const Color(0xFF0A1628),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.people, color: Color(0xFF52B788)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: totalQtyController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.isHindi ? 'कुल मात्रा (क्विंटल)' : 'Total quantity (qtl)',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: const Color(0xFF0A1628),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.scale, color: Color(0xFF52B788)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.isHindi ? 'दाम (₹/क्विंटल)' : 'Price (₹/qtl)',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: const Color(0xFF0A1628),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF52B788)),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _calculate,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF52B788),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.isHindi ? 'बचत गणना करें' : 'CALCULATE SAVINGS',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<String>(
              valueListenable: resultNotifier,
              builder: (context, result, _) {
                if (result.isEmpty) return const SizedBox();
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF52B788).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF52B788).withOpacity(0.4)),
                  ),
                  child: Text(
                    result,
                    style: const TextStyle(
                      color: Color(0xFF52B788),
                      fontSize: 14,
                      height: 1.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}