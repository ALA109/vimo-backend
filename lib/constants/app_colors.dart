import 'package:flutter/material.dart';

/// 🎨 ألوان تطبيق Vimo - منسقة لتصميم عصري يشبه TikTok
class AppColors {
  // 🔹 اللون الأساسي للتطبيق (زر المتابعة، التسجيل، إلخ)
  static const Color primary = Color(0xFFE91E63); // وردي قوي

  // 🔹 اللون الثانوي (يستخدم في الظلال والأزرار الثانوية)
  static const Color secondary = Color(0xFF9C27B0); // بنفسجي أنيق

  // 🔹 لون الخلفية الأساسية (صفحة الـ Home، الملف الشخصي، إلخ)
  static const Color background = Color(0xFF000000); // أسود نقي

  // 🔹 لون النصوص الأساسية
  static const Color textPrimary = Color(0xFFFFFFFF); // أبيض

  // 🔹 لون النصوص الثانوية
  static const Color textSecondary = Color(0xFFB0B0B0); // رمادي ناعم

  // 🔹 لون الخط الفاصل / الحدود
  static const Color border = Color(0xFF2C2C2C);

  // 🔹 لون الأيقونات
  static const Color icon = Color(0xFFDADADA);

  // 🔹 لون زر الإعجاب بعد التفاعل
  static const Color like = Color(0xFFFF1744); // أحمر ساطع

  // 🔹 لون أزرار البث المباشر
  static const Color live = Color(0xFFFF4081); // وردي متدرج

  // 🔹 لون الرسائل والإشعارات الجديدة
  static const Color notification = Color(0xFF00BCD4); // سماوي زاهي

  // 🔹 لون الخلفية في الوضع الفاتح (لاحقًا إن تم دعم الوضع المزدوج)
  static const Color lightBackground = Color(0xFFF9F9F9);

  // 🔹 تدرج الألوان للزر الكبير (زر الفيديو في المنتصف)
  static const LinearGradient recordButtonGradient = LinearGradient(
    colors: [Color(0xFFFF1744), Color(0xFFE040FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
