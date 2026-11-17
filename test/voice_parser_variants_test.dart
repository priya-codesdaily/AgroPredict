import 'package:agropredict/logic/voice_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('spelling variants from speech recognition', () {
    test('onion with dotted ज (separate nukta)', () {
      final r = VoiceParser.parse('पचास किलो प्याज\u093C है');
      expect(r.crop, 'Onion');
      expect(r.quantity, 50);
      expect(r.unit, 'kg');
    });

    test('onion with dotted ज (single character)', () {
      final r = VoiceParser.parse('पचास किलो प्या\u095B है');
      expect(r.crop, 'Onion');
      expect(r.quantity, 50);
    });

    test('wheat and five with chandrabindu', () {
      final r = VoiceParser.parse('पा\u0901च क्विंटल गेहू\u0901 है');
      expect(r.crop, 'Wheat');
      expect(r.quantity, 5);
      expect(r.unit, 'quintal');
    });

    test('fifty with dotted फ, written in Devanagari', () {
      final r = VoiceParser.parse('आई हैव फ\u093Cिफ्टी के जी अनियन');
      expect(r.crop, 'Onion');
      expect(r.quantity, 50);
      expect(r.unit, 'kg');
    });

    test('pomegranate with candra e', () {
      final r = VoiceParser.parse('आई ह\u0945व अ हंड्रेड के जी पामग्र\u0945नेट');
      expect(r.crop, 'Pomegranate');
      expect(r.quantity, 100);
      expect(r.unit, 'kg');
    });
  });

  group('more number words', () {
    test('Hindi two', () {
      final r = VoiceParser.parse('मेरे पास दो क्विंटल प्याज है');
      expect(r.quantity, 2);
    });

    test('Hindi eight', () {
      final r = VoiceParser.parse('मेरे पास आठ क्विंटल टमाटर है');
      expect(r.quantity, 8);
    });

    test('Hindi twelve', () {
      final r = VoiceParser.parse('बारह क्विंटल आलू है');
      expect(r.quantity, 12);
    });

    test('Hindi eighty with wheat', () {
      final r = VoiceParser.parse('मेरे पास अस्सी किलो गेहूं है');
      expect(r.crop, 'Wheat');
      expect(r.quantity, 80);
      expect(r.unit, 'kg');
    });

    test('English two', () {
      final r = VoiceParser.parse('I have two quintal bhindi');
      expect(r.crop, 'Bhindi');
      expect(r.quantity, 2);
    });
  });

  group('numbers made of two words', () {
    test('twenty five', () {
      final r = VoiceParser.parse('I have twenty five quintal soyabean');
      expect(r.crop, 'Soybean');
      expect(r.quantity, 25);
    });

    test('thirty five', () {
      final r = VoiceParser.parse('thirty five kg potato');
      expect(r.quantity, 35);
    });

    test('twenty five in Devanagari letters', () {
      final r = VoiceParser.parse('ट्वेंटी फाइव क्विंटल राइस');
      expect(r.crop, 'Rice');
      expect(r.quantity, 25);
    });

    test('plain twenty is still twenty', () {
      final r = VoiceParser.parse('I have twenty quintal rice');
      expect(r.quantity, 20);
    });
  });
}