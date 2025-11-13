import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../data/services/video_service.dart';
import '../../../domain/models/video_model.dart';
import '../../../core/utils/count_format.dart';
import 'widgets/comments_sheet.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _service = VideoService();
  final _pageController = PageController();
  final _players = <int, VideoPlayerController>{};
  final _videos = <Video>[];
  int _index = 0;
  bool _loading = true;
  bool _muted = true;
  bool _showHeart = false;
  Timer? _heartTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _service.fetchFeed();
      if (!mounted) return;
      setState(() {
        _videos
          ..clear()
          ..addAll(list);
        _loading = false;
      });
      if (_videos.isNotEmpty) {
        await _prepare(_index);
        _play(_index);
        _preload(_index + 1);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _prepare(int i) async {
    if (i < 0 || i >= _videos.length) return;
    if (_players[i] != null) return;
    final url = _videos[i].url;
    if (url.isEmpty) return; // لا تحاول تشغيل رابط فارغ
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    _players[i] = c;
    await c.initialize();
    await c.setLooping(true);
    await c.setVolume(_muted ? 0 : 1);
  }

  void _preload(int i) {
    unawaited(_prepare(i));
  }

  void _play(int i) {
    for (final entry in _players.entries) {
      if (entry.key == i) {
        entry.value.play();
      } else {
        entry.value.pause();
      }
    }
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    final c = _players[_index];
    c?.setVolume(_muted ? 0 : 1);
  }

  void _onPageChanged(int i) async {
    setState(() => _index = i);
    await _prepare(i);
    _play(i);
    _preload(i + 1);
    // تفريغ الكنترولرز البعيدة لتوفير الذاكرة
    _disposeIndex(i - 2);
    _disposeIndex(i + 2);
  }

  Future<void> _toggleLike(Video v) async {
    setState(() {
      _showHeart = true;
    });
    _heartTimer?.cancel();
    _heartTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showHeart = false);
    });
    try {
      final liked = await _service.toggleLike(v.id);
      setState(() {
        v.isLiked = liked;
        v.likes += liked ? 1 : -1;
      });
    } catch (e) {
      debugPrint('❌ Error toggling like: $e');
    }
  }

  void _disposeIndex(int i) {
    final c = _players.remove(i);
    c?.dispose();
  }

  Future<void> _onDoubleTapLike() async {
    setState(() => _showHeart = true);
    _heartTimer?.cancel();
    _heartTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showHeart = false);
    });

    final v = _videos[_index];
    setState(() => v.likes += 1);
    try {
      final liked = await _service.toggleLike(v.id);
      setState(() => v.isLiked = liked);
      if (!liked) {
        setState(() => v.likes = (v.likes - 2).clamp(0, 1 << 31));
      }
    } catch (_) {
      setState(() => v.likes = (v.likes - 1).clamp(0, 1 << 31));
    }
  }

  // ✅ فتح ورقة التعليقات
  Future<void> _openComments(String videoId) async {
    final c = _players[_index];
    c?.pause();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(videoId: videoId),
    );
    c?.play();
  }

  @override
  void dispose() {
    _heartTimer?.cancel();
    for (final c in _players.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_videos.isEmpty) {
      return const Center(child: Text('No videos', style: TextStyle(color: Colors.white)));
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: _onPageChanged,
          itemCount: _videos.length,
          itemBuilder: (context, i) {
            final v = _videos[i];
            final c = _players[i];
            return GestureDetector(
              onDoubleTap: _onDoubleTapLike,
              onTap: _toggleMute,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: c != null && c.value.isInitialized
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: c.value.size.width,
                              height: c.value.size.height,
                              child: VideoPlayer(c),
                            ),
                          )
                        : const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                  // شريط علوي (شكلي فقط)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Following',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                        SizedBox(width: 16),
                        Text('For You',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // المعلومات أسفل الفيديو + عمود الأزرار يمين
                  Positioned(
                    left: 12,
                    right: 80,
                    bottom: 24,
                    child: _VideoMeta(v: v),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 24,
                    child: _RightRail(
                      likes: v.likes,
                      comments: v.comments,
                      shares: v.shares,
                      isLiked: v.isLiked,
                      onLike: () => _toggleLike(v),
                      onComment: () => _openComments(v.id),
                      onShare: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share TODO')),
                        );
                      },
                    ),
                  ),
                  // مؤشر الصوت
                  Positioned(
                    top: 50,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _muted ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(_muted ? 'Muted' : 'Sound on',
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  if (_showHeart) const _HeartOverlay(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _VideoMeta extends StatelessWidget {
  final Video v;
  const _VideoMeta({required this.v});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('@${v.userId}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (v.caption != null && v.caption!.isNotEmpty)
          Text(v.caption!, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        if (v.songName != null && v.songName!.isNotEmpty)
          Row(
            children: [
              const Icon(Icons.music_note, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child:
                    Text(v.songName!, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
      ],
    );
  }
}

class _RightRail extends StatelessWidget {
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const _RightRail({
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Action(icon: Icons.account_circle, label: 'Profile', onTap: () {}),
        const SizedBox(height: 16),
        // ❤️ زر الإعجاب
        _LikeAction(
          count: likes,
          isLiked: isLiked,
          onTap: onLike,
        ),
        const SizedBox(height: 16),
        _Action(icon: Icons.comment, label: formatCount(comments), onTap: onComment),
        const SizedBox(height: 16),
        _Action(icon: Icons.share, label: formatCount(shares), onTap: onShare),
      ],
    );
  }
}

class _LikeAction extends StatefulWidget {
  final int count;
  final bool isLiked;
  final VoidCallback onTap;

  const _LikeAction({
    required this.count,
    required this.isLiked,
    required this.onTap,
  });

  @override
  State<_LikeAction> createState() => _LikeActionState();
}

class _LikeActionState extends State<_LikeAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 1.0,
      upperBound: 1.4,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      child: Column(
        children: [
          ScaleTransition(
            scale: _controller,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 150),
              scale: widget.isLiked ? 1.2 : 1.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isLiked ? 1.0 : 0.8,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: widget.isLiked ? Colors.red : Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatCount(widget.count),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _HeartOverlay extends StatefulWidget {
  const _HeartOverlay();

  @override
  State<_HeartOverlay> createState() => _HeartOverlayState();
}

class _HeartOverlayState extends State<_HeartOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _opacity = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 140, // حجم القلب الكبير
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
