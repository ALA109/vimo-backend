import 'package:flutter/material.dart';

class GiftItem {
  GiftItem({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
  });

  final String id;
  final String name;
  final int price;
  final String emoji;
}

final sampleGifts = <GiftItem>[
  GiftItem(id: 'rose', name: 'Rose', price: 50, emoji: '🌹'),
  GiftItem(id: 'heart', name: 'Heart', price: 30, emoji: '❤️'),
  GiftItem(id: 'star', name: 'Star', price: 80, emoji: '⭐'),
  GiftItem(id: 'rocket', name: 'Rocket', price: 200, emoji: '🚀'),
];

typedef OnSendGift = Future<void> Function(GiftItem gift);

class GiftShopSheet extends StatefulWidget {
  const GiftShopSheet({
    super.key,
    required this.gifts,
    required this.initialCoins,
    required this.onSend,
  });

  final List<GiftItem> gifts;
  final int initialCoins;
  final OnSendGift onSend;

  @override
  State<GiftShopSheet> createState() => _GiftShopSheetState();
}

class _GiftShopSheetState extends State<GiftShopSheet> {
  late int _coins;
  GiftItem? _selected;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _coins = widget.initialCoins;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Available gifts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text('Coins: $_coins'),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: widget.gifts.length,
              itemBuilder: (_, i) {
                final gift = widget.gifts[i];
                final isSelected = _selected?.id == gift.id;
                return GestureDetector(
                  onTap: () => setState(() => _selected = gift),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.pinkAccent : Colors.white24,
                        width: 2,
                      ),
                      color: isSelected
                          ? Colors.pinkAccent.withValues(alpha: 0.1)
                          : Colors.white10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(gift.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(
                          gift.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text('${gift.price} coins'),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.card_giftcard),
                label: Text(_sending ? 'Sending...' : 'Send gift'),
                onPressed: _sending || _selected == null
                    ? null
                    : () async {
                        if (_coins < _selected!.price) {
                          setState(
                            () => _error = 'You do not have enough coins.',
                          );
                          return;
                        }

                        setState(() {
                          _sending = true;
                          _error = null;
                        });

                        try {
                          await widget.onSend(_selected!);
                          if (!mounted) return;
                          setState(() {
                            _coins -= _selected!.price;
                          });
                          if (!mounted) return;
                          Navigator.pop(context);
                        } catch (error) {
                          if (!mounted) return;
                          setState(() => _error = 'Failed to send gift: $error');
                        } finally {
                          if (!mounted) return;
                          setState(() => _sending = false);
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
