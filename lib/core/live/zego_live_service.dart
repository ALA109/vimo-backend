// lib/core/live/zego_live_service.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

import 'package:vimo/constants/app_config.dart';
import 'package:vimo/core/live/zego_live_config.dart';

class ZegoLiveService {
  // ======== �������� �����S�'�� ���"�.������'�� ========

  // A) �����^�� �������. (�"�" ������������): appID + appSign �.�� �"�^�� ZEGO
  static int get appID => AppConfig.zegoAppId; // ���� ���'�. APP_ID
  static String get appSign =>
      AppConfig.zegoAppSign; // ���� APP_SIGN ���� �������� �Ν��� ���"�����S�'��

  // B) ���������. ���^��� ZEGO (�.��������� �"�"���ŝ�����)
  static String get tokenServer =>
      AppConfig.zegoTokenEndpoint; // �����'�" IP/���"���^�.�S��

  static Future<String> fetchToken(String userID) async {
    if (tokenServer.isEmpty) {
      throw Exception('�������� ���"�� ZEGO token endpoint ���������.');
    }

    final uri = Uri.parse(tokenServer).replace(queryParameters: {
      'userID': userID,
    });
    final response =
        await http.get(uri).timeout(const Duration(seconds: 6));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'] as String;
    } else {
      throw Exception('�������� ���"�� ZEGO token (${response.statusCode})');
    }
  }

  /// ����� ���� ��.���S�?
  static Future<void> goLive({
    required BuildContext context,
    required String userID,
    required String userName,
    required String liveId, // �.�� Zego �S���.�% liveId �"�����^�ŝ� ���"�����?�
    bool useTokenServer = false,
  }) async {
    String? token;
    if (useTokenServer) {
      token = await fetchToken(userID);
    }

    final config = buildHostConfig(localUserId: userID);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ZegoUIKitPrebuiltLiveStreaming(
        appID: appID,
        appSign: useTokenServer ? '' : appSign,
        token: useTokenServer ? token! : '', // �^����� �?�'�� �.�� ���"�������S��
        userID: userID,
        userName: userName,
        liveID: liveId, // �����./�.�����'? ���"����
        config: config,
      ),
    ));
  }

  /// ���ŝ��. ��.����Ν�
  static Future<void> joinLive({
    required BuildContext context,
    required String userID,
    required String userName,
    required String liveId,
    bool useTokenServer = false,
  }) async {
    String? token;
    if (useTokenServer) {
      token = await fetchToken(userID);
    }

    final config = buildAudienceConfig(localUserId: userID);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ZegoUIKitPrebuiltLiveStreaming(
        appID: appID,
        appSign: useTokenServer ? '' : appSign,
        token: useTokenServer ? token! : '',
        userID: userID,
        userName: userName,
        liveID: liveId,
        config: config,
      ),
    ));
  }
}
