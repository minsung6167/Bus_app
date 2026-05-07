import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../models/seat_model.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  Bus? selectedBus;
  List<Seat> seats = [];
  final List<Seat> selectedSeats = [];
  final List<Booking> bookings = [];

  void selectBus(Bus bus) {
    selectedBus = bus;
    selectedSeats.clear();
    _generateSeats(bus);
    notifyListeners();
  }

  void _generateSeats(Bus bus) {
    seats = [];
    final cols = _getColumns(bus.busType);
    final rows = _getRows(bus.busType);

    // 노선ID + 출발일시 기반 시드 → 같은 버스는 항상 같은 좌석 배치
    final dep = bus.departureTime;
    final seed = bus.id.hashCode ^
        dep.year ^
        (dep.month << 8) ^
        (dep.day << 16) ^
        (dep.hour << 20);
    final rng = Random(seed);

    final occupied = bus.totalSeats - bus.remainingSeats;

    // 점유 좌석을 랜덤하게 미리 선정 (앞자리 쏠림 방지)
    final allSeatIds = <String>[];
    for (int r = 1; r <= rows; r++) {
      for (final col in cols) {
        allSeatIds.add('$col$r');
      }
    }
    allSeatIds.shuffle(rng);
    final occupiedIds = allSeatIds.take(occupied).toSet();

    for (int r = 1; r <= rows; r++) {
      for (final col in cols) {
        final id = '$col$r';
        seats.add(Seat(
          id: id,
          row: r,
          column: col,
          status: occupiedIds.contains(id)
              ? SeatStatus.occupied
              : SeatStatus.available,
        ));
      }
    }
  }

  List<String> _getColumns(String busType) {
    switch (busType) {
      case '프리미엄':
        return ['A', 'B'];
      case '우등':
        return ['A', 'B', 'C'];
      default:
        return ['A', 'B', 'C', 'D'];
    }
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

  void toggleSeat(Seat seat) {
    if (seat.isOccupied) return;
    if (seat.isSelected) {
      seat.status = SeatStatus.available;
      selectedSeats.remove(seat);
    } else {
      seat.status = SeatStatus.selected;
      selectedSeats.add(seat);
    }
    notifyListeners();
  }

  Booking createBooking({
    required String passengerName,
    required String passengerPhone,
  }) {
    final booking = Booking(
      id: 'BK${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}',
      bus: selectedBus!,
      seats: selectedSeats.map((s) => s.label).toList(),
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      totalPrice: selectedBus!.price * selectedSeats.length,
      bookedAt: DateTime.now(),
    );
    bookings.add(booking);
    notifyListeners();
    return booking;
  }

  int get totalPrice => (selectedBus?.price ?? 0) * selectedSeats.length;

  void clearSelection() {
    for (final seat in selectedSeats) {
      seat.status = SeatStatus.available;
    }
    selectedSeats.clear();
    notifyListeners();
  }
}
