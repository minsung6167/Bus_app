import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'coupon_screen.dart';
import 'my_info_screen.dart';
import 'event_screen.dart';
import 'notice_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  void _showLanguagePicker(BuildContext context, LanguageProvider langProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(AppStrings.get(langProvider.langCode, 'selectLanguage'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...LanguageProvider.languages.map((lang) {
              final isSelected = langProvider.langCode == lang['code'];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
                title: Text(lang['label']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  )),
                trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                onTap: () { langProvider.setLanguage(lang['code']!); Navigator.pop(context); },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.get(lang, 'logout')),
        content: Text(AppStrings.get(lang, 'logoutConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get(lang, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: Text(AppStrings.get(lang, 'logout'),
              style: const TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    final langProvider = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final bookings = context.watch<BookingProvider>().bookings;
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline, size: 80, color: AppColors.textHint),
                const SizedBox(height: 20),
                Text(
                  AppStrings.get(lang, 'guestTitle'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.get(lang, 'guestDesc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: Text(AppStrings.get(lang, 'goToLogin')),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final upcoming = bookings.where((b) => b.isUpcoming).length;
    final past = bookings.where((b) => !b.isUpcoming).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 헤더
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 아바타
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                      ),
                      child: Center(
                        child: Text(initials,
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(user.email,
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 예매 통계 카드
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(child: _StatItem(
                              icon: Icons.confirmation_number_outlined,
                              label: AppStrings.get(lang, 'upcomingTrips'),
                              value: '$upcoming',
                              color: AppColors.primary,
                            )),
                            Container(width: 1, height: 40, color: AppColors.divider),
                            Expanded(child: _StatItem(
                              icon: Icons.history_outlined,
                              label: AppStrings.get(lang, 'pastTrips'),
                              value: '$past',
                              color: AppColors.textSecondary,
                            )),
                            Container(width: 1, height: 40, color: AppColors.divider),
                            Expanded(child: _StatItem(
                              icon: Icons.receipt_long_outlined,
                              label: AppStrings.get(lang, 'totalBookings'),
                              value: '${bookings.length}',
                              color: const Color(0xFF7C3AED),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 설정 메뉴
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      children: [
                        _MenuCard(children: [
                          _MenuTile(
                            icon: Icons.manage_accounts_outlined,
                            label: AppStrings.get(lang, 'myInfo'),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const MyInfoScreen()),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _MenuCard(children: [
                          _MenuTile(
                            icon: Icons.confirmation_number_outlined,
                            label: AppStrings.get(lang, 'coupons'),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CouponScreen()),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.divider, indent: 52),
                          _MenuTile(
                            icon: Icons.campaign_outlined,
                            label: AppStrings.get(lang, 'notices'),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const NoticeScreen()),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.divider, indent: 52),
                          _MenuTile(
                            icon: Icons.local_activity_outlined,
                            label: AppStrings.get(lang, 'events'),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const EventScreen()),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _MenuCard(children: [
                          _MenuTile(
                            icon: Icons.language_outlined,
                            label: AppStrings.get(lang, 'selectLanguage'),
                            trailing: Text(
                              '${LanguageProvider.languages.firstWhere((l) => l['code'] == lang)['flag']} ${LanguageProvider.languages.firstWhere((l) => l['code'] == lang)['label']}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            onTap: () => _showLanguagePicker(context, langProvider),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _MenuCard(children: [
                          _MenuTile(
                            icon: Icons.logout,
                            label: AppStrings.get(lang, 'logout'),
                            iconColor: const Color(0xFFE53935),
                            labelColor: const Color(0xFFE53935),
                            onTap: () => _confirmLogout(context, lang),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint), textAlign: TextAlign.center),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MenuItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textHint),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor = AppColors.textHint,
    this.labelColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, size: 20, color: iconColor),
      title: Text(label, style: TextStyle(fontSize: 14, color: labelColor, fontWeight: FontWeight.w500)),
      trailing: trailing ?? Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
      onTap: onTap,
    );
  }
}
