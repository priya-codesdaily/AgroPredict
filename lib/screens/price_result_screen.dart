import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/crop_model.dart';
import '../services/mandi_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final advice = MandiService.getSellAdvice(widget.prices);
    final bestMandi = MandiService.getBestMandi(widget.prices);

    Color adviceColor = advice == 'SELL'
        ? Colors.redAccent
        : advice == 'WAIT'
            ? const Color(0xFF52B788)
            : Colors.orangeAccent;

    String adviceEmoji = advice == 'SELL' ? '📉' : advice == 'WAIT' ? '📈' : '➡️';
    String bestMandiName = bestMandi != null
        ? bestMandi.market
        : (widget.isHindi ? 'नजदीकी मंडी' : 'nearby mandi');

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

                // Why This Advice
                _buildWhySellCard(advice, widget.prices, bestMandi, widget.isHindi),
                const SizedBox(height: 16),

                // Best Mandi Card
                if (bestMandi != null) ...[
                  Text(widget.isHindi ? 'सबसे अच्छी मंडी' : 'BEST MANDI TO SELL',
                      style: const TextStyle(
                          color: Color(0xFF52B788),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2744),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF52B788).withOpacity(0.3)),
                    ),
                    child: Row(
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
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                'Rs.${bestMandi.modalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: Color(0xFF52B788),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900)),
                            Text(
                                widget.isHindi ? 'प्रति क्विंटल' : 'per quintal',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Data count
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
                              ? '${widget.prices.length} मंडियों के आधार पर · AGMARKNET सरकारी डेटा'
                              : 'Based on ${widget.prices.length} mandis · Official AGMARKNET Govt Data',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),

                // Go to details
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _tabController.animateTo(2),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.isHindi
                              ? 'सभी मंडियों के भाव देखें'
                              : 'View all mandi prices',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.white.withOpacity(0.4), size: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TAB 2 — PROFIT CALCULATOR
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isHindi
                      ? 'यात्रा करने से पहले जानें — क्या यह फायदेमंद है?'
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
                // Chart
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
                                'Rs.${value.toInt()}',
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
                      barGroups: widget.prices
                          .asMap()
                          .entries
                          .map((e) => BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value.modalPrice,
                                    color: e.value == bestMandi
                                        ? const Color(0xFF52B788)
                                        : const Color(0xFF52B788)
                                            .withOpacity(0.4),
                                    width: 18,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // All mandis list
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
                                                ? 'सबसे अच्छा'
                                                : 'BEST',
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
                                  'Rs.${price.modalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(
                                  'Min: Rs.${price.minPrice.toStringAsFixed(0)} | Max: Rs.${price.maxPrice.toStringAsFixed(0)}',
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

  Widget _buildWhySellCard(String advice, List<CropPrice> prices,
      CropPrice? bestMandi, bool isHindi) {
    if (prices.isEmpty || bestMandi == null) return const SizedBox();

    double avgModal =
        prices.map((p) => p.modalPrice).reduce((a, b) => a + b) /
            prices.length;
    double maxModal = prices
        .map((p) => p.modalPrice)
        .reduce((a, b) => a > b ? a : b);
    double percentAboveAvg = ((maxModal - avgModal) / avgModal) * 100;

    List<String> reasons = [];

    if (advice == 'SELL') {
      reasons.add(isHindi
          ? 'कीमत औसत से ${percentAboveAvg.toStringAsFixed(0)}% ज़्यादा है'
          : 'Price is ${percentAboveAvg.toStringAsFixed(0)}% above market average');
      reasons.add(isHindi
          ? '${bestMandi.market} में सबसे अच्छा दाम'
          : 'Best price available at ${bestMandi.market}');
      reasons.add(isHindi
          ? 'दाम स्थिर हैं — अभी बेचना सही है'
          : 'Price is stable — right time to sell');
    } else if (advice == 'WAIT') {
      reasons.add(isHindi
          ? 'मंडियों में दाम अभी कम हैं'
          : 'Prices are currently low across mandis');
      reasons.add(isHindi
          ? 'कुछ दिन रुकने पर बेहतर दाम मिल सकता है'
          : 'Waiting may get better prices');
      reasons.add(isHindi
          ? 'औसत दाम बढ़ने की संभावना है'
          : 'Average price likely to improve');
    } else {
      reasons.add(isHindi
          ? 'सभी मंडियों में दाम लगभग एक जैसे हैं'
          : 'Prices are similar across all mandis');
      reasons.add(isHindi ? '2-3 दिन नज़र रखें' : 'Monitor for 2-3 more days');
    }

    Color cardColor = advice == 'SELL'
        ? const Color(0xFF52B788)
        : advice == 'WAIT'
            ? Colors.orangeAccent
            : Colors.blueAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: cardColor, size: 18),
              const SizedBox(width: 8),
              Text(
                isHindi ? 'यह सलाह क्यों?' : 'WHY THIS ADVICE?',
                style: TextStyle(
                    color: cardColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...reasons.map((reason) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: cardColor, size: 16),
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
    );
  }

  Widget _buildTransportCalculator(CropPrice? bestMandi, bool isHindi) {
    if (bestMandi == null) return const SizedBox();
    final distanceController = TextEditingController();
    final quantityController = TextEditingController();
    final resultNotifier = ValueNotifier<String>('');

    return StatefulBuilder(
      builder: (context, setState) {
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
                    isHindi
                        ? 'परिवहन लाभ कैलकुलेटर'
                        : 'TRANSPORT PROFIT CALCULATOR',
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
                isHindi
                    ? '${bestMandi.market} — Rs.${bestMandi.modalPrice.toStringAsFixed(0)}/क्विंटल'
                    : '${bestMandi.market} — Rs.${bestMandi.modalPrice.toStringAsFixed(0)}/quintal',
                style: const TextStyle(
                    color: Color(0xFF52B788), fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: distanceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: isHindi
                      ? 'मंडी की दूरी (किमी)'
                      : 'Distance to mandi (km)',
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
                  hintText: isHindi
                      ? 'बेचने की मात्रा (क्विंटल)'
                      : 'Quantity to sell (quintals)',
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
                  double distance =
                      double.tryParse(distanceController.text) ?? 0;
                  double quantity =
                      double.tryParse(quantityController.text) ?? 0;
                  if (distance == 0 || quantity == 0) {
                    resultNotifier.value = isHindi
                        ? 'कृपया दूरी और मात्रा दर्ज करें'
                        : 'Please enter distance and quantity';
                    return;
                  }
                  double transportCost = distance * 10;
                  double totalRevenue = bestMandi.modalPrice * quantity;
                  double netProfit = totalRevenue - transportCost;
                  double profitPerQuintal = netProfit / quantity;
                  bool worthIt = netProfit > (totalRevenue * 0.7);
                  resultNotifier.value = worthIt
                      ? (isHindi
                          ? 'फायदेमंद है ✅\nकुल लाभ: Rs.${netProfit.toStringAsFixed(0)}\nप्रति क्विंटल: Rs.${profitPerQuintal.toStringAsFixed(0)}'
                          : 'WORTH IT ✅\nNet profit: Rs.${netProfit.toStringAsFixed(0)}\nProfit/quintal: Rs.${profitPerQuintal.toStringAsFixed(0)}')
                      : (isHindi
                          ? 'फायदेमंद नहीं ❌\nयातायात खर्च Rs.${transportCost.toStringAsFixed(0)} बहुत ज़्यादा\nनजदीकी मंडी में बेचो'
                          : 'NOT WORTH IT ❌\nTransport Rs.${transportCost.toStringAsFixed(0)} eats too much\nConsider local mandi instead');
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
                      (result.contains('WORTH IT') &&
                              !result.contains('NOT')) ||
                          result.contains('फायदेमंद है');
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
