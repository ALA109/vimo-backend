import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GiftOverlay extends StatefulWidget {
  const GiftOverlay({super.key, required this.giftStream});

  final Stream<String> giftStream;

  @override
  State<GiftOverlay> createState() => _GiftOverlayState();
}

class _GiftOverlayState extends State<GiftOverlay> {
  StreamSubscription<String>? _subscription;
  String? _currentGift;

  @override
  void initState() {
    super.initState();
    _subscription = widget.giftStream.listen((gift) {
      setState(() => _currentGift = gift);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _currentGift = null);
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _currentGift == null ? 0 : 1,
        duration: const Duration(milliseconds: 250),
        child: _currentGift == null
            ? const SizedBox.shrink()
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      _giftAnim(_currentGift!),
                      height: 160,
                      repeat: false,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gift: $_currentGift!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 8, color: Colors.pink)],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _giftAnim(String gift) {
    switch (gift) {
      case 'rose':
        return 'assets/lottie/rose.json';
      case 'heart':
        return 'assets/lottie/heart.json';
      case 'star':
        return 'assets/lottie/star.json';
      default:
        return 'assets/lottie/confetti.json';
    }
  }
}
