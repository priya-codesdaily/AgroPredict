import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class VoiceService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<String> transcribe(
    Uint8List audioBytes, {
    String languageCode = 'indic-auto',
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/stt'))
      ..fields['language_code'] = languageCode
      ..files.add(http.MultipartFile.fromBytes(
        'audio',
        audioBytes,
        filename: 'speech.wav',
        contentType: MediaType('audio', 'wav'),
      ));

    final streamed = await request.send().timeout(const Duration(seconds: 40));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Speech service error (${response.statusCode})');
    }

    final data = json.decode(utf8.decode(response.bodyBytes));
    return (data['transcript'] ?? '').toString().trim();
  }

  static Future<Uint8List> speak(String text, {String language = 'hi-IN'}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/tts'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'text': text, 'language': language}),
        )
        .timeout(const Duration(seconds: 40));

    if (response.statusCode != 200) {
      throw Exception('Voice service error (${response.statusCode})');
    }
    return response.bodyBytes;
  }
}