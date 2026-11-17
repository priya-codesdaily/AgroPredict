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
  // Speech models spell the same Hindi word in several ways. This puts the
  // common variants (dotted letters, chandrabindu, candra e) into one form,
  // so one dictionary entry matches all of them.
  static String _norm(String s) {
    var t = s.toLowerCase();
    const precomposed = {
      '\u0958': '\u0915',
      '\u0959': '\u0916',
      '\u095A': '\u0917',
      '\u095B': '\u091C',
      '\u095C': '\u0921',
      '\u095D': '\u0922',
      '\u095E': '\u092B',
      '\u095F': '\u092F',
    };
    for (final e in precomposed.entries) {
      t = t.replaceAll(e.key, e.value);
    }
    return t
        .replaceAll('\u093C', '')
        .replaceAll('\u0901', '\u0902')
        .replaceAll('\u0945', '\u0947');
  }

  static Map<String, T> _normKeys<T>(Map<String, T> m) =>
      m.map((k, v) => MapEntry(_norm(k), v));

  static final Map<String, String> _hindiCrops = _normKeys(<String, String>{
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
  });

  // English crop words, written in English or in Devanagari letters
  static final Map<String, String> _englishCrops = _normKeys(<String, String>{
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
    'anar': 'Pomegranate', 'pomegranate': 'Pomegranate',
    'पोमेग्रेनेट': 'Pomegranate', 'पामग्रेनेट': 'Pomegranate',
  });

  static final Map<String, double> _numbers = _normKeys(<String, double>{
    // English
    'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6,
    'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10, 'eleven': 11, 'twelve': 12,
    'thirteen': 13, 'fourteen': 14, 'fifteen': 15, 'sixteen': 16,
    'seventeen': 17, 'eighteen': 18, 'nineteen': 19, 'twenty': 20,
    'twenty-five': 25, 'thirty': 30, 'forty': 40, 'fifty': 50, 'sixty': 60,
    'seventy': 70, 'eighty': 80, 'ninety': 90, 'hundred': 100,
    // Hindi
    'एक': 1, 'दो': 2, 'तीन': 3, 'चार': 4, 'पांच': 5, 'पाँच': 5, 'छह': 6,
    'छः': 6, 'सात': 7, 'आठ': 8, 'नौ': 9, 'दस': 10, 'ग्यारह': 11, 'बारह': 12,
    'तेरह': 13, 'चौदह': 14, 'पंद्रह': 15, 'सोलह': 16, 'सत्रह': 17,
    'अठारह': 18, 'उन्नीस': 19, 'बीस': 20, 'पच्चीस': 25, 'तीस': 30,
    'चालीस': 40, 'पैंतालीस': 45, 'पचास': 50, 'साठ': 60, 'सत्तर': 70,
    'अस्सी': 80, 'नब्बे': 90, 'सौ': 100,
    // English numbers written in Devanagari letters
    'वन': 1, 'टू': 2, 'थ्री': 3, 'फोर': 4, 'फाइव': 5, 'सिक्स': 6, 'सेवन': 7,
    'एट': 8, 'नाइन': 9, 'टेन': 10, 'इलेवन': 11, 'ट्वेल्व': 12,
    'फिफ्टीन': 15, 'ट्वेंटी': 20, 'ट्वेंटीफाइव': 25, 'थर्टी': 30,
    'फोर्टी': 40, 'फिफ्टी': 50, 'सिक्सटी': 60, 'सेवंटी': 70, 'एटी': 80,
    'नाइंटी': 90, 'हंड्रेड': 100,
  });

  static final List<String> _quintalStarts = [
    'quintal',
    'क्विंटल',
    'क्विन्टल',
    'क्वींटल',
    'कुंतल',
  ].map(_norm).toList();

  static final Set<String> _kgWords = [
    'kg',
    'kgs',
    'kilo',
    'kilos',
    'किलो',
    'किलोग्राम',
    'किग्रा',
  ].map(_norm).toSet();

  static double? _readQuantity(List<String> words) {
    for (var i = 0; i < words.length; i++) {
      final n = double.tryParse(words[i]) ?? _numbers[words[i]];
      if (n == null) continue;
      // "twenty five" is 25, not 20
      if (n >= 20 && n < 100 && n % 10 == 0 && i + 1 < words.length) {
        final next = _numbers[words[i + 1]];
        if (next != null && next >= 1 && next <= 9) return n + next;
      }
      return n;
    }
    return null;
  }

  static ParsedQuery parse(String text) {
    final cleaned = _norm(text)
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
      if (_quintalStarts.any((p) => w.startsWith(p))) {
        unit = 'quintal';
        break;
      }
      if (_kgWords.contains(w) || w.startsWith('kilogram')) {
        unit = 'kg';
        break;
      }
    }

    final quantity = unit.isEmpty ? null : _readQuantity(words);

    return ParsedQuery(
      crop: crop,
      quantity: quantity,
      unit: unit,
      spokenEnglish: spokenEnglish,
    );
  }
}