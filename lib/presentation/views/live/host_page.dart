import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:vimo/constants/app_config.dart';
import 'package:vimo/data/services/live_token_service.dart';
import 'package:vimo/core/live/zego_live_config.dart';
import 'package:vimo/presentation/views/live/gift_shop_sheet.dart';
import 'package:vimo/presentation/views/live/live_overlay.dart';

import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class HostPage extends StatefulWidget {
  const HostPage({super.key});

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  final _giftStreamController = StreamController<String>.broadcast();
  final LiveTokenService _tokenService = LiveTokenService();
  final String _liveId = '${AppConfig.liveRoomPrefix}primary';

  StreamSubscription? _commandSubscription;
  bool _isStarting = false;
  bool _isLive = false;
  String? _userId;
  String? _token;

  @override
  void dispose() {
    _commandSubscription?.cancel();
    _giftStreamController.close();
    _tokenService.close();
    super.dispose();
  }

  Future<void> _startLive() async {
    if (_isStarting) return;

    setState(() {
      _isStarting = true;
    });

    if (AppConfig.zegoAppId <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please configure a valid ZEGO AppID.')),
        );
      }
      setState(() => _isStarting = false);
      return;
    }

    final userId = 'host_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final token = await _tokenService.fetchToken(
        roomId: _liveId,
        userId: userId,
      );

      _userId = userId;
      _token = token;
      _isLive = true;
      _listenForCommands();

      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start live: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  void _listenForCommands() {
    _commandSubscription?.cancel();
    _commandSubscription = ZegoUIKitPrebuiltLiveStreamingController()
        .room
        .commandReceivedStream()
        .listen((event) {
      for (final message in event.messages) {
        final payload = utf8.decode(message.message);
        if (payload.isNotEmpty) {
          _giftStreamController.add(payload);
        }
      }
    });
  }

  Future<void> _renewToken() async {
    final currentUserId = _userId;
    if (currentUserId == null) return;

    try {
      final nextToken = await _tokenService.fetchToken(
        roomId: _liveId,
        userId: currentUserId,
      );
      await ZegoUIKitPrebuiltLiveStreamingController().room.renewToken(nextToken);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to renew token: $error')),
      );
    }
  }

  Future<void> _sendGift(GiftItem gift) async {
    final command =
        Uint8List.fromList(utf8.encode(gift.id)); // broadcast gift id as UTF-8
    final success = await ZegoUIKitPrebuiltLiveStreamingController()
        .room
        .sendCommand(
      roomID: _liveId,
      command: command,
        );

    if (!success) {
      throw Exception('Unable to send gift command.');
    }

    _giftStreamController.add(gift.id);
  }

  void _handleLiveEnded() {
    _commandSubscription?.cancel();
    _commandSubscription = null;

    if (mounted) {
      setState(() {
        _isLive = false;
        _token = null;
        _userId = null;
      });
    }
  }

  ZegoUIKitPrebuiltLiveStreamingEvents _buildEvents() {
    return ZegoUIKitPrebuiltLiveStreamingEvents(
      onEnded: (event, defaultAction) {
        defaultAction();
        _handleLiveEnded();
      },
      room: ZegoLiveStreamingRoomEvents(
        onTokenExpired: (remainSeconds) {
          _renewToken();
          return null;
        },
      ),
      onError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Live error: ${error.code}')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _isLive ? null : AppBar(title: const Text('Go Live (Host)')),
      body: _isLive
          ? Stack(
              children: [
                ZegoUIKitPrebuiltLiveStreaming(
                  appID: AppConfig.zegoAppId,
                  userID: _userId!,
                  userName: 'Host',
                  liveID: _liveId,
                  token: _token ?? '',
                  config: buildHostConfig(localUserId: _userId!),
                  events: _buildEvents(),
                ),
                GiftOverlay(giftStream: _giftStreamController.stream),
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.card_giftcard),
                    label: const Text('Send gift'),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => GiftShopSheet(
                        gifts: sampleGifts,
                        initialCoins: 500,
                        onSend: _sendGift,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Start broadcasting with ZEGOCLOUD Live Streaming.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isStarting ? null : _startLive,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        child: Text(_isStarting ? 'Connecting...' : 'Start Live'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
