import 'package:flutter/material.dart';

import '../../../../../data/services/comment_service.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({super.key, required this.videoId});

  final String videoId;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _service = CommentService();
  final _ctrl = TextEditingController();
  final _comments = <Map<String, dynamic>>[];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await _service.fetch(widget.videoId);
      if (!mounted) return;
      setState(() {
        _comments
          ..clear()
          ..addAll(rows);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load comments: $error')),
      );
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    try {
      final row = await _service.add(videoId: widget.videoId, text: text);
      if (!mounted) return;
      setState(() {
        _comments.insert(0, row);
        _ctrl.clear();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send comment: $error')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        color: Colors.black,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Comments',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.greenAccent,
                      ),
                    )
                  : _comments.isEmpty
                      ? const Center(
                          child: Text(
                            'No comments yet.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.separated(
                          reverse: false,
                          itemCount: _comments.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: Colors.white10),
                          itemBuilder: (context, index) {
                            final row = _comments[index];
                            final user =
                                row['users'] as Map<String, dynamic>? ?? {};
                            final name = user['username'] as String? ?? 'User';
                            final avatarUrl = user['avatar_url'] as String?;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: avatarUrl != null
                                    ? NetworkImage(avatarUrl)
                                    : const AssetImage(
                                        'assets/default_avatar.png',
                                      ) as ImageProvider,
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                row['text'] as String? ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sending ? null : _send,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.greenAccent,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.greenAccent),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
