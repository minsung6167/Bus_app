import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/seat_model.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/seat_widget.dart';
import 'booking_confirm_screen.dart';

class SeatSelectionScreen extends StatelessWidget {
  const SeatSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (ctx, provider, _) {
        final bus = provider.selectedBus!;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('좌석 선택 · ${bus.busType}'),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildLegend(),
                      const SizedBox(height: 20),
                      _buildBusFront(),
                      const SizedBox(height: 8),
                      _buildSeatMap(provider),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: AppColors.seatAvailable,
          borderColor: AppColors.seatAvailableBorder,
          label: '선택 가능',
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: AppColors.seatOccupied,
          borderColor: AppColors.seatOccupiedBorder,
          label: '선택 불가',
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: AppColors.seatSelected,
          borderColor: AppColors.seatSelected,
          label: '선택한 좌석',
          textColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildBusFront() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_bus, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            '운전석 (앞)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatMap(BookingProvider provider) {
    final bus = provider.selectedBus!;
    final rows = _getRows(bus.busType);

    return Container(
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          _buildColumnHeader(bus.busType),
          const SizedBox(height: 8),
          ...List.generate(rows, (i) => _buildSeatRow(i + 1, provider)),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String busType) {
    final List<String> leftCols;
    final List<String> rightCols;

    if (busType == '일반') {
      leftCols = ['A', 'B'];
      rightCols = ['C', 'D'];
    } else if (busType == '우등') {
      leftCols = ['A'];
      rightCols = ['B', 'C'];
    } else {
      leftCols = ['A'];
      rightCols = ['B'];
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 24),
        ...leftCols.map(
          (c) => SizedBox(
            width: 50,
            child: Center(
              child: Text(
                c,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 28),
        ...rightCols.map(
          (c) => SizedBox(
            width: 50,
            child: Center(
              child: Text(
                c,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeatRow(int rowNum, BookingProvider provider) {
    final busType = provider.selectedBus!.busType;
    final rowSeats = provider.seats.where((s) => s.row == rowNum).toList();

    final List<Seat> leftSeats;
    final List<Seat> rightSeats;

    if (busType == '일반') {
      leftSeats = rowSeats.where((s) => s.column == 'A' || s.column == 'B').toList();
      rightSeats = rowSeats.where((s) => s.column == 'C' || s.column == 'D').toList();
    } else if (busType == '우등') {
      leftSeats = rowSeats.where((s) => s.column == 'A').toList();
      rightSeats = rowSeats.where((s) => s.column == 'B' || s.column == 'C').toList();
    } else {
      leftSeats = rowSeats.where((s) => s.column == 'A').toList();
      rightSeats = rowSeats.where((s) => s.column == 'B').toList();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          child: Text(
            '$rowNum',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
        ),
        ...leftSeats.map(
          (seat) => SeatWidget(
            seat: seat,
            onTap: () => provider.toggleSeat(seat),
          ),
        ),
        const SizedBox(width: 28),
        ...rightSeats.map(
          (seat) => SeatWidget(
            seat: seat,
            onTap: () => provider.toggleSeat(seat),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, BookingProvider provider) {
    final priceFormat = NumberFormat('#,###');
    final hasSelection = provider.selectedSeats.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasSelection) ...[
            Row(
              children: [
                const Text(
                  '선택한 좌석',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 4,
                  children: provider.selectedSeats
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            s.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const Spacer(),
                Text(
                  '${priceFormat.format(provider.totalPrice)}원',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasSelection
                  ? () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const BookingConfirmScreen(),
                      ));
                    }
                  : null,
              child: Text(
                hasSelection
                    ? '${provider.selectedSeats.length}석 예매하기'
                    : '좌석을 선택해주세요',
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getRows(String busType) {
    switch (busType) {
      case '일반':
        return 11;
      case '우등':
        return 9;
      case '프리미엄':
        return 10;
      default:
        return 11;
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;
  final Color textColor;

  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
    this.textColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: textColor == AppColors.textSecondary ? AppColors.textSecondary : AppColors.textSecondary),
        ),
      ],
    );
  }
}
