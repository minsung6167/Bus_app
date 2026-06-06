import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bus_model.dart';
import '../models/seat_model.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  Bus? selectedBus;
  List<Seat> seats = [];
  final List<Seat> selectedSeats = [];
  final List<Booking> bookings = [];

  final Map<String, int> _bookedSeatsMap = {};
  String? _userId;

  static String _bookingKey(String userId) => 'bookings_$userId';

  /// 로그인 시 호출 — 해당 유저의 예매 내역 로드
  Future<void> loadForUser(String userId) async {
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bookingKey(userId));
    final loaded = <Booking>[];
    if (raw != null) {
      final list = json.decode(raw) as List;
      loaded.addAll(list.map((e) => Booking.fromJson(e as Map<String, dynamic>)));
    }
    bookings
      ..clear()
      ..addAll(loaded);
    _bookedSeatsMap.clear();
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    bookings.clear();
    _bookedSeatsMap.clear();
    selectedBus = null;
    selectedSeats.clear();
    notifyListeners();
  }

  Future<void> _save() async {
    if (_userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _bookingKey(_userId!),
      json.encode(bookings.map((b) => b.toJson()).toList()),
    );
  }

  int effectiveRemaining(Bus bus) {
    final booked = _bookedSeatsMap[bus.id] ?? 0;
    return (bus.remainingSeats - booked).clamp(0, bus.totalSeats);
  }

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

    final dep = bus.departureTime;
    final seed = bus.id.hashCode ^
        dep.year ^
        (dep.month << 8) ^
        (dep.day << 16) ^
        (dep.hour << 20);
    final rng = Random(seed);

    final occupied = bus.totalSeats - bus.remainingSeats;

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

  // 좌석 선택 (유형 포함)
  void selectSeat(Seat seat, PassengerType type) {
    if (seat.isOccupied) return;
    seat.status = SeatStatus.selected;
    seat.passengerType = type;
    if (!selectedSeats.contains(seat)) {
      selectedSeats.add(seat);
    }
    notifyListeners();
  }

  // 좌석 해제
  void deselectSeat(Seat seat) {
    seat.status = SeatStatus.available;
    seat.passengerType = PassengerType.general;
    selectedSeats.remove(seat);
    notifyListeners();
  }

  // 유형별 인원수
  int get generalCount =>
      selectedSeats.where((s) => s.passengerType == PassengerType.general).length;
  int get studentCount =>
      selectedSeats.where((s) => s.passengerType == PassengerType.student).length;
  int get childCount =>
      selectedSeats.where((s) => s.passengerType == PassengerType.child).length;

  // 유형별 가격 적용 합계
  int get totalPrice {
    final base = selectedBus?.price ?? 0;
    return selectedSeats.fold(0, (sum, seat) {
      return sum + (base * seat.priceMultiplier).round();
    });
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
      totalPrice: totalPrice,
      bookedAt: DateTime.now(),
    );
    bookings.add(booking);
    _bookedSeatsMap[selectedBus!.id] =
        (_bookedSeatsMap[selectedBus!.id] ?? 0) + selectedSeats.length;
    notifyListeners();
    _save();
    return booking;
  }

  void clearSelection() {
    for (final seat in selectedSeats) {
      seat.status = SeatStatus.available;
      seat.passengerType = PassengerType.general;
    }
    selectedSeats.clear();
    notifyListeners();
  }
}
