import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/card_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/language_provider.dart';
import 'screens/main_screen.dart';
import 'services/sleep_mode_task.dart';
import 'services/time_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    FlutterForegroundTask.initCommunicationPort();
    initForegroundTask();
  }
  await dotenv.load(fileName: '.env');
  await TimeService.init();
  runApp(const BusApp());
}

class BusApp extends StatelessWidget {
  const BusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()..init()),
        ChangeNotifierProvider(create: (_) => CardProvider()..init()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (ctx, langProvider, _) => MaterialApp(
          title: '버스티켓',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          locale: Locale(langProvider.langCode),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko', 'KR'),
            Locale('en', 'US'),
            Locale('zh'),
            Locale('ja'),
          ],
          scrollBehavior: const _NoOverscroll(),
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _NoOverscroll extends ScrollBehavior {
  const _NoOverscroll();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  String? _loadedUserId;
  late final AuthProvider _auth;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthProvider>();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (_auth.isInitializing) return;
    final userId = _auth.currentUser?.id;

    if (userId != null && userId != _loadedUserId) {
      _loadedUserId = userId;
      // 세 프로바이더를 병렬 로드 — 각각 notifyListeners 하지만 UI 는 MainScreen 이 이미 표시된 상태
      Future.wait([
        context.read<BookingProvider>().loadForUser(userId),
        context.read<CardProvider>().loadForUser(userId),
        context.read<FavoriteProvider>().loadForUser(userId),
      ]);
    } else if (userId == null && _loadedUserId != null) {
      _loadedUserId = null;
      context.read<BookingProvider>().clearUser();
      context.read<CardProvider>().clearUser();
      context.read<FavoriteProvider>().clearUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: auth.isInitializing
          ? const _SplashView(key: ValueKey('splash'))
          : MainScreen(key: mainScreenKey),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_bus_rounded, size: 72, color: Colors.white),
            const SizedBox(height: 12),
            const Text(
              '버스티켓',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
