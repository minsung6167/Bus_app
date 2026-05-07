import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bus_model.dart';
import '../theme/app_theme.dart';

class BusCard extends StatelessWidget {
  final Bus bus;
  final VoidCallback onSelect;

  const BusCard({super.key, required this.bus, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final priceFormat = NumberFormat('#,###');

    final typeColor = switch (bus.busType) {
      '우등' => const Color(0xFF7C3AED),
      '프리미엄' => const Color(0xFFB45309),
      _ => AppColors.primary,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    bus.busType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  bus.company,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                _RemainingSeatsChip(remaining: bus.remainingSeats),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _TimeBlock(
                  time: timeFormat.format(bus.departureTime),
                  label: bus.from,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        bus.duration,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(height: 1, color: AppColors.divider),
                          const Icon(
                            Icons.directions_bus,
                            size: 16,
                            color: AppColors.primaryLight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _TimeBlock(
                  time: timeFormat.format(bus.arrivalTime),
                  label: bus.to,
                  isRight: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${priceFormat.format(bus.price)}원',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      '1인 기준',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: bus.remainingSeats > 0 ? onSelect : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                  child: const Text('선택'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String time;
  final String label;
  final bool isRight;

  const _TimeBlock({
    required this.time,
    required this.label,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RemainingSeatsChip extends StatelessWidget {
  final int remaining;

  const _RemainingSeatsChip({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final isScarce = remaining <= 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isScarce
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isScarce ? Icons.warning_amber_rounded : Icons.event_seat,
            size: 12,
            color: isScarce
                ? const Color(0xFFD97706)
                : const Color(0xFF16A34A),
          ),
          const SizedBox(width: 3),
          Text(
            remaining > 0 ? '잔여 $remaining석' : '매진',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isScarce
                  ? const Color(0xFFD97706)
                  : const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }
}
