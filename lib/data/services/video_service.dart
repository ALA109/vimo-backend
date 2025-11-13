import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/video_model.dart';

class VideoService {
  final _supabase = Supabase.instance.client;

  /// 🔹 جلب قائمة الفيديوهات لعرضها في الـ Feed
  Future<List<Video>> fetchFeed() async {
    final response = await _supabase
        .from('videos')
        .select('id, user_id, video_url, title, description, likes_count, comments_count, shares_count')
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => Video.fromMap(data as Map<String, dynamic>))
        .toList();
  }

  /// 🔹 قلب حالة الإعجاب (Like/Unlike) للفيديو
  Future<bool> toggleLike(String videoId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    // هل هناك إعجاب موجود مسبقًا؟
    final existing = await _supabase
        .from('likes')
        .select('id')
        .eq('video_id', videoId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing == null) {
      await _supabase.from('likes').insert({
        'video_id': videoId,
        'user_id': user.id,
      });
      return true; // تمت إضافة الإعجاب
    } else {
      await _supabase.from('likes').delete().eq('id', existing['id']);
      return false; // تم إلغاء الإعجاب
    }
  }
}
