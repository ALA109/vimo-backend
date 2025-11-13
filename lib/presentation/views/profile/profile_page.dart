import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabase = Supabase.instance.client;
  final _nameCtrl = TextEditingController();

  bool _loading = true;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
      return;
    }

    try {
      final data = await _supabase
          .from('users')
          .select('username, avatar_url, bio')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        await _supabase.from('users').insert({
          'id': user.id,
          'username': user.email?.split('@').first ?? 'User',
          'avatar_url': null,
        });
      }

      final fresh = data ??
          await _supabase
              .from('users')
              .select('username, avatar_url, bio')
              .eq('id', user.id)
              .maybeSingle();

      if (!mounted) return;
      setState(() {
        _nameCtrl.text =
            (fresh?['username'] as String?) ?? user.email?.split('@').first ?? '';
        _avatarUrl = fresh?['avatar_url'] as String?;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Failed to load profile: $error');
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $error')),
      );
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final filePath = 'avatars/${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileData = File(file.path);

      await _supabase.storage.from('avatars').upload(filePath, fileData);

      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
      await _supabase.from('users').update({
        'avatar_url': publicUrl,
      }).eq('id', user.id);

      if (!mounted) return;
      setState(() {
        _avatarUrl = '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar updated')),
      );
    } catch (error) {
      debugPrint('Failed to update avatar: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update avatar: $error')),
      );
    }
  }

  Future<void> _updateName() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('users').update({
        'username': _nameCtrl.text.trim(),
      }).eq('id', user.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name updated')),
      );
    } catch (error) {
      debugPrint('Failed to update name: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update name: $error')),
      );
    }
  }

  Future<void> _logout() async {
    await _supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAvatar,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: _avatarUrl != null
                    ? NetworkImage(_avatarUrl!)
                    : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap the avatar to upload a new picture.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Display name',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateName,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'Save name',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24, height: 32),
            const Text(
              'More profile settings are coming soon.',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
