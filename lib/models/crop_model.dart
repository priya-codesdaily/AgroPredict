class CropPrice {
  final String cropName;
  final String market;
  final String state;
  final String district;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final String arrivalDate;

  CropPrice({
    required this.cropName,
    required this.market,
    required this.state,
    required this.district,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.arrivalDate,
  });

  static double _parsePrice(dynamic value) {
    if (value == null) return 0;
    String str = value.toString().replaceAll(',', '').trim();
    return double.tryParse(str) ?? 0;
  }

  factory CropPrice.fromJson(Map<String, dynamic> json) {
    return CropPrice(
      cropName: json['commodity'] ?? json['crop'] ?? '',
      market: json['market'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      minPrice: _parsePrice(json['min_price']),
      maxPrice: _parsePrice(json['max_price']),
      modalPrice: _parsePrice(json['modal_price']),
      arrivalDate: json['arrival_date'] ?? '',
    );
  }
}