import 'package:agropredict/logic/voice_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Hindi sentences', () {
    test('rice, number word, quintal', () {
      final r = VoiceParser.parse('मेरे पास बीस क्विंटल धान है।');
      expect(r.crop, 'Rice');
      expect(r.quantity, 20);
      expect(r.unit, 'quintal');
      expect(r.spokenEnglish, false);
    });

    test('potato with digits', () {
      final r = VoiceParser.parse('मेरे पास 25 क्विंटल आलू है');
      expect(r.crop, 'Potato');
      expect(r.quantity, 25);
      expect(r.unit, 'quintal');
    });

    test('onion in kilos', () {
      final r = VoiceParser.parse('मेरे पास पचास किलो प्याज है');
      expect(r.crop, 'Onion');
      expect(r.quantity, 50);
      expect(r.unit, 'kg');
    });

    test('tomato', () {
      final r = VoiceParser.parse('दस क्विंटल टमाटर बेचना है');
      expect(r.crop, 'Tomato');
      expect(r.quantity, 10);
    });

    test('wheat alternate spelling', () {
      final r = VoiceParser.parse('पांच क्विंटल गेंहू है');
      expect(r.crop, 'Wheat');
      expect(r.quantity, 5);
    });

    test('bhindi', () {
      final r = VoiceParser.parse('मेरे पास दस क्विंटल भिंडी है');
      expect(r.crop, 'Bhindi');
      expect(r.quantity, 10);
    });
  });

  group('English sentences', () {
    test('number word and quintal', () {
      final r = VoiceParser.parse('I have twenty quintal rice');
      expect(r.crop, 'Rice');
      expect(r.quantity, 20);
      expect(r.unit, 'quintal');
      expect(r.spokenEnglish, true);
    });

    test('digits', () {
      final r = VoiceParser.parse('I have 20 quintal wheat');
      expect(r.crop, 'Wheat');
      expect(r.quantity, 20);
    });

    test('number glued to the unit', () {
      final r = VoiceParser.parse('20kg rice');
      expect(r.crop, 'Rice');
      expect(r.quantity, 20);
      expect(r.unit, 'kg');
    });

    test('decimal quantity', () {
      final r = VoiceParser.parse('I have 2.5 quintal onion.');
      expect(r.crop, 'Onion');
      expect(r.quantity, 2.5);
    });

    test('kilo', () {
      final r = VoiceParser.parse('ten kilo tomato');
      expect(r.crop, 'Tomato');
      expect(r.quantity, 10);
      expect(r.unit, 'kg');
    });

    test('upper case', () {
      final r = VoiceParser.parse('RICE 20 QUINTAL');
      expect(r.crop, 'Rice');
      expect(r.quantity, 20);
    });
  });

  group('Speech written in Devanagari letters', () {
    test('english sentence transcribed in Hindi script', () {
      final r = VoiceParser.parse('आई हैव ट्वेंटी के जी राइस।');
      expect(r.crop, 'Rice');
      expect(r.quantity, 20);
      expect(r.unit, 'kg');
      expect(r.spokenEnglish, true);
    });
  });

  group('Missing information', () {
    test('crop but no quantity', () {
      final r = VoiceParser.parse('In which mandi is tomato higher in price?');
      expect(r.crop, 'Tomato');
      expect(r.quantity, isNull);
      expect(r.unit, '');
    });

    test('crop and unit but no number', () {
      final r = VoiceParser.parse('rice price in quintal');
      expect(r.crop, 'Rice');
      expect(r.quantity, isNull);
      expect(r.unit, 'quintal');
    });

    test('no crop at all', () {
      final r = VoiceParser.parse('what is the weather today');
      expect(r.crop, isNull);
    });

    test('empty text', () {
      final r = VoiceParser.parse('');
      expect(r.crop, isNull);
      expect(r.quantity, isNull);
    });
  });
}