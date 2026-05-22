class MandiLocations {
  static const Map<String, Map<String, double>> coordinates = {
    "Bhubaneswar": {"lat": 20.2961, "lng": 85.8245},
    "Cuttack": {"lat": 20.4625, "lng": 85.8830},
    "Berhampur": {"lat": 19.3150, "lng": 84.7941},
    "Sambalpur": {"lat": 21.4669, "lng": 83.9812},
    "Rourkela": {"lat": 22.2604, "lng": 84.8536},
    "Balasore": {"lat": 21.4942, "lng": 86.9317},
    "Kantabanji": {"lat": 20.4700, "lng": 82.9200},
    "Jeypore": {"lat": 18.8535, "lng": 82.5720},
    "Pune": {"lat": 18.5204, "lng": 73.8567},
    "Nashik": {"lat": 19.9975, "lng": 73.7898},
    "Nagpur": {"lat": 21.1458, "lng": 79.0882},
    "Amritsar": {"lat": 31.6340, "lng": 74.8723},
    "Ludhiana": {"lat": 30.9010, "lng": 75.8573},
    "Ahmedgarh": {"lat": 30.6700, "lng": 75.8500},
    "Fatehabad": {"lat": 29.5177, "lng": 75.4570},
    "Lucknow": {"lat": 26.8467, "lng": 80.9462},
    "Bhopal": {"lat": 23.2599, "lng": 77.4126},
    "Indore": {"lat": 22.7196, "lng": 75.8577},
    "Hyderabad": {"lat": 17.3850, "lng": 78.4867},
    "Vijayawada": {"lat": 16.5062, "lng": 80.6480},
    "Bangalore": {"lat": 12.9716, "lng": 77.5946},
    "Chennai": {"lat": 13.0827, "lng": 80.2707},
    "Coimbatore": {"lat": 11.0168, "lng": 76.9558},
    "Mettupalayam": {"lat": 11.2970, "lng": 76.9330},
    "Dindigul": {"lat": 10.3624, "lng": 77.9695},
    "Jaipur": {"lat": 26.9124, "lng": 75.7873},
    "Ahmedabad": {"lat": 23.0225, "lng": 72.5714},
    "Surat": {"lat": 21.1702, "lng": 72.8311},
    "Kolkata": {"lat": 22.5726, "lng": 88.3639},
    "Siliguri": {"lat": 26.7271, "lng": 88.3953},
    "Patna": {"lat": 25.5941, "lng": 85.1376},
    "Ranchi": {"lat": 23.3441, "lng": 85.3096},
    "Raipur": {"lat": 21.2514, "lng": 81.6296},
    "Durg": {"lat": 21.1904, "lng": 81.2849},
    "Jammu": {"lat": 32.7266, "lng": 74.8570},
    "Hamirpur": {"lat": 31.6862, "lng": 76.5218},
    "Jalalabad": {"lat": 30.5850, "lng": 74.2000},
    "Malappuram": {"lat": 11.0510, "lng": 76.0711},
    "Banaskantha": {"lat": 24.1700, "lng": 72.4300},
    "Sangrur": {"lat": 30.2344, "lng": 75.8442},
    "Fazilka": {"lat": 30.4022, "lng": 74.0292},
    "Kangra": {"lat": 32.0998, "lng": 76.2691},
    "Warangal": {"lat": 17.9784, "lng": 79.5941},
    "Guntur": {"lat": 16.2960, "lng": 80.4365},
    "Mysore": {"lat": 12.2958, "lng": 76.6394},
    "Madurai": {"lat": 9.9252, "lng": 78.1198},
    "Jodhpur": {"lat": 26.2389, "lng": 73.0243},
    "Rajkot": {"lat": 22.3039, "lng": 70.8022},
    "Varanasi": {"lat": 25.3176, "lng": 82.9739},
    "Kochi": {"lat": 9.9312, "lng": 76.2673},
    "Jamshedpur": {"lat": 22.8046, "lng": 86.2029},
  };

  static Map<String, double>? getCoordinates(String mandiName) {
    if (coordinates.containsKey(mandiName)) {
      return coordinates[mandiName];
    }
    for (final entry in coordinates.entries) {
      if (mandiName.toLowerCase().contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(mandiName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
