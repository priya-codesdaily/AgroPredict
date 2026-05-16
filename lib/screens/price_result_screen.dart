import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/crop_model.dart';
import '../logic/decision_engine.dart';

class PriceResultScreen extends StatefulWidget {
  final String cropName;
  final List<CropPrice> prices;
  final bool isHindi;

  const PriceResultScreen({
    super.key,
    required this.cropName,
    required this.prices,
    this.isHindi = false,
  });

  @override
  State<PriceResultScreen> createState() => _PriceResultScreenState();
}

class _PriceResultScreenState extends State<PriceResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPerKg = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double _getPrice(double quintalPrice) =>
      _showPerKg ? quintalPrice / 100 : quintalPrice;

  String _priceUnit() => _showPerKg
      ? (widget.isHindi ? 'प्रति किलो • आज का भाव' : 'per kg • Today\'s price')
      : (widget.isHindi ? 'प्रति क्विंटल • आज का भाव' : 'per quintal • Today\'s price');

  @override
  Widget build(BuildContext context) {
    final decision = DecisionEngine.analyze(widget.prices);
    final String advice = decision['advice'] as String;
    final CropPrice? bestMandi = decision['bestMandi'] as CropPrice?;
    final List<String> reasons = List<String>.from(decision['reasons'] as List);
    final int mandiCount = decision['mandiCount'] as int;
    final double avgPrice = decision['avgPrice'] as double;
    final double percentAboveAvg = decision['percentAboveAvg'] as double;

    Color adviceColor = advice == 'SELL'
        ? Colors.redAccent
        : advice == 'WAIT'
            ? const Color(0xFF52B788)
            : Colors.orangeAccent;

    String adviceEmoji = advice == 'SELL' ? '📉' : advice == 'WAIT' ? '📈' : '➡️';
    String bestMandiName = bestMandi?.market ?? (widget.isHindi ? 'नजदीकी मंडी' : 'nearby mandi');

    String adviceTitle = advice == 'SELL'
        ? (widget.isHindi ? 'अभी बेचो' : 'SELL NOW')
        : advice == 'WAIT'
            ? (widget.isHindi ? 'रुको' : 'WAIT')
            : (widget.isHindi ? 'नज़र रखो' : 'MONITOR');

    String adviceText = advice == 'SELL'
        ? (widget.isHindi
            ? '$bestMandiName में सबसे अच्छा दाम\nवहाँ जाकर बेचो'
            : 'Best price at $bestMandiName\nSell your crop there now')
        : advice == 'WAIT'
            ? (widget.isHindi
                ? 'दाम बढ़ रहे हैं\n5-7 दिन और रुको'
                : 'Prices rising\nWait 5-7 more days')
            : (widget.isHindi
                ? 'दाम एक जैसे हैं\n2-3 दिन देखो'
                : 'Prices stable\nMonitor 2-3 more days');

    // Natural reasons for farmers
    List<String> naturalReasons = [];
    if (advice == 'SELL') {
      naturalReasons.add(widget.isHindi
          ? 'पास के बाज़ारों से ${percentAboveAvg.toStringAsFixed(0)}% ज़्यादा दाम मिल रहा है'
          : 'Price is ${percentAboveAvg.toStringAsFixed(0)}% higher than nearby markets');
      naturalReasons.add(widget.isHindi
          ? '$bestMandiName में सबसे अच्छा दाम मिला'
          : 'Best rate found in $bestMandiName');
      naturalReasons.add(widget.isHindi
          ? 'दाम स्थिर है — बेचने का सही समय है'
          : 'Good time to sell — prices are stable');
    } else {
      naturalReasons = reasons;
    }

    double priceDiff = bestMandi != null ? bestMandi.modalPrice - avgPrice : 0;

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
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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
                style: const TextStyle(
                    color: Color(0xFF52B788),
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
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
          labelStyle: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
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

          // TAB 1 — OVERVIEW
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Main Decision Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: adviceColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: adviceColor.withOpacity(0.4), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(adviceEmoji, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 10),
                      Text(adviceTitle,
                          style: TextStyle(
                              color: adviceColor,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Text(adviceText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: adviceColor.withOpacity(0.8),
                              fontSize: 15,
                              height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Why This Advice — natural language
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: adviceColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: adviceColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology, color: adviceColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            widget.isHindi ? 'यह सलाह क्यों?' : 'WHY THIS ADVICE?',
                            style: TextStyle(
                                color: adviceColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...naturalReasons.map((reason) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: adviceColor, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(reason,
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 13,
                                          height: 1.4)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // POWER CARD
                if (bestMandi != null) ...[
                  // Best choice label
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF52B788).withOpacity(0.15),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.isHindi
                            ? '🔥 सबसे ज़्यादा फायदे वाली मंडी'
                            : '🔥 BEST PROFIT OPTION',
                        style: const TextStyle(
                            color: Color(0xFF52B788),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2744),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(
                          color: const Color(0xFF52B788).withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF52B788).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.store,
                                  color: Color(0xFF52B788), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(bestMandi.market,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text('${bestMandi.district}, ${bestMandi.state}',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    '₹${_getPrice(bestMandi.modalPrice).toStringAsFixed(_showPerKg ? 1 : 0)}',
                                    style: const TextStyle(
                                        color: Color(0xFF52B788),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900)),
                                Text(_priceUnit(),
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Travel suggestion line
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.isHindi
                                ? '👉 यहाँ बेचने पर औसत से ₹${_getPrice(priceDiff).toStringAsFixed(0)} ज़्यादा मिलेगा'
                                : '👉 Sell here to earn ₹${_getPrice(priceDiff).toStringAsFixed(0)} more than average',
                            style: const TextStyle(
                                color: Color(0xFF52B788),
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _powerStat(
                              '${percentAboveAvg.toStringAsFixed(0)}%',
                              widget.isHindi ? 'औसत से ज़्यादा' : 'above avg',
                              Icons.trending_up,
                            ),
                            Container(
                                width: 1, height: 30, color: Colors.white12),
                            _powerStat(
                              mandiCount.toString(),
                              widget.isHindi ? 'मंडियां देखी' : 'mandis checked',
                              Icons.store_mall_directory,
                            ),
                            Container(
                                width: 1, height: 30, color: Colors.white12),
                            _powerStat(
                              widget.isHindi ? '✅ सही' : '✅ YES',
                              widget.isHindi ? 'बेचो यहाँ' : 'sell here',
                              Icons.verified,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Compare All Mandis button
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
                        Text(
                          widget.isHindi
                              ? 'सभी मंडियों की तुलना करें'
                              : 'Compare All Mandis',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios,
                            color: Color(0xFF52B788), size: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Trust badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2744),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF52B788).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified,
                          color: Color(0xFF52B788), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.isHindi
                              ? '$mandiCount मंडियों के आधार पर · AGMARKNET सरकारी डेटा · आज अपडेट हुआ'
                              : 'Based on $mandiCount mandis · AGMARKNET Govt Data · Updated today',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TAB 2 — PROFIT
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isHindi
                      ? 'यात्रा से पहले जानें — क्या फायदेमंद है?'
                      : 'Know before you travel — is it worth it?',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      height: 1.5),
                ),
                const SizedBox(height: 16),
                _buildTransportCalculator(bestMandi, widget.isHindi),
              ],
            ),
          ),

          // TAB 3 — MARKETS
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isHindi ? 'मंडी भाव तुलना' : 'MANDI PRICE COMPARISON',
                  style: const TextStyle(
                      color: Color(0xFF52B788),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2744),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: BarChart(
                    BarChartData(
                      backgroundColor: Colors.transparent,
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withOpacity(0.05),
                            strokeWidth: 1),
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) => Text(
                                '₹${_getPrice(value).toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 8)),
                          ),
                        ),
                        bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: widget.prices.asMap().entries.map((e) =>
                          BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: _getPrice(e.value.modalPrice),
                                color: e.value == bestMandi
                                    ? const Color(0xFF52B788)
                                    : const Color(0xFF52B788).withOpacity(0.4),
                                width: 18,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ],
                          )).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.isHindi ? 'सभी मंडियां' : 'ALL MANDIS',
                  style: const TextStyle(
                      color: Color(0xFF52B788),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                ...widget.prices.map((price) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2744),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: price == bestMandi
                              ? const Color(0xFF52B788).withOpacity(0.5)
                              : Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(price.market,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    if (price == bestMandi) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF52B788)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                            widget.isHindi
                                                ? '✅ सबसे अच्छा'
                                                : '✅ BEST',
                                            style: const TextStyle(
                                                color: Color(0xFF52B788),
                                                fontSize: 9,
                                                fontWeight:
                                                    FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(price.district,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  '₹${_getPrice(price.modalPrice).toStringAsFixed(_showPerKg ? 1 : 0)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(_priceUnit(),
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _powerStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF52B788), size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Color(0xFF52B788),
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 10)),
      ],
    );
  }

  Widget _buildTransportCalculator(CropPrice? bestMandi, bool isHindi) {
    if (bestMandi == null) return const SizedBox();
    final distanceController = TextEditingController();
    final quantityController = TextEditingController();
    final resultNotifier = ValueNotifier<String>('');

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2744),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF52B788).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🚛 ', style: TextStyle(fontSize: 18)),
                  Text(
                    isHindi ? 'परिवहन लाभ कैलकुलेटर' : 'TRANSPORT PROFIT CALCULATOR',
                    style: const TextStyle(
                        color: Color(0xFF52B788),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${bestMandi.market} — ₹${_getPrice(bestMandi.modalPrice).toStringAsFixed(_showPerKg ? 1 : 0)} ${_priceUnit()}',
                style: const TextStyle(color: Color(0xFF52B788), fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: distanceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: isHindi ? 'मंडी की दूरी (किमी)' : 'Distance to mandi (km)',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF0A1628),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.route,
                      color: Color(0xFF52B788), size: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: isHindi ? 'बेचने की मात्रा (क्विंटल)' : 'Quantity to sell (quintals)',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF0A1628),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.scale,
                      color: Color(0xFF52B788), size: 18),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  double distance = double.tryParse(distanceController.text) ?? 0;
                  double quantity = double.tryParse(quantityController.text) ?? 0;
                  if (distance == 0 || quantity == 0) {
                    resultNotifier.value = isHindi
                        ? 'कृपया दूरी और मात्रा दर्ज करें'
                        : 'Please enter distance and quantity';
                    return;
                  }
                  final result = DecisionEngine.calculateProfit(
                    price: bestMandi.modalPrice,
                    quantity: quantity,
                    distance: distance,
                  );
                  bool worthIt = result['worthIt'] as bool;
                  double netProfit = result['netProfit'] as double;
                  double transportCost = result['transportCost'] as double;
                  double profitPerQuintal = result['profitPerQuintal'] as double;

                  resultNotifier.value = worthIt
                      ? (isHindi
                          ? '✅ फायदेमंद है!\n₹${distance.toStringAsFixed(0)} किमी जाने पर ₹${netProfit.toStringAsFixed(0)} कुल लाभ\nप्रति क्विंटल: ₹${profitPerQuintal.toStringAsFixed(0)}'
                          : '✅ Worth the travel!\nTravel ${distance.toStringAsFixed(0)}km → Earn ₹${netProfit.toStringAsFixed(0)} net profit\nProfit/quintal: ₹${profitPerQuintal.toStringAsFixed(0)}')
                      : (isHindi
                          ? '❌ फायदेमंद नहीं\nयातायात खर्च ₹${transportCost.toStringAsFixed(0)} बहुत ज़्यादा है\nनजदीकी मंडी में बेचना बेहतर है'
                          : '❌ Not worth the travel\nTransport cost ₹${transportCost.toStringAsFixed(0)} is too high\nConsider selling at local mandi instead');
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF52B788),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      isHindi ? 'लाभ की गणना करें' : 'CALCULATE NET PROFIT',
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String>(
                valueListenable: resultNotifier,
                builder: (context, result, _) {
                  if (result.isEmpty) return const SizedBox();
                  bool isPositive =
                      result.contains('✅');
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? const Color(0xFF52B788).withOpacity(0.15)
                          : Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isPositive
                            ? const Color(0xFF52B788).withOpacity(0.4)
                            : Colors.redAccent.withOpacity(0.4),
                      ),
                    ),
                    child: Text(result,
                        style: TextStyle(
                            color: isPositive
                                ? const Color(0xFF52B788)
                                : Colors.redAccent,
                            fontSize: 13,
                            height: 1.6,
                            fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
