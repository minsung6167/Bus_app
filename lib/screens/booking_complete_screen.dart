import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../l10n/terminal_names.dart';
import '../models/booking_model.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';
import 'sleep_mode_screen.dart';

class BookingCompleteScreen extends StatelessWidget {
  final Booking booking;

  const BookingCompleteScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat(AppStrings.dateFormat(lang));
    final priceFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100, height: 100,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.get(lang, 'bookingComplete'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.fmt(lang, 'bookingId', {'id': booking.id}),
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(TerminalNames.translate(booking.bus.from, lang),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.arrow_forward, color: AppColors.primaryLight),
                        ),
                        Text(TerminalNames.translate(booking.bus.to, lang),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.divider),
                    _SummaryRow(
                      icon: Icons.calendar_today_outlined,
                      label: AppStrings.get(lang, 'date'),
                      value: dateFormat.format(booking.bus.departureTime),
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.access_time,
                      label: AppStrings.get(lang, 'departure'),
                      value: timeFormat.format(booking.bus.departureTime),
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.event_seat_outlined,
                      label: AppStrings.get(lang, 'seats'),
                      value: booking.seats.join(', '),
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.person_outline,
                      label: AppStrings.get(lang, 'passengerInfo'),
                      value: booking.passengerName,
                    ),
                    const Divider(height: 24, color: AppColors.divider),
                    Row(
                      children: [
                        Text(AppStrings.get(lang, 'totalPayment'),
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        const Spacer(),
                        Text('${priceFormat.format(booking.totalPrice)}원',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(AppStrings.get(lang, 'goHome'),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        mainScreenKey.currentState?.switchTab(1);
                      },
                      child: Text(AppStrings.get(lang, 'viewMyBookings')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SleepModeScreen(destTerminalName: booking.bus.to),
                    ),
                  ),
                  icon: const Icon(Icons.nightlight_round, size: 18),
                  label: const Text('수면 모드 설정', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: const Color(0xFF7C3AED),
                    side: const BorderSide(color: Color(0xFF7C3AED)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
