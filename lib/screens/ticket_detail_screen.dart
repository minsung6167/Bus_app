import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../l10n/app_strings.dart';
import '../l10n/terminal_names.dart';
import '../models/booking_model.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import 'map_screen.dart';
import 'sleep_mode_screen.dart';

class TicketDetailScreen extends StatelessWidget {
  final Booking booking;

  const TicketDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat(AppStrings.dateFormat(lang));
    final priceFormat = NumberFormat('#,###');
    final isPast = !booking.isUpcoming;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.fmt(lang, 'bookingNum', {'id': booking.id})),
        actions: isPast ? null : [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: AppStrings.get(lang, 'mapTooltip'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MapScreen(
                  fromTerminalName: booking.bus.from,
                  toTerminalName: booking.bus.to,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.snooze),
            tooltip: AppStrings.get(lang, 'sleepModeTooltip'),
            color: const Color(0xFF7C3AED),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SleepModeScreen(destTerminalName: booking.bus.to),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // 티켓 카드
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  // 출발/도착
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(timeFormat.format(booking.bus.departureTime),
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              Text(TerminalNames.translate(booking.bus.from, lang),
                                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(booking.bus.duration,
                              style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                            const Icon(Icons.arrow_forward, color: AppColors.primaryLight, size: 20),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(timeFormat.format(booking.bus.arrivalTime),
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              Text(TerminalNames.translate(booking.bus.to, lang),
                                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: AppColors.divider),

                  // 상세 정보
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _Row(
                          icon: Icons.calendar_today_outlined,
                          label: AppStrings.get(lang, 'date'),
                          value: dateFormat.format(booking.bus.departureTime),
                        ),
                        const SizedBox(height: 14),
                        _Row(
                          icon: Icons.access_time,
                          label: AppStrings.get(lang, 'departure'),
                          value: timeFormat.format(booking.bus.departureTime),
                        ),
                        const SizedBox(height: 14),
                        _Row(
                          icon: Icons.event_seat_outlined,
                          label: AppStrings.get(lang, 'seats'),
                          value: booking.seats.join(', '),
                        ),
                        const SizedBox(height: 14),
                        _Row(
                          icon: Icons.person_outline,
                          label: AppStrings.get(lang, 'passengerInfo'),
                          value: booking.passengerName,
                        ),
                        const SizedBox(height: 14),
                        _Row(
                          icon: Icons.directions_bus_outlined,
                          label: AppStrings.get(lang, 'busType'),
                          value: TerminalNames.translateBusType(booking.bus.busType, lang),
                        ),
                        const Divider(height: 28, color: AppColors.divider),
                        Row(
                          children: [
                            Text(AppStrings.get(lang, 'totalPayment'),
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                            const Spacer(),
                            Text('${priceFormat.format(booking.totalPrice)}원',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 모바일 발권 QR코드
            const SizedBox(height: 16),
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
                    children: [
                      const Icon(Icons.qr_code, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(AppStrings.get(lang, 'mobileTicket'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: '${booking.id}|${booking.bus.from}|${booking.bus.to}|'
                        '${DateFormat('yyyy-MM-dd HH:mm').format(booking.bus.departureTime)}|'
                        '${booking.seats.join(',')}|${booking.passengerName}',
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(booking.id,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(AppStrings.get(lang, 'showQrHint'),
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
