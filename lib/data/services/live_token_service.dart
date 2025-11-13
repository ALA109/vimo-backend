import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:vimo/constants/app_config.dart';

class LiveTokenService {
  LiveTokenService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> fetchToken({
    String? roomId,
    String? liveId,
    required String userId,
  }) async {
    final resolvedRoomId = roomId ?? liveId;
    if (resolvedRoomId == null || resolvedRoomId.isEmpty) {
      throw Exception('Missing roomId for token request.');
    }

    final endpoint = AppConfig.zegoTokenEndpoint;
    if (endpoint.isEmpty ||
        endpoint.contains('your-backend') ||
        endpoint.contains('your-server.com')) {
      throw Exception('Zego token endpoint is not configured.');
    }

    final uri = Uri.parse(endpoint);

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
            },
            body: jsonEncode({
              'roomId': resolvedRoomId,
              'userId': userId,
            }),
          )
          .timeout(const Duration(seconds: 8));
    } on SocketException {
      throw Exception(
          'Cannot reach token server (${uri.host}). Check Wi-Fi / Firewall.');
    } on TimeoutException {
      throw Exception('Token request timed out. Is the server reachable?');
    }
    if (response.statusCode != 200) {
      throw Exception(
          'Zego token request failed (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Token field missing in Zego response.');
    }
    return token;
  }

  void close() {
    _client.close();
  }
}
