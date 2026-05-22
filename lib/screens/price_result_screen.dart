import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  double _getPrice(double q) => _showPerKg ? q / 100 : q;

  String _unit() => _showPerKg
      ? (widget.isHindi ? 'प्रति किलो • आज का भाव' : 'per kg • today')
      : (widget.isHindi ? 'प्रति क्विंटल • आज का भाव' : 'per quintal • today');

  @override
  Widget build(BuildContext context) {
    final decision = DecisionEngine.analyze(widget.prices);
    final String advice = decision['advice'] as String;
    final CropPrice? best = decision['bestMandi'] as CropPrice?;
    final List<String> reasons = List<String>.from(decision['reasons'] as List);
    final int count = decision['mandiCount'] as int;
    final double avg = decision['avgPrice'] as double;
    final double pct = decision['percentAboveAvg'] as double;
    final String smartLine = decision['smartLine'] as String;
    final String smartLineHindi = decision['smartLineHindi'] as String;

    Color ac = advice == 'SELL'
        ? Colors.redAccent
        : advice == 'WAIT'
            ? const Color(0xFF52B788)
            : Colors.orangeAccent;

    String emoji = advice == 'SELL' ? '📉' : advice == 'WAIT' ? '📈' : '➡️';
    String title = advice == 'SELL'
        ? (widget.isHindi ? 'अभी बेचो' : 'SELL NOW')
        : advice == 'WAIT'
            ? (widget.isHindi ? 'रुको' : 'WAIT')
            : (widget.isHindi ? 'नज़र रखो' : 'MONITOR');
    String sub = advice == 'SELL'
        ? (widget.isHindi
            ? '${best?.market ?? ''} में सबसे अच्छा दाम\nवहाँ जाकर बेचो'
            : 'Best price at ${best?.market ?? ''}\nSell your crop there now')
        : advice == 'WAIT'
            ? (widget.isHindi ? 'दाम बढ़ रहे हैं\n5-7 दिन और रुको' : 'Prices rising\nWait 5-7 more days')
            : (widget.isHindi ? 'दाम एक जैसे हैं\n2-3 दिन देखो' : 'Prices stable\nMonitor 2-3 days');

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

          // TAB 1 — OVERVIEW
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
                      Text(emoji, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 10),
                      Text(title, style: TextStyle(color: ac, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Text(sub, textAlign: TextAlign.center,
                          style: TextStyle(color: ac.withOpacity(0.8), fontSize: 15, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Smart AI line
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ac.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Text('🧠 ', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.isHindi ? smartLineHindi : smartLine,
                          style: TextStyle(color: ac.withOpacity(0.9), fontSize: 12, fontStyle: FontStyle.italic, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // GPS Nearest Mandi Card
                if (widget.userLat != null && widget.userLng != null)
                  _buildNearestMandiCard(),
                if (widget.userLat != null && widget.userLng != null)
                  const SizedBox(height: 16),

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

                // Power card — Best overall
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
                        style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
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
                ],
                const SizedBox(height: 16),

                // Compare button
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
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios, color: Color(0xFF52B788), size: 12),
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
                    border: Border.all(color: const Color(0xFF52B788).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Color(0xFF52B788), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.isHindi
                              ? '$count मंडियों के आधार पर · AGMARKNET सरकारी डेटा · आज अपडेट हुआ'
                              : 'Based on $count mandis · AGMARKNET Govt Data · Updated today',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
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
                  widget.isHindi ? 'यात्रा से पहले जानें — क्या फायदेमंद है?' : 'Know before you travel — is it worth it?',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 16),
                _buildCalc(
                    decision['bestMandi'] as CropPrice?, widget.isHindi),
              ],
            ),
          ),

          // TAB 3 — MARKETS
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
                    gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                        drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true, reservedSize: 45,
                          getTitlesWidget: (v, m) => Text('₹${_getPrice(v).toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white38, fontSize: 8)))),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: widget.prices.asMap().entries.map((e) => BarChartGroupData(
                      x: e.key,
                      barRods: [BarChartRodData(
                        toY: _getPrice(e.value.modalPrice),
                        color: e.value == best
                            ? const Color(0xFF52B788)
                            : const Color(0xFF52B788).withOpacity(0.4),
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
                  // Get distance if GPS available
                  double? dist;
                  if (widget.userLat != null && widget.userLng != null) {
                    final mandisWithDist = DecisionEngine.getMandisWithDistance(
                        widget.prices, widget.userLat!, widget.userLng!);
                    final match = mandisWithDist.where((m) => (m['price'] as CropPrice) == p).toList();
                    if (match.isNotEmpty) dist = match.first['distance'] as double?;
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2744),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: p == best
                              ? const Color(0xFF52B788).withOpacity(0.5)
                              : Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(p.market, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                if (p == best) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFF52B788).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                    child: Text(widget.isHindi ? '✅ सबसे अच्छा' : '✅ BEST',
                                        style: const TextStyle(color: Color(0xFF52B788), fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ]),
                              Text(p.district, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                              if (dist != null)
                                Text('📍 ${dist.toStringAsFixed(0)} km away',
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

  Widget _buildNearestMandiCard() {
    final result = DecisionEngine.getBestNearbyMandi(
        widget.prices, widget.userLat!, widget.userLng!);
    if (result == null) return const SizedBox();

    final CropPrice price = result['price'] as CropPrice;
    final double? distance = result['distance'] as double?;

    String distText = distance != null
        ? '${distance.toStringAsFixed(0)} km ${widget.isHindi ? 'दूर' : 'away'}'
        : widget.isHindi ? 'दूरी अज्ञात' : 'Distance unknown';

    String travelText = '';
    if (distance != null) {
      int hrs = (distance / 60).floor();
      int mins = ((distance / 60 - hrs) * 60).round();
      travelText = hrs > 0 ? '~$hrs hr ${mins}min' : '~${mins}min';
    }

    return Container(
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
            const Icon(Icons.my_location, color: Colors.blueAccent, size: 16),
            const SizedBox(width: 8),
            Text(
              widget.isHindi ? '📍 आपके पास की सबसे अच्छी मंडी' : '📍 BEST MANDI NEAR YOU',
              style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(price.market, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${price.district}, ${price.state}',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.directions_car, color: Colors.blueAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(distText, style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
                      if (travelText.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.access_time, color: Colors.blueAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(travelText, style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
                      ],
                    ]),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${_getPrice(price.modalPrice).toStringAsFixed(_showPerKg ? 1 : 0)}',
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 22, fontWeight: FontWeight.w900)),
                  Text(_unit(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildCalc(CropPrice? best, bool isHindi) {
    if (best == null) return const SizedBox();
    final distC = TextEditingController();
    final qtyC = TextEditingController();
    final resultN = ValueNotifier<String>('');

    return StatefulBuilder(builder: (context, ss) {
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
              const Text('🚛 ', style: TextStyle(fontSize: 18)),
              Text(isHindi ? 'परिवहन लाभ कैलकुलेटर' : 'TRANSPORT PROFIT CALCULATOR',
                  style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ]),
            const SizedBox(height: 8),
            Text('${best.market} — ₹${_getPrice(best.modalPrice).toStringAsFixed(_showPerKg ? 1 : 0)} ${_unit()}',
                style: const TextStyle(color: Color(0xFF52B788), fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: distC,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: isHindi ? 'मंडी की दूरी (किमी)' : 'Distance to mandi (km)',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                filled: true, fillColor: const Color(0xFF0A1628),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.route, color: Color(0xFF52B788), size: 18),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: qtyC,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: isHindi ? 'बेचने की मात्रा (क्विंटल)' : 'Quantity to sell (quintals)',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                filled: true, fillColor: const Color(0xFF0A1628),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.scale, color: Color(0xFF52B788), size: 18),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                double dist = double.tryParse(distC.text) ?? 0;
                double qty = double.tryParse(qtyC.text) ?? 0;
                if (dist == 0 || qty == 0) {
                  resultN.value = isHindi ? 'कृपया दूरी और मात्रा दर्ज करें' : 'Please enter distance and quantity';
                  return;
                }
                final r = DecisionEngine.calculateProfit(price: best.modalPrice, quantity: qty, distance: dist);
                bool wi = r['worthIt'] as bool;
                double np = r['netProfit'] as double;
                double tc = r['transportCost'] as double;
                double ppq = r['profitPerQuintal'] as double;
                resultN.value = wi
                    ? (isHindi
                        ? '✅ यात्रा करना फायदेमंद है!\n\nकुल लाभ: ₹${np.toStringAsFixed(0)}\nप्रति क्विंटल: ₹${ppq.toStringAsFixed(0)}\nयात्रा खर्च: ₹${tc.toStringAsFixed(0)}'
                        : '✅ Worth the travel!\n\nTotal profit: ₹${np.toStringAsFixed(0)}\nPer quintal: ₹${ppq.toStringAsFixed(0)}\nTravel cost: ₹${tc.toStringAsFixed(0)}')
                    : (isHindi
                        ? '❌ यात्रा फायदेमंद नहीं\n\nयात्रा खर्च: ₹${tc.toStringAsFixed(0)}\nनजदीकी मंडी में बेचना बेहतर है'
                        : '❌ Not worth the travel\n\nTravel cost: ₹${tc.toStringAsFixed(0)}\nSell at local mandi instead');
              },
              child: Container(
                width: double.infinity, height: 44,
                decoration: BoxDecoration(color: const Color(0xFF52B788), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(isHindi ? 'लाभ की गणना करें' : 'CALCULATE NET PROFIT',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13))),
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: resultN,
              builder: (context, result, _) {
                if (result.isEmpty) return const SizedBox();
                bool pos = result.contains('✅');
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: pos ? const Color(0xFF52B788).withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: pos ? const Color(0xFF52B788).withOpacity(0.4) : Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: Text(result,
                      style: TextStyle(color: pos ? const Color(0xFF52B788) : Colors.redAccent,
                          fontSize: 13, height: 1.6, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
