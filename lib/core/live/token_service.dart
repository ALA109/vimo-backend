// lib/core/live/token_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TokenService {
  static const _base =
      'http://192.168.1.38:8080'; // غيّرها لاحقاً إذا نشرت الخادم سحابياً

  static Future<String> getZegoToken(String userId) async {
    final url = Uri.parse('$_base/zegotoken?userID=$userId');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      return body['token'] as String;
    } else {
      throw Exception('فشل في جلب التوكن: ${resp.statusCode}');
    }
  }
}
