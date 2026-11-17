class CropVarieties {
  static const Map<String, List<String>> varieties = {
    'Rice': ['All Rice', 'Basmati', 'Sona Masuri', 'IR64', 'Ponni', 'Common'],
    'Mango': ['All Mango', 'Alphonso', 'Kesar', 'Dasheri', 'Langra', 'Local'],
    'Wheat': ['All Wheat', 'Sharbati', 'Lokwan', 'Common'],
    'Tomato': ['All Tomato', 'Hybrid', 'Country', 'Cherry'],
    'Potato': ['All Potato', 'Jyoti', 'Kufri', 'Common'],
    'Onion': ['All Onion', 'Red', 'White', 'Small'],
    'Cotton': ['All Cotton', 'Long Staple', 'Medium Staple', 'Common'],
    'Soybean': ['All Soybean', 'Yellow', 'Common'],
  };

  static List<String> getVarieties(String crop) {
    return varieties[crop] ?? ['All ${crop}'];
  }

  static bool hasVarieties(String crop) {
    final v = varieties[crop];
    return v != null && v.length > 1;
  }
}
