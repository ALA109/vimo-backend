import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

import 'core/constants/app_constants.dart';
import 'presentation/navigation/bottom_nav.dart';
import 'presentation/views/auth/login_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🧩 تهيئة Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    debug: true,
  );

  final navigatorKey = GlobalKey<NavigatorState>();
  await ZegoUIKit().initLog();

  runApp(VimoApp(navigatorKey: navigatorKey));
}

class VimoApp extends StatelessWidget {
  const VimoApp({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vimo',
      navigatorKey: navigatorKey,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final body = child ?? const SizedBox.shrink();
        return Stack(
          children: [
            body,
            ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage(
              contextQuery: () =>
                  navigatorKey.currentState?.context ?? context,
            ),
          ],
        );
      },
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: ZegoUIKitPrebuiltLiveStreamingMiniPopScope(
        child: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _ensuring = false;

  /// ✅ ينشئ صف المستخدم في جدول users عند تسجيل الدخول لأول مرة
  Future<void> _ensureUserRow(User user) async {
    if (_ensuring) return;
    _ensuring = true;

    final supabase = Supabase.instance.client;
    try {
      final existing = await supabase
          .from('users')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existing == null) {
        await supabase.from('users').insert({
          'id': user.id,
          'username': user.email?.split('@').first ?? 'User',
          'avatar_url': null,
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error ensuring user row: $e');
    } finally {
      _ensuring = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession ?? snapshot.data?.session;
        final user = session?.user;

        // 🧱 إذا لم يكن هناك جلسة → عرض صفحة تسجيل الدخول
        if (user == null) {
          return const LoginPage();
        }

        // ✅ تأكد من وجود صف للمستخدم في قاعدة البيانات
        _ensureUserRow(user);

        // ✅ إذا المستخدم مسجّل → اذهب إلى الواجهة الرئيسية
        return const BottomNav();
      },
    );
  }
}
