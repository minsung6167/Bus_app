import 'package:test/test.dart';
import 'package:bus_app/models/bus_model.dart';
import 'package:bus_app/models/booking_model.dart';

Bus _futureBus() {
  final dep = DateTime.now().add(const Duration(days: 1));
  return Bus(
    id: 'BUS001',
    from: '서울남부',
    to: '부산종합',
    departureTime: dep,
    arrivalTime: dep.add(const Duration(hours: 4)),
    price: 20000,
    totalSeats: 28,
    remainingSeats: 10,
    busType: '일반',
    company: '금호고속',
  );
}

Bus _pastBus() {
  final dep = DateTime.now().subtract(const Duration(days: 1));
  return Bus(
    id: 'BUS002',
    from: '부산종합',
    to: '서울남부',
    departureTime: dep,
    arrivalTime: dep.add(const Duration(hours: 4)),
    price: 20000,
    totalSeats: 28,
    remainingSeats: 0,
    busType: '우등',
    company: '동양고속',
  );
}

Booking _makeBooking(Bus bus) => Booking(
      id: 'BK00001',
      bus: bus,
      seats: ['A1', 'B2'],
      passengerName: '최민성',
      passengerPhone: '010-1234-5678',
      totalPrice: 40000,
      bookedAt: DateTime(2026, 6, 14, 10, 0),
    );

void main() {
  group('Booking 모델 단위 테스트', () {
    test('isUpcoming — 미래 출발 버스는 true를 반환한다', () {
      final booking = _makeBooking(_futureBus());
      expect(booking.isUpcoming, true);
    });

    test('isUpcoming — 과거 출발 버스는 false를 반환한다', () {
      final booking = _makeBooking(_pastBus());
      expect(booking.isUpcoming, false);
    });

    test('toJson — 모든 필드가 직렬화된다', () {
      final booking = _makeBooking(_futureBus());
      final json = booking.toJson();

      expect(json['id'], 'BK00001');
      expect(json['passengerName'], '최민성');
      expect(json['passengerPhone'], '010-1234-5678');
      expect(json['totalPrice'], 40000);
      expect((json['seats'] as List), contains('A1'));
      expect((json['seats'] as List), contains('B2'));
      expect(json['bus'], isA<Map<String, dynamic>>());
    });

    test('fromJson — JSON에서 Booking 객체가 복원된다', () {
      final original = _makeBooking(_futureBus());
      final json = original.toJson();
      final restored = Booking.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.passengerName, original.passengerName);
      expect(restored.passengerPhone, original.passengerPhone);
      expect(restored.totalPrice, original.totalPrice);
      expect(restored.seats, original.seats);
      expect(restored.bus.id, original.bus.id);
    });

    test('toJson/fromJson 직렬화 왕복 후 isUpcoming이 유지된다', () {
      final futurBooking = _makeBooking(_futureBus());
      final restored = Booking.fromJson(futurBooking.toJson());
      expect(restored.isUpcoming, true);
    });
  });
}
