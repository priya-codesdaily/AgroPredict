import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crop_model.dart';

class MandiService {
  // Government AGMARKNET API (data.gov.in)
  static const String _apiKey = 'YOUR_API_KEY';
  static const String _baseUrl =
      'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070';

  // Fetch crop prices by crop name and state
  static Future<List<CropPrice>> fetchPrices({
    required String cropName,
    String? state,
    int limit = 20,
  }) async {
    try {
      String url =
          '$_baseUrl?api-key=$_apiKey&format=json&limit=$limit&filters[commodity]=$cropName';

      if (state != null && state.isNotEmpty) {
        url += '&filters[state]=$state';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final records = data['records'] as List;
        return records.map((r) => CropPrice.fromJson(r)).toList();
      } else {
        return _getMockData(cropName);
      }
    } catch (e) {
      return _getMockData(cropName);
    }
  }

  // Mock data for testing without API key
  static List<CropPrice> _getMockData(String cropName) {
    return [
      CropPrice(
        cropName: cropName,
        market: 'Rourkela',
        state: 'Odisha',
        district: 'Sundergarh',
        minPrice: 1200,
        maxPrice: 1800,
        modalPrice: 1500,
        arrivalDate: '01/05/2026',
      ),
      CropPrice(
        cropName: cropName,
        market: 'Bhubaneswar',
        state: 'Odisha',
        district: 'Khurda',
        minPrice: 1400,
        maxPrice: 2000,
        modalPrice: 1700,
        arrivalDate: '01/05/2026',
      ),
      CropPrice(
        cropName: cropName,
        market: 'Cuttack',
        state: 'Odisha',
        district: 'Cuttack',
        minPrice: 1100,
        maxPrice: 1900,
        modalPrice: 1600,
        arrivalDate: '01/05/2026',
      ),
      CropPrice(
        cropName: cropName,
        market: 'Sambalpur',
        state: 'Odisha',
        district: 'Sambalpur',
        minPrice: 1000,
        maxPrice: 1700,
        modalPrice: 1400,
        arrivalDate: '01/05/2026',
      ),
      CropPrice(
        cropName: cropName,
        market: 'Berhampur',
        state: 'Odisha',
        district: 'Ganjam',
        minPrice: 1300,
        maxPrice: 2100,
        modalPrice: 1800,
        arrivalDate: '01/05/2026',
      ),
    ];
  }

  // Sell Now or Wait logic
  static String getSellAdvice(List<CropPrice> prices) {
    if (prices.isEmpty) return 'No data available';

    double avgModal =
        prices.map((p) => p.modalPrice).reduce((a, b) => a + b) /
            prices.length;
    double maxModal = prices.map((p) => p.modalPrice).reduce(
        (a, b) => a > b ? a : b);

    double difference = maxModal - avgModal;
    double percentDiff = (difference / avgModal) * 100;

    if (percentDiff > 15) {
      return 'WAIT';
    } else if (percentDiff > 8) {
      return 'NEUTRAL';
    } else {
      return 'SELL';
    }
  }

  // Get best mandi
  static CropPrice? getBestMandi(List<CropPrice> prices) {
    if (prices.isEmpty) return null;
    return prices.reduce(
        (a, b) => a.modalPrice > b.modalPrice ? a : b);
  }
}