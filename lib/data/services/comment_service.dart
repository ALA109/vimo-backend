// lib/data/services/comment_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentService {
  final SupabaseClient _db = Supabase.instance.client;

  /// جلب التعليقات لفيديو معين
  Future<List<Map<String, dynamic>>> fetch(String videoId) async {
    final rows = await _db
        .from('comments')
        .select('id, text, user_id, created_at, users(username, avatar_url)')


        .eq('video_id', videoId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  /// إضافة تعليق جديد وإرجاعه مع معلومات المستخدم (RETURNING *)
  Future<Map<String, dynamic>> add({
    required String videoId,
    required String text,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    final inserted = await _db
        .from('comments')
        .insert({
          'video_id': videoId,
          'text': text,
          'user_id': user.id,
        })
        .select('id, text, user_id, created_at, users(username, avatar_url)')


        .single();

    return Map<String, dynamic>.from(inserted);
  }

  /// اشتراك لحظي بالتعليقات الجديدة على فيديو معيّن
  RealtimeChannel subscribeToVideoComments({
    required String videoId,
    required void Function(Map<String, dynamic> newRow) onInsert,
  }) {
    final channel = _db.channel('comments-$videoId').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'comments',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'video_id',
        value: videoId,
      ),
      callback: (payload) {
        final newRow = payload.newRecord;
        onInsert(Map<String, dynamic>.from(newRow));
      },
    ).subscribe();
    return channel;
  }

  void unsubscribe(RealtimeChannel channel) {
    _db.removeChannel(channel);
  }
}
