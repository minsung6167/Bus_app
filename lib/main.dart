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
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    FlutterForegroundTask.initCommunicationPort();
    initForegroundTask();
  }
  await dotenv.load(fileName: '.env');
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
      context.read<BookingProvider>().loadForUser(userId);
      context.read<CardProvider>().loadForUser(userId);
      context.read<FavoriteProvider>().loadForUser(userId);
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
    if (auth.isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return MainScreen(key: mainScreenKey);
  }
}
