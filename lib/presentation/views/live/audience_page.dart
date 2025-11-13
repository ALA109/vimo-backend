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

class AudiencePage extends StatefulWidget {
  const AudiencePage({super.key});

  @override
  State<AudiencePage> createState() => _AudiencePageState();
}

class _AudiencePageState extends State<AudiencePage> {
  final _giftStreamController = StreamController<String>.broadcast();
  final LiveTokenService _tokenService = LiveTokenService();
  final String _liveId = '${AppConfig.liveRoomPrefix}primary';

  StreamSubscription? _commandSubscription;
  bool _isJoining = false;
  bool _isLive = false;
  bool _canSendGift = false;
  String? _userId;
  String? _token;

  @override
  void dispose() {
    _commandSubscription?.cancel();
    _giftStreamController.close();
    _tokenService.close();
    super.dispose();
  }

  Future<void> _joinStream() async {
    if (_isJoining) return;

    setState(() {
      _isJoining = true;
    });

    if (AppConfig.zegoAppId <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please configure a valid ZEGO AppID.')),
        );
      }
      setState(() => _isJoining = false);
      return;
    }

    final userId = 'viewer_${DateTime.now().millisecondsSinceEpoch}';

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
          SnackBar(content: Text('Failed to join live: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
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
    if (!_canSendGift) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please wait until the stream connects.')),
        );
      }
      return;
    }

    final command = Uint8List.fromList(utf8.encode(gift.id));
    final success = await ZegoUIKitPrebuiltLiveStreamingController()
        .room
        .sendCommand(
          roomID: _liveId,
          command: command,
        );

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to send gift right now.')),
        );
      }
      return;
    }

    _giftStreamController.add(gift.id);
  }

  void _handleLiveEnded() {
    _commandSubscription?.cancel();
    _commandSubscription = null;

    if (mounted) {
      setState(() {
        _isLive = false;
        _canSendGift = false;
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
      onStateUpdated: (state) {
        if (!mounted) return;
        setState(() => _canSendGift = state == ZegoLiveStreamingState.living);
      },
      audioVideo: ZegoLiveStreamingAudioVideoEvents(
        onCameraTurnOnByOthersConfirmation: (context) {
          return _onTurnOnAudienceDeviceConfirmation(
            context,
            isCameraOrMicrophone: true,
          );
        },
        onMicrophoneTurnOnByOthersConfirmation: (context) {
          return _onTurnOnAudienceDeviceConfirmation(
            context,
            isCameraOrMicrophone: false,
          );
        },
      ),
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

  Future<bool> _onTurnOnAudienceDeviceConfirmation(
    BuildContext context, {
    required bool isCameraOrMicrophone,
  }) async {
    const baseStyle = TextStyle(
      fontSize: 10,
      color: Colors.white70,
    );
    const buttonStyle = TextStyle(
      fontSize: 10,
      color: Colors.black,
    );
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.blue[900]!.withOpacity(0.9),
              title: Text(
                'You have a request to turn on your '
                '${isCameraOrMicrophone ? "camera" : "microphone"}',
                style: baseStyle,
              ),
              content: Text(
                'Do you agree to turn on the '
                '${isCameraOrMicrophone ? "camera" : "microphone"}?',
                style: baseStyle,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel', style: buttonStyle),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('OK', style: buttonStyle),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _isLive ? null : AppBar(title: const Text('Watch Live')),
      body: _isLive
          ? Stack(
              children: [
                ZegoUIKitPrebuiltLiveStreaming(
                  appID: AppConfig.zegoAppId,
                  userID: _userId!,
                  userName: 'Viewer',
                  liveID: _liveId,
                  token: _token ?? '',
                  config: buildAudienceConfig(localUserId: _userId!),
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
                        initialCoins: 200,
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
                      'Join the live stream powered by ZEGOCLOUD.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isJoining ? null : _joinStream,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        child: Text(_isJoining ? 'Connecting...' : 'Watch Live'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
