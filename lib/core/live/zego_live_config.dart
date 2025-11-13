import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

/// Builds the default host configuration matching the official co-host sample.
ZegoUIKitPrebuiltLiveStreamingConfig buildHostConfig({
  required String localUserId,
}) {
  final config = ZegoUIKitPrebuiltLiveStreamingConfig.host(
    plugins: [ZegoUIKitSignalingPlugin()],
  );
  _applySharedConfig(config: config, localUserId: localUserId);
  config.audioVideoView.foregroundBuilder =
      (context, size, user, extraInfo) => _hostAudioVideoViewForegroundBuilder(
            context,
            size,
            user,
            extraInfo,
            localUserId,
          );
  return config;
}

/// Builds the default audience configuration matching the official co-host sample.
ZegoUIKitPrebuiltLiveStreamingConfig buildAudienceConfig({
  required String localUserId,
}) {
  final config = ZegoUIKitPrebuiltLiveStreamingConfig.audience(
    plugins: [ZegoUIKitSignalingPlugin()],
  );
  _applySharedConfig(config: config, localUserId: localUserId);
  return config;
}

void _applySharedConfig({
  required ZegoUIKitPrebuiltLiveStreamingConfig config,
  required String localUserId,
}) {
  config.audioVideoView.useVideoViewAspectFill = true;
  config.topMenuBar.buttons = [
    ZegoLiveStreamingMenuBarButtonName.minimizingButton,
  ];
  config.avatarBuilder = _customAvatarBuilder;
  config.inRoomMessage.attributes =
      () => _userLevelsAttributes(localUserId: localUserId);
  config.inRoomMessage.avatarLeadingBuilder = _userLevelBuilder;
}

Widget _customAvatarBuilder(
  BuildContext context,
  Size size,
  ZegoUIKitUser? user,
  Map<String, dynamic> extraInfo,
) {
  if (user == null) {
    return const SizedBox.shrink();
  }

  return Stack(
    children: [
      CachedNetworkImage(
        imageUrl: 'https://robohash.org/${user.id}.png',
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return CircularProgressIndicator(value: downloadProgress.progress);
        },
        errorWidget: (context, url, error) {
          return ZegoAvatar(user: user, avatarSize: size);
        },
      ),
    ],
  );
}

Map<String, String> _userLevelsAttributes({required String localUserId}) {
  return {
    'lv': Random(localUserId.hashCode).nextInt(100).toString(),
  };
}

Widget _userLevelBuilder(
  BuildContext context,
  ZegoInRoomMessage message,
  Map<String, dynamic> extraInfo,
) {
  return Container(
    alignment: Alignment.center,
    height: 15,
    width: 30,
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.purple.shade300, Colors.purple.shade400],
      ),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
    ),
    child: Text(
      'LV ${message.attributes['lv']}',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10),
    ),
  );
}

Widget _hostAudioVideoViewForegroundBuilder(
  BuildContext context,
  Size size,
  ZegoUIKitUser? user,
  Map<String, dynamic> extraInfo,
  String localUserId,
) {
  if (user == null || user.id == localUserId) {
    return const SizedBox.shrink();
  }

  Widget toolbarButton({
    required String assetName,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size.width * 0.4,
        height: size.width * 0.4,
        child: Image.asset(
          assetName,
          package: 'zego_uikit_prebuilt_live_streaming',
        ),
      ),
    );
  }

  return Positioned(
    top: 15,
    right: 0,
    child: Row(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: ZegoUIKit().getCameraStateNotifier(user.id),
          builder: (context, isCameraEnabled, _) {
            return toolbarButton(
              assetName: isCameraEnabled
                  ? 'assets/icons/toolbar_camera_normal.png'
                  : 'assets/icons/toolbar_camera_off.png',
              onTap: () {
                ZegoUIKit().turnCameraOn(!isCameraEnabled, userID: user.id);
              },
            );
          },
        ),
        SizedBox(width: size.width * 0.1),
        ValueListenableBuilder<bool>(
          valueListenable: ZegoUIKit().getMicrophoneStateNotifier(user.id),
          builder: (context, isMicrophoneEnabled, _) {
            return toolbarButton(
              assetName: isMicrophoneEnabled
                  ? 'assets/icons/toolbar_mic_normal.png'
                  : 'assets/icons/toolbar_mic_off.png',
              onTap: () {
                ZegoUIKit().turnMicrophoneOn(
                  !isMicrophoneEnabled,
                  userID: user.id,
                  muteMode: true,
                );
              },
            );
          },
        ),
      ],
    ),
  );
}
