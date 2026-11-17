class ParsedQuery {
  final String? crop;
  final double? quantity;
  final String unit;
  final bool spokenEnglish;

  const ParsedQuery({
    this.crop,
    this.quantity,
    this.unit = '',
    this.spokenEnglish = false,
  });
}

class VoiceParser {
  static const Map<String, String> _hindiCrops = {
    'टमाटर': 'Tomato',
    'आलू': 'Potato',
    'प्याज': 'Onion',
    'चावल': 'Rice',
    'धान': 'Rice',
    'गेहूं': 'Wheat',
    'गेहू': 'Wheat',
    'गेंहू': 'Wheat',
    'आम': 'Mango',
    'कपास': 'Cotton',
    'सोयाबीन': 'Soybean',
    'भिंडी': 'Bhindi',
    'करेला': 'Bitter Gourd',
    'अनार': 'Pomegranate',
  };

  // English crop words, written in English or in Devanagari letters
  static const Map<String, String> _englishCrops = {
    'tomato': 'Tomato', 'टोमेटो': 'Tomato', 'टमाटो': 'Tomato',
    'potato': 'Potato', 'पोटैटो': 'Potato', 'पोटेटो': 'Potato',
    'onion': 'Onion', 'अनियन': 'Onion', 'ओनियन': 'Onion',
    'rice': 'Rice', 'paddy': 'Rice', 'राइस': 'Rice', 'राईस': 'Rice', 'पैडी': 'Rice',
    'wheat': 'Wheat', 'व्हीट': 'Wheat', 'वीट': 'Wheat',
    'mango': 'Mango', 'मैंगो': 'Mango', 'मेंगो': 'Mango',
    'cotton': 'Cotton', 'कॉटन': 'Cotton', 'कोटन': 'Cotton',
    'soybean': 'Soybean', 'soyabean': 'Soybean',
    'bhindi': 'Bhindi', 'okra': 'Bhindi', 'ओकरा': 'Bhindi',
    'karela': 'Bitter Gourd',
    'anar': 'Pomegranate', 'pomegranate': 'Pomegranate', 'पोमेग्रेनेट': 'Pomegranate',
  };

  static const Map<String, double> _numberWords = {
    'five': 5, 'ten': 10, 'fifteen': 15, 'twenty': 20, 'twenty-five': 25,
    'thirty': 30, 'forty': 40, 'fifty': 50, 'hundred': 100,
    'फाइव': 5, 'टेन': 10, 'फिफ्टीन': 15, 'ट्वेंटी': 20, 'ट्वेंटीफाइव': 25,
    'थर्टी': 30, 'फोर्टी': 40, 'फिफ्टी': 50, 'हंड्रेड': 100,
    'पांच': 5, 'पाँच': 5, 'दस': 10, 'पंद्रह': 15, 'बीस': 20, 'पच्चीस': 25,
    'तीस': 30, 'चालीस': 40, 'पचास': 50, 'सौ': 100,
  };

  static ParsedQuery parse(String text) {
    final cleaned = text
        .toLowerCase()
        .replaceAll(RegExp(r'के\s*जी'), ' kg ')
        .replaceAll(RegExp(r'\bk\.?\s*g\.?\b'), ' kg ')
        .replaceAllMapped(
          RegExp(r'(\d)(?=[a-z\u0900-\u097F])'),
          (m) => '${m[1]} ',
        );

    final words = cleaned
        .split(RegExp(r'[\s,।?!]+|\.(?!\d)'))
        .where((w) => w.isNotEmpty)
        .toList();

    String? crop;
    var spokenEnglish = false;
    for (final w in words) {
      if (_hindiCrops.containsKey(w)) {
        crop = _hindiCrops[w];
        break;
      }
      if (_englishCrops.containsKey(w)) {
        crop = _englishCrops[w];
        spokenEnglish = true;
        break;
      }
    }

    var unit = '';
    for (final w in words) {
      if (w.startsWith('quintal') ||
          w.startsWith('क्विंटल') ||
          w.startsWith('क्विन्टल') ||
          w.startsWith('क्वींटल') ||
          w.startsWith('कुंतल')) {
        unit = 'quintal';
        break;
      }
      if (w == 'kg' ||
          w == 'kgs' ||
          w == 'kilo' ||
          w == 'kilos' ||
          w == 'किलो' ||
          w == 'किलोग्राम' ||
          w == 'किग्रा' ||
          w.startsWith('kilogram')) {
        unit = 'kg';
        break;
      }
    }

    double? quantity;
    if (unit.isNotEmpty) {
      for (final w in words) {
        final n = double.tryParse(w) ?? _numberWords[w];
        if (n != null) {
          quantity = n;
          break;
        }
      }
    }

    return ParsedQuery(
      crop: crop,
      quantity: quantity,
      unit: unit,
      spokenEnglish: spokenEnglish,
    );
  }
}