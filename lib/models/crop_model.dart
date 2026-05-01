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

  factory CropPrice.fromJson(Map<String, dynamic> json) {
    return CropPrice(
      cropName: json['commodity'] ?? '',
      market: json['market'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      minPrice: double.tryParse(json['min_price']?.toString() ?? '0') ?? 0,
      maxPrice: double.tryParse(json['max_price']?.toString() ?? '0') ?? 0,
      modalPrice: double.tryParse(json['modal_price']?.toString() ?? '0') ?? 0,
      arrivalDate: json['arrival_date'] ?? '',
    );
  }
}
  
