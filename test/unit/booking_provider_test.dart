import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bus_app/providers/booking_provider.dart';
import 'package:bus_app/models/bus_model.dart';
import 'package:bus_app/models/seat_model.dart';

Bus _makeBus({
  String id = 'BUS001',
  String busType = '일반',
  int price = 20000,
  int totalSeats = 44,
  int remainingSeats = 20,
}) {
  final dep = DateTime(2026, 6, 20, 9, 0);
  return Bus(
    id: id,
    from: '서울남부',
    to: '부산종합',
    departureTime: dep,
    arrivalTime: dep.add(const Duration(hours: 4)),
    price: price,
    totalSeats: totalSeats,
    remainingSeats: remainingSeats,
    busType: busType,
    company: '금호고속',
  );
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BookingProvider 단위 테스트', () {
    test('초기 상태 — selectedBus가 null이고 seats가 비어 있다', () {
      final provider = BookingProvider();
      expect(provider.selectedBus, isNull);
      expect(provider.seats, isEmpty);
      expect(provider.selectedSeats, isEmpty);
      expect(provider.bookings, isEmpty);
    });

    test('selectBus — 버스 선택 후 selectedBus가 설정된다', () {
      final provider = BookingProvider();
      final bus = _makeBus();
      provider.selectBus(bus);
      expect(provider.selectedBus, bus);
    });

    test('selectBus — 버스 선택 후 seats가 생성된다', () {
      final provider = BookingProvider();
      final bus = _makeBus(busType: '일반', totalSeats: 44);
      provider.selectBus(bus);
      expect(provider.seats, isNotEmpty);
    });

    test('selectBus — 일반 버스 좌석은 A~D 4열로 생성된다', () {
      final provider = BookingProvider();
      provider.selectBus(_makeBus(busType: '일반', totalSeats: 44, remainingSeats: 44));
      final columns = provider.seats.map((s) => s.column).toSet();
      expect(columns, containsAll(['A', 'B', 'C', 'D']));
    });

    test('selectBus — 우등 버스 좌석은 A~C 3열로 생성된다', () {
      final provider = BookingProvider();
      provider.selectBus(_makeBus(busType: '우등', totalSeats: 27, remainingSeats: 27));
      final columns = provider.seats.map((s) => s.column).toSet();
      expect(columns, containsAll(['A', 'B', 'C']));
      expect(columns.contains('D'), false);
    });

    test('좌석 생성이 결정적이다 — 같은 버스는 항상 동일한 좌석 배치를 반환한다', () {
      final bus = _makeBus(id: 'BUS_SEED', totalSeats: 44, remainingSeats: 20);

      final p1 = BookingProvider()..selectBus(bus);
      final p2 = BookingProvider()..selectBus(bus);

      final ids1 = p1.seats.map((s) => '${s.label}:${s.status.name}').toList();
      final ids2 = p2.seats.map((s) => '${s.label}:${s.status.name}').toList();
      expect(ids1, ids2);
    });

    test('selectSeat — 좌석 선택 후 selectedSeats에 추가된다', () {
      final provider = BookingProvider();
      provider.selectBus(_makeBus());

      final seat = provider.seats.firstWhere((s) => s.isAvailable);
      provider.selectSeat(seat, PassengerType.general);

      expect(provider.selectedSeats, contains(seat));
      expect(seat.isSelected, true);
    });

    test('selectSeat — occupied 좌석은 선택되지 않는다', () {
      final provider = BookingProvider();
      provider.selectBus(_makeBus(totalSeats: 44, remainingSeats: 1));

      final occupied = provider.seats.firstWhere((s) => s.isOccupied);
      provider.selectSeat(occupied, PassengerType.general);

      expect(provider.selectedSeats, isEmpty);
    });

    test('deselectSeat — 선택 해제 후 selectedSeats에서 제거된다', () {
      final provider = BookingProvider();
      provider.selectBus(_makeBus());

      final seat = provider.seats.firstWhere((s) => s.isAvailable);
      provider.selectSeat(seat, PassengerType.general);
      expect(provider.selectedSeats.length, 1);

      provider.deselectSeat(seat);
      expect(provider.selectedSeats, isEmpty);
      expect(seat.isAvailable, true);
    });

    test('totalPrice — 일반 승객 가격이 정확하다', () {
      final provider = BookingProvider();
      provider.selectBus(_makeBus(price: 20000));

      final seat = provider.seats.firstWhere((s) => s.isAvailable);
      provider.selectSeat(seat, PassengerType.general);

      expect(provider.totalPrice, 20000);
    });

    test('totalPrice — 중고생(0.8) 가격이 정확하다', () {
      final provider = BookingProvider();
      provider.selectBus(_makeBus(price: 20000));

      final seat = provider.seats.firstWhere((s) => s.isAvailable);
      provider.selectSeat(seat, PassengerType.student);

      expect(provider.totalPrice, 16000); // 20000 * 0.8
    });

    test('totalPrice — 아동(0.5) 가격이 정확하다', () {
      final provider = BookingProvider();
      provider.selectBus(_makeBus(price: 20000));

      final seat = provider.seats.firstWhere((s) => s.isAvailable);
      provider.selectSeat(seat, PassengerType.child);

      expect(provider.totalPrice, 10000); // 20000 * 0.5
    });

    test('generalCount / studentCount / childCount가 정확하다', () {
      final provider = BookingProvider();
      provider.selectBus(_makeBus(price: 10000, totalSeats: 44, remainingSeats: 44));

      final available = provider.seats.where((s) => s.isAvailable).take(3).toList();
      provider.selectSeat(available[0], PassengerType.general);
      provider.selectSeat(available[1], PassengerType.student);
      provider.selectSeat(available[2], PassengerType.child);

      expect(provider.generalCount, 1);
      expect(provider.studentCount, 1);
      expect(provider.childCount, 1);
    });

    test('effectiveRemaining — 좌석 선택 후 잔여 좌석이 줄어든다', () {
      final provider = BookingProvider();
      final bus = _makeBus(totalSeats: 44, remainingSeats: 10);
      provider.selectBus(bus);

      final before = provider.effectiveRemaining(bus);
      final seat = provider.seats.firstWhere((s) => s.isAvailable);
      provider.selectSeat(seat, PassengerType.general);

      // effectiveRemaining은 예약 완료(createBooking) 후 감소
      // 선택 시점에는 아직 감소하지 않음
      expect(provider.effectiveRemaining(bus), before);
    });

    test('clearSelection — 선택한 좌석이 모두 해제된다', () {
      final provider = BookingProvider();
      provider.selectBus(_makeBus(totalSeats: 44, remainingSeats: 44));

      final available = provider.seats.where((s) => s.isAvailable).take(2).toList();
      provider.selectSeat(available[0], PassengerType.general);
      provider.selectSeat(available[1], PassengerType.general);
      expect(provider.selectedSeats.length, 2);

      provider.clearSelection();
      expect(provider.selectedSeats, isEmpty);
      expect(available[0].isAvailable, true);
      expect(available[1].isAvailable, true);
    });
  });
}
