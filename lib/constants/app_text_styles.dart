import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 🖋️ أنماط النصوص الخاصة بتطبيق Vimo
/// منسقة لتناسب واجهة تشبه TikTok ولكن بهوية Vimo الخاصة (ألوان حيوية وخط عصري)
class AppTextStyles {
  // 🏠 العناوين الكبيرة (الصفحات الرئيسية مثل Home وProfile)
  static const TextStyle headline = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  // 🎥 عناوين الفيديو أو أسماء المستخدمين
  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // 💬 نصوص الوصف والتعليقات
  static const TextStyle body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // 🔘 نصوص الأزرار (Follow, Upload, Send, etc)
  static const TextStyle button = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // 🕶️ النصوص الصغيرة (تاريخ، عدد الإعجابات، إلخ)
  static const TextStyle small = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // 💖 عدد الإعجابات والمشاهدات
  static const TextStyle stat = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // 🔴 نصوص البث المباشر
  static const TextStyle live = TextStyle(
    color: AppColors.live,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.8,
  );

  // 🏷️ النصوص داخل النوافذ المنبثقة أو الحوارية (dialogs)
  static const TextStyle dialog = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  // 🆕 نصوص الإشعارات أو الرسائل الجديدة
  static const TextStyle notification = TextStyle(
    color: AppColors.notification,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ⚙️ النصوص في الإعدادات أو القوائم
  static const TextStyle settings = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}
