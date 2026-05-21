import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../l10n/terminal_names.dart';
import '../models/booking_model.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(AppStrings.get(lang, 'tabMyBookings')),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.confirmation_number_outlined, size: 80, color: AppColors.textHint),
                const SizedBox(height: 20),
                Text(
                  AppStrings.get(lang, 'loginToUse'),
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

    return Consumer<BookingProvider>(
      builder: (ctx, provider, _) {
        final upcoming = provider.bookings.where((b) => b.isUpcoming).toList();
        final past = provider.bookings.where((b) => !b.isUpcoming).toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(AppStrings.get(lang, 'tabMyBookings')),
              automaticallyImplyLeading: false,
              bottom: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  Tab(text: AppStrings.get(lang, 'tabUpcoming')),
                  Tab(text: AppStrings.get(lang, 'tabPast')),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _BookingList(bookings: upcoming, isEmpty: upcoming.isEmpty, lang: lang),
                _BookingList(bookings: past, isEmpty: past.isEmpty, isPast: true, lang: lang),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final bool isEmpty;
  final bool isPast;
  final String lang;

  const _BookingList({
    required this.bookings,
    required this.isEmpty,
    required this.lang,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPast ? Icons.history_outlined : Icons.confirmation_number_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              isPast
                  ? AppStrings.get(lang, 'noPastBookings')
                  : AppStrings.get(lang, 'noUpcomingBookings'),
              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get(lang, 'searchPrompt'),
              style: const TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (ctx, i) => _BookingCard(booking: bookings[i], isPast: isPast, lang: lang),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isPast;
  final String lang;

  const _BookingCard({required this.booking, required this.isPast, required this.lang});


  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('yyyy.MM.dd');
    final priceFormat = NumberFormat('#,###');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isPast ? AppColors.background : AppColors.primary.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(
                  AppStrings.fmt(lang, 'bookingNum', {'id': booking.id}),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPast ? AppColors.divider : AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPast
                        ? AppStrings.get(lang, 'tripComplete')
                        : AppStrings.get(lang, 'bookingDone'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isPast ? AppColors.textSecondary : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(timeFormat.format(booking.bus.departureTime),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text(TerminalNames.translate(booking.bus.from, lang),
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(booking.bus.duration,
                          style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                        const Icon(Icons.arrow_forward, color: AppColors.primaryLight, size: 18),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(timeFormat.format(booking.bus.arrivalTime),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text(TerminalNames.translate(booking.bus.to, lang),
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: AppColors.divider),
                Row(
                  children: [
                    _DetailChip(icon: Icons.calendar_today_outlined, label: dateFormat.format(booking.bus.departureTime)),
                    const SizedBox(width: 8),
                    _DetailChip(icon: Icons.event_seat_outlined, label: booking.seats.join(', ')),
                    const Spacer(),
                    Text('${priceFormat.format(booking.totalPrice)}원',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
