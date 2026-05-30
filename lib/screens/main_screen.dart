import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import 'chatbot_screen.dart';
import 'home_screen.dart';
import 'my_bookings_screen.dart';
import 'my_page_screen.dart';

final mainScreenKey = GlobalKey<MainScreenState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _bookingTabNotifier = ValueNotifier<int>(0);

  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  void switchToBookings(int tab) {
    _bookingTabNotifier.value = tab;
    setState(() => _currentIndex = 1);
  }

  late final List<Widget> _screens = [
    const HomeScreen(),
    MyBookingsScreen(tabNotifier: _bookingTabNotifier),
    const MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        ),
        backgroundColor: AppColors.primary,
        tooltip: '고객센터 챗봇',
        child: const Icon(Icons.support_agent, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -2)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: AppStrings.get(lang, 'tabHome'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.confirmation_number_outlined),
              activeIcon: const Icon(Icons.confirmation_number),
              label: AppStrings.get(lang, 'tabMyBookings'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: AppStrings.get(lang, 'tabMyPage'),
            ),
          ],
        ),
      ),
    );
  }
}
