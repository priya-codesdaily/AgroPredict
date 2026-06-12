import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crop_model.dart';

class MandiService {
  static const String _apiKey = '579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b';
  static const String _baseUrl = 'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070';

  static Future<List<CropPrice>> fetchPrices({
    required String cropName,
    String? state,
    int limit = 50,
  }) async {
    try {
      String url = '$_baseUrl?api-key=$_apiKey&format=json&limit=$limit&filters%5Bcommodity%5D=$cropName';
      if (state != null && state.isNotEmpty) {
        url += '&filters%5Bstate%5D=$state';
      }
      final response = await http.get(Uri.parse(url), headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['records'] != null && (data['records'] as List).isNotEmpty) {
          return (data['records'] as List).map((r) => CropPrice.fromJson(r)).toList();
        }
      }
      return getMockData(cropName);
    } catch (e) {
      return getMockData(cropName);
    }
  }

  static List<CropPrice> getMockData(String cropName) {
    return [
      CropPrice(cropName: cropName, market: 'Simdega', state: 'Jharkhand', district: 'Simdega', minPrice: 900, maxPrice: 1500, modalPrice: 1200, arrivalDate: '10/06/2026'),
      CropPrice(cropName: cropName, market: 'Chaibasa', state: 'Jharkhand', district: 'West Singhbhum', minPrice: 1000, maxPrice: 1600, modalPrice: 1300, arrivalDate: '10/06/2026'),
      CropPrice(cropName: cropName, market: 'Ranchi', state: 'Jharkhand', district: 'Ranchi', minPrice: 1100, maxPrice: 1800, modalPrice: 1500, arrivalDate: '10/06/2026'),
      CropPrice(cropName: cropName, market: 'Jamshedpur', state: 'Jharkhand', district: 'East Singhbhum', minPrice: 1200, maxPrice: 1900, modalPrice: 1600, arrivalDate: '10/06/2026'),
      CropPrice(cropName: cropName, market: 'Rourkela', state: 'Odisha', district: 'Sundergarh', minPrice: 1200, maxPrice: 1800, modalPrice: 1500, arrivalDate: '10/06/2026'),
      CropPrice(cropName: cropName, market: 'Bhubaneswar', state: 'Odisha', district: 'Khurda', minPrice: 1400, maxPrice: 2000, modalPrice: 1700, arrivalDate: '10/06/2026'),
      CropPrice(cropName: cropName, market: 'Cuttack', state: 'Odisha', district: 'Cuttack', minPrice: 1100, maxPrice: 1900, modalPrice: 1600, arrivalDate: '10/06/2026'),
      CropPrice(cropName: cropName, market: 'Sambalpur', state: 'Odisha', district: 'Sambalpur', minPrice: 1000, maxPrice: 1700, modalPrice: 1400, arrivalDate: '10/06/2026'),
      CropPrice(cropName: cropName, market: 'Berhampur', state: 'Odisha', district: 'Ganjam', minPrice: 1300, maxPrice: 2100, modalPrice: 1800, arrivalDate: '10/06/2026'),
      CropPrice(cropName: cropName, market: 'Bokaro', state: 'Jharkhand', district: 'Bokaro', minPrice: 1150, maxPrice: 1750, modalPrice: 1450, arrivalDate: '10/06/2026'),
    ];
  }
}