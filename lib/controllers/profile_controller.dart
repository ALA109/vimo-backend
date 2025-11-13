// lib/controllers/profile_controller.dart (أو Service مخصص للبروفايل)
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController {
  final _db = Supabase.instance.client;

  Future<String> uploadAvatar(File file) async {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final path = 'avatars/${user.id}-${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _db.storage.from('avatars').upload(
      path,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    // URL عام
    final publicUrl = _db.storage.from('avatars').getPublicUrl(path);

    // تحديث جدول users
    await _db.from('users').update({
      'avatar_url': publicUrl,
    }).eq('id', user.id);

    return publicUrl;
  }
}
