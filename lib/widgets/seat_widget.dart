import 'package:flutter/material.dart';
import '../models/seat_model.dart';
import '../theme/app_theme.dart';

class SeatWidget extends StatelessWidget {
  final Seat seat;
  final VoidCallback? onTap;

  const SeatWidget({super.key, required this.seat, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;

    switch (seat.status) {
      case SeatStatus.available:
        bgColor = AppColors.seatAvailable;
        borderColor = AppColors.seatAvailableBorder;
        textColor = const Color(0xFF16A34A);
      case SeatStatus.occupied:
        bgColor = AppColors.seatOccupied;
        borderColor = AppColors.seatOccupiedBorder;
        textColor = const Color(0xFFDC2626);
      case SeatStatus.selected:
        bgColor = AppColors.seatSelected;
        borderColor = AppColors.seatSelected;
        textColor = Colors.white;
    }

    return GestureDetector(
      onTap: seat.isOccupied ? null : onTap,
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          seat.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
