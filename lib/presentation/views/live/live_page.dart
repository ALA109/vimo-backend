import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

import 'audience_page.dart';
import 'host_page.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Streaming'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose how you want to join the live room:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.videocam, size: 28),
              label: const Text('Go live as host'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              onPressed: () {
                final minimizeController =
                    ZegoUIKitPrebuiltLiveStreamingController().minimize;
                if (minimizeController.isMinimizing) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HostPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.remove_red_eye, size: 28),
              label: const Text('Join as viewer'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                final minimizeController =
                    ZegoUIKitPrebuiltLiveStreamingController().minimize;
                if (minimizeController.isMinimizing) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AudiencePage()),
                );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Ensure your ZEGOCLOUD credentials are configured before going live. '
              'Everyone in the room sees gifts in real time.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
