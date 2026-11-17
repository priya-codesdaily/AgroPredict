
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
        'reasonsHindi': ['कोई डेटा उपलब्ध नहीं'],
        'mandiCount': 0,
        'smartLine': 'No data available',
        'smartLineHindi': 'कोई डेटा उपलब्ध नहीं',
      };
    }

    final avgPrice = prices
            .map((p) => p.modalPrice)
            .reduce((a, b) => a + b) /
        prices.length;

    final bestMandi = prices.reduce(
      (a, b) => a.modalPrice > b.modalPrice ? a : b,
    );

    final percentAboveAvg =
        avgPrice == 0 ? 0.0 : ((bestMandi.modalPrice - avgPrice) / avgPrice) * 100;

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

    final List<String> reasons = [];
    final List<String> reasonsHindi = [];

    if (advice == 'SELL') {
      reasons.add(
        'Price is ${percentAboveAvg.toStringAsFixed(0)}% higher than the average',
      );
      reasons.add('Best rate found in ${bestMandi.market}');
      reasons.add('Compare transport costs before deciding');

      reasonsHindi.add(
        'दाम औसत से ${percentAboveAvg.toStringAsFixed(0)}% ज़्यादा है',
      );
      reasonsHindi.add('${bestMandi.market} में सबसे अच्छा दाम मिला है');
      reasonsHindi.add('फैसले से पहले परिवहन का खर्च देखें');
    } else if (advice == 'WAIT') {
      reasons.add('Average price is currently relatively low');
      reasons.add('Monitor prices before deciding to sell');
      reasons.add('Consider storage costs and crop condition');

      reasonsHindi.add('अभी औसत दाम कम है');
      reasonsHindi.add('बेचने का फैसला करने से पहले दाम देखते रहें');
      reasonsHindi.add('भंडारण खर्च और फसल की स्थिति देखें');
    } else {
      reasons.add('Prices are relatively similar');
      reasons.add('Monitor prices before deciding');
      reasonsHindi.add('मंडियों में दाम लगभग एक जैसे हैं');
      reasonsHindi.add('फैसला करने से पहले दाम देखते रहें');
    }

    String smartLine;
    String smartLineHindi;

    if (advice == 'SELL') {
      smartLine = 'A higher price is available; compare net proceeds first.';
      smartLineHindi = 'बेहतर दाम उपलब्ध है; पहले खर्च घटाकर कमाई देखें।';
    } else if (advice == 'WAIT') {
      smartLine = 'Prices look relatively low. Monitor before deciding.';
      smartLineHindi = 'दाम कम लग रहे हैं। फैसला करने से पहले देखते रहें।';
    } else {
      smartLine = 'Monitor prices and compare your selling options.';
      smartLineHindi = 'दाम देखते रहें और बेचने के विकल्पों की तुलना करें।';
    }

    return {
      'advice': advice,
      'bestMandi': bestMandi,
      'avgPrice': avgPrice,
      'percentAboveAvg': percentAboveAvg,
      'reasons': reasons,
      'reasonsHindi': reasonsHindi,
      'mandiCount': prices.length,
      'smartLine': smartLine,
      'smartLineHindi': smartLineHindi,
    };
  }

  static Map<String, dynamic> calculateProfit({
    required double price,
    required double quantity,
    required double distance,
    required double avgPrice,
    double costPerKm = 12.0,
  }) {
    final transportCost = distance * costPerKm;
    final totalEarnings = price * quantity;
    final netInHand = totalEarnings - transportCost;
    final localEarnings = avgPrice * quantity;
    final netGain = netInHand - localEarnings;
    final worthIt = netInHand > localEarnings;

    return {
      'transportCost': transportCost,
      'totalEarnings': totalEarnings,
      'netInHand': netInHand,
      'localEarnings': localEarnings,
      'netGain': netGain,
      'extraEarnings': netGain,
      'worthIt': worthIt,
    };
  }

  static List<Map<String, dynamic>> getMandisWithDistance(
    List<CropPrice> prices,
    double userLat,
    double userLng,
  ) {
    final List<Map<String, dynamic>> result = [];

    for (final price in prices) {
      final coords = MandiLocations.getCoordinates(price.market);
      double? distance;

      if (coords != null) {
        distance = Geolocator.distanceBetween(
              userLat,
              userLng,
              coords['lat']!,
              coords['lng']!,
            ) /
            1000;
      }

      result.add({
        'price': price,
        'distance': distance,
        'hasLocation': coords != null,
      });
    }

    result.sort((a, b) {
      if (a['distance'] == null && b['distance'] == null) return 0;
      if (a['distance'] == null) return 1;
      if (b['distance'] == null) return -1;

      return (a['distance'] as double)
          .compareTo(b['distance'] as double);
    });

    return result;
  }

  static Map<String, dynamic>? getNearestMandi(
    List<CropPrice> prices,
    double userLat,
    double userLng,
  ) {
    final list = getMandisWithDistance(prices, userLat, userLng);

    final known = list
        .where((m) => m['distance'] != null)
        .toList();

    if (known.isEmpty) return null;

    known.sort(
      (a, b) => (a['distance'] as double)
          .compareTo(b['distance'] as double),
    );

    return known.first;
  }

  static Map<String, dynamic>? getBestNearbyMandi(
    List<CropPrice> prices,
    double userLat,
    double userLng, {
    double maxKm = 500,
  }) {
    final list = getMandisWithDistance(prices, userLat, userLng);

    final nearby = list
        .where(
          (m) =>
              m['distance'] != null &&
              (m['distance'] as num) <= maxKm,
        )
        .toList();

    if (nearby.isEmpty) return null;

    nearby.sort(
      (a, b) => (b['price'] as CropPrice)
          .modalPrice
          .compareTo((a['price'] as CropPrice).modalPrice),
    );

    return nearby.first;
  }
}
