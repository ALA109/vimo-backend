import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// الأفضل استخدام استيراد باكيج ثابت بدل النسبي لتفادي أخطاء المسار:
import 'package:vimo/domain/models/message_model.dart';
 // غيّر your_app لاسم مشروعك

class ChatController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// قائمة الرسائل في المحادثة الحالية
  final RxList<MessageModel> messages = <MessageModel>[].obs;

  RealtimeChannel? _messagesChannel;

  /// تحميل الرسائل بين المستخدم الحالي ومستخدم آخر
  Future<void> loadMessages(String currentUserId, String otherUserId) async {
    try {
      final List<dynamic> rows = await _supabase
          .from('messages')
          .select()
      // رسائل بين الطرفين: (A→B) أو (B→A)
          .or(
        'and(sender_id.eq.$currentUserId,receiver_id.eq.$otherUserId),'
            'and(sender_id.eq.$otherUserId,receiver_id.eq.$currentUserId)',
      )
          .order('created_at', ascending: true);

      messages.assignAll(
        rows.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e, st) {
      Get.log('loadMessages error: $e\n$st');
      rethrow;
    }
  }

  /// إرسال رسالة جديدة
  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    try {
      final message = {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'text': text, // مطابق للجدول
        // بإمكانك ترك created_at للـ DEFAULT في DB، لكن لا مشكلة إن مرّرته:
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('messages').insert(message);
      // لا نضيفها محليًا هنا حتى لا تتكرر، سنعتمد على Realtime لإضافتها تلقائيًا.
    } catch (e, st) {
      Get.log('sendMessage error: $e\n$st');
      rethrow;
    }
  }

  /// الاستماع للرسائل الجديدة في الوقت الحقيقي (Supabase v2)
  void subscribeToMessages(String currentUserId, String otherUserId) {
    // ألغِ أي قناة قديمة
    _messagesChannel?.unsubscribe();

    _messagesChannel = _supabase.channel('public:messages')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        // بإمكانك إضافة فلتر لتخفيف الحمل (اختياري):
        // filter: 'or(and(sender_id.eq.$currentUserId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$currentUserId))',
        callback: (payload) {
          final msg = MessageModel.fromJson(payload.newRecord);

          final isBetweenTheTwo =
              (msg.senderId == currentUserId && msg.receiverId == otherUserId) ||
                  (msg.senderId == otherUserId && msg.receiverId == currentUserId);

          if (isBetweenTheTwo) {
            messages.add(msg);
          }
        },
      ).subscribe();
  }

  /// حذف رسالة
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase.from('messages').delete().eq('id', messageId);
      messages.removeWhere((m) => m.id == messageId);
    } catch (e, st) {
      Get.log('deleteMessage error: $e\n$st');
      rethrow;
    }
  }

  @override
  void onClose() {
    _messagesChannel?.unsubscribe();
    super.onClose();
  }
}
