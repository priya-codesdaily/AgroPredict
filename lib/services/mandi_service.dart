import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crop_model.dart';

class MandiService {
  static const String _apiKey = '579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b';
  static const String _baseUrl =
      'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070';

  static Future<List<CropPrice>> fetchPrices({
    required String cropName,
    String? state,
    int limit = 50,
  }) async {
    try {
      String url =
          '$_baseUrl?api-key=$_apiKey&format=json&limit=$limit&filters%5Bcommodity%5D=$cropName';

      if (state != null && state.isNotEmpty) {
        url += '&filters%5Bstate%5D=$state';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['records'] != null && (data['records'] as List).isNotEmpty) {
          final records = data['records'] as List;
          return records.map((r) => CropPrice.fromJson(r)).toList();
        } else {
          return getMockData(cropName);
        }
      } else {
        return getMockData(cropName);
      }
    } catch (e) {
      return getMockData(cropName);
    }
  }

  static List<CropPrice> getMockData(String cropName) {
    return [
      CropPrice(cropName: cropName, market: 'Rourkela', state: 'Odisha', district: 'Sundergarh', minPrice: 1200, maxPrice: 1800, modalPrice: 1500, arrivalDate: '01/05/2026'),
      CropPrice(cropName: cropName, market: 'Bhubaneswar', state: 'Odisha', district: 'Khurda', minPrice: 1400, maxPrice: 2000, modalPrice: 1700, arrivalDate: '01/05/2026'),
      CropPrice(cropName: cropName, market: 'Cuttack', state: 'Odisha', district: 'Cuttack', minPrice: 1100, maxPrice: 1900, modalPrice: 1600, arrivalDate: '01/05/2026'),
      CropPrice(cropName: cropName, market: 'Sambalpur', state: 'Odisha', district: 'Sambalpur', minPrice: 1000, maxPrice: 1700, modalPrice: 1400, arrivalDate: '01/05/2026'),
      CropPrice(cropName: cropName, market: 'Berhampur', state: 'Odisha', district: 'Ganjam', minPrice: 1300, maxPrice: 2100, modalPrice: 1800, arrivalDate: '01/05/2026'),
    ];
  }

  static String getSellAdvice(List<CropPrice> prices) {
    if (prices.isEmpty) return 'NEUTRAL';

    double avgModal =
        prices.map((p) => p.modalPrice).reduce((a, b) => a + b) / prices.length;
    double maxModal =
        prices.map((p) => p.modalPrice).reduce((a, b) => a > b ? a : b);

    double percentAboveAvg = ((maxModal - avgModal) / avgModal) * 100;

    if (percentAboveAvg > 20) return 'SELL';
    if (avgModal > 2500 && percentAboveAvg < 10) return 'SELL';
    if (avgModal < 1500 && percentAboveAvg < 10) return 'WAIT';
    if (percentAboveAvg > 10) return 'WAIT';

    return 'NEUTRAL';
  }

  static CropPrice? getBestMandi(List<CropPrice> prices) {
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a.modalPrice > b.modalPrice ? a : b);
  }
}
