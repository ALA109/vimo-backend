import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  static const String kBucket = 'videos'; // تأكد من الاسم في Supabase
  final _supabase = Supabase.instance.client;
  final _titleCtrl = TextEditingController();

  File? _videoFile;
  String? _publicUrl;
  bool _busy = false;

  Future<void> _chooseSource() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.white),
              title: const Text('تصوير من الكاميرا', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await _pickVideo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.white),
              title: const Text('اختيار من المعرض', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await _pickVideo(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 1),
    );
    if (picked != null) {
      setState(() {
        _videoFile = File(picked.path);
        _publicUrl = null;
      });
    }
  }

  Future<void> _uploadToStorage() async {
    if (_videoFile == null) {
      _snack('اختر/صوّر فيديو أولاً');
      return;
    }
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _snack('الرجاء تسجيل الدخول');
      return;
    }
    setState(() => _busy = true);
    try {
      final name = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final path = 'uploads/$name';
      await _supabase.storage.from(kBucket).upload(path, _videoFile!);
      final url = _supabase.storage.from(kBucket).getPublicUrl(path);
      setState(() => _publicUrl = url);
      _snack('تم الرفع إلى Storage. اضغط حفظ للقاعدة.');
    } catch (e) {
      _snack('خطأ رفع: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _saveToDb() async {
    if (_publicUrl == null) {
      _snack('ارفع الفيديو أولاً');
      return;
    }
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _snack('الرجاء تسجيل الدخول');
      return;
    }
    try {
      await _supabase.from('videos').insert({
        'user_id': user.id,
        'video_url': _publicUrl, // تأكد من اسم العمود حسب جدولك
        'title': _titleCtrl.text.trim().isEmpty ? 'بدون عنوان' : _titleCtrl.text.trim(),
      });
      _snack('تم حفظ الفيديو في قاعدة البيانات ✅');
      setState(() {
        _videoFile = null;
        _publicUrl = null;
        _titleCtrl.clear();
      });
    } catch (e) {
      _snack('Database Error: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('رفع فيديو'), backgroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _chooseSource,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: _videoFile == null
                    ? const Center(child: Text('اضغط لاختيار المصدر (كاميرا/معرض)', style: TextStyle(color: Colors.white54)))
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam, color: Colors.greenAccent),
                    const SizedBox(height: 10),
                    Text(_videoFile!.path.split('/').last, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'عنوان الفيديو',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _busy ? null : _uploadToStorage,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, minimumSize: const Size(double.infinity, 48)),
              icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.cloud_upload, color: Colors.black),
              label: Text(_busy ? 'جاري الرفع...' : 'رفع إلى Storage', style: const TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _publicUrl == null ? null : _saveToDb,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size(double.infinity, 48)),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('حفظ في قاعدة البيانات'),
            ),
          ],
        ),
      ),
    );
  }
}
