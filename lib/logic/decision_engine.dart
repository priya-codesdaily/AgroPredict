import 'package:geolocator/geolocator.dart';
import '../models/crop_model.dart';
import '../data/mandi_locations.dart';

class DecisionEngine {
  static Map<String, dynamic> analyze(List<CropPrice> prices) {
    if (prices.isEmpty) {
      return {
        'advice': 'NEUTRAL',
        'bestMandi': null,
        'avgPrice': 0.0,
        'percentAboveAvg': 0.0,
        'reasons': ['No data available'],
        'mandiCount': 0,
        'smartLine': 'No data available',
        'smartLineHindi': 'कोई डेटा उपलब्ध नहीं',
      };
    }
    double avgPrice = prices.map((p) => p.modalPrice).reduce((a, b) => a + b) / prices.length;
    CropPrice bestMandi = prices.reduce((a, b) => a.modalPrice > b.modalPrice ? a : b);
    double percentAboveAvg = ((bestMandi.modalPrice - avgPrice) / avgPrice) * 100;

    String advice;
    if (percentAboveAvg > 20) {
      advice = 'SELL';
    } else if (avgPrice > 2500 && percentAboveAvg < 10) {
      advice = 'SELL';
    } else if (avgPrice < 1500) {
      advice = 'WAIT';
    } else if (percentAboveAvg > 10) {
      advice = 'WAIT';
    } else {
      advice = 'NEUTRAL';
    }

List<String> reasons = [];
List<String> reasonsHindi = [];

if (advice == 'SELL') {
  reasons.add('Price is ${percentAboveAvg.toStringAsFixed(0)}% higher than nearby markets');
  reasons.add('Best rate found in ${bestMandi.market}');
  reasons.add('Good time to sell — prices are stable');
  reasonsHindi.add('दाम ${percentAboveAvg.toStringAsFixed(0)}% ज़्यादा है पास की मंडियों से');
  reasonsHindi.add('${bestMandi.market} में सबसे अच्छा दाम मिला है');
  reasonsHindi.add('बेचने का सही समय है — दाम स्थिर हैं');
} else if (advice == 'WAIT') {
  reasons.add('Average price is currently below normal');
  reasons.add('Monitor daily — prices could improve');
  reasons.add('Sell only if storage cost is high');
  reasonsHindi.add('अभी औसत दाम सामान्य से कम है');
  reasonsHindi.add('रोज़ देखते रहें — दाम बेहतर हो सकते हैं');
  reasonsHindi.add('केवल तभी बेचें जब रखने का खर्च ज़्यादा हो');
} else {
  reasons.add('Prices are similar across all mandis');
  reasons.add('Monitor for 2-3 more days before deciding');
  reasonsHindi.add('सभी मंडियों में दाम लगभग एक जैसे हैं');
  reasonsHindi.add('फैसला करने से पहले 2-3 दिन और देखें');
}
    String smartLine;
    String smartLineHindi;
    if (advice == 'SELL') {
      if (percentAboveAvg > 30) {
        smartLine = 'Unusually high price — sell immediately before it drops';
        smartLineHindi = 'असामान्य रूप से ऊँचा दाम — तुरंत बेचें';
      } else if (percentAboveAvg > 20) {
        smartLine = 'Strong demand detected — good time to sell';
        smartLineHindi = 'ज़्यादा माँग है — अभी बेचना फायदेमंद है';
      } else {
        smartLine = 'Stable price — sell now to avoid future risk';
        smartLineHindi = 'दाम स्थिर है — अभी बेचो';
      }
    } else if (advice == 'WAIT') {
      smartLine = 'Prices are below average this week. Monitor before selling.';
      smartLineHindi = 'इस हफ्ते दाम औसत से कम हैं। बेचने से पहले देखते रहें।';
    } else {
      smartLine = 'Monitor daily — prices could move either way';
      smartLineHindi = 'रोज़ देखते रहें';
    }

    return {
      'advice': advice,
      'bestMandi': bestMandi,
      'avgPrice': avgPrice,
      'percentAboveAvg': percentAboveAvg,
      'reasons': reasons,
      'mandiCount': prices.length,
      'smartLine': smartLine,
      'smartLineHindi': smartLineHindi,
    };
  }

  static Map<String, dynamic> calculateProfit({
    required double price,
    required double quantity,
    required double distance,
    double costPerKm = 10.0,
  }) {
    double totalRevenue = price * quantity;
    double transportCost = distance * costPerKm;
    double netProfit = totalRevenue - transportCost;
    double profitPerQuintal = netProfit / quantity;
    bool worthIt = netProfit > (totalRevenue * 0.7);
    return {
      'totalRevenue': totalRevenue,
      'transportCost': transportCost,
      'netProfit': netProfit,
      'profitPerQuintal': profitPerQuintal,
      'worthIt': worthIt,
    };
  }

  static List<Map<String, dynamic>> getMandisWithDistance(
      List<CropPrice> prices, double userLat, double userLng) {
    List<Map<String, dynamic>> result = [];
    for (final price in prices) {
      final coords = MandiLocations.getCoordinates(price.market);
      double? distance;
      if (coords != null) {
        distance = Geolocator.distanceBetween(
          userLat, userLng, coords['lat']!, coords['lng']!,
        ) / 1000;
      }
      result.add({'price': price, 'distance': distance, 'hasLocation': coords != null});
    }
    result.sort((a, b) {
      if (a['distance'] == null && b['distance'] == null) return 0;
      if (a['distance'] == null) return 1;
      if (b['distance'] == null) return -1;
      return (a['distance'] as double).compareTo(b['distance'] as double);
    });
    return result;
  }

  static Map<String, dynamic>? getNearestMandi(
      List<CropPrice> prices, double userLat, double userLng) {
    final mandisWithDist = getMandisWithDistance(prices, userLat, userLng);
    final known = mandisWithDist.where((m) => m['distance'] != null).toList();
    if (known.isEmpty) return null;
    known.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    return known.first;
  }

  static Map<String, dynamic>? getBestNearbyMandi(
      List<CropPrice> prices, double userLat, double userLng,
      {double maxKm = 500}) {
    final mandisWithDist = getMandisWithDistance(prices, userLat, userLng);
    final nearby = mandisWithDist.where((m) =>
        m['distance'] == null || (m['distance'] as double) <= maxKm).toList();
    if (nearby.isEmpty) return null;
    nearby.sort((a, b) {
      final priceA = (a['price'] as CropPrice).modalPrice;
      final priceB = (b['price'] as CropPrice).modalPrice;
      return priceB.compareTo(priceA);
    });
    return nearby.first;
  }
}