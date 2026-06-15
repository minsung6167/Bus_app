import 'package:test/test.dart';
import 'package:bus_app/models/bus_model.dart';

Bus _makeBus({
  String id = 'BUS001',
  int durationHours = 3,
  int durationMinutes = 30,
  int price = 20000,
  int totalSeats = 28,
  int remainingSeats = 10,
  String busType = '일반',
}) {
  final now = DateTime(2026, 6, 14, 9, 0);
  return Bus(
    id: id,
    from: '서울남부',
    to: '부산종합',
    departureTime: now,
    arrivalTime: now.add(Duration(hours: durationHours, minutes: durationMinutes)),
    price: price,
    totalSeats: totalSeats,
    remainingSeats: remainingSeats,
    busType: busType,
    company: '금호고속',
  );
}

void main() {
  group('Bus 모델 단위 테스트', () {
    test('duration — 시간+분 형식이 올바르다', () {
      final bus = _makeBus(durationHours: 3, durationMinutes: 30);
      expect(bus.duration, '3시간 30분');
    });

    test('duration — 분만 있을 때 분 형식이다', () {
      final bus = _makeBus(durationHours: 0, durationMinutes: 45);
      expect(bus.duration, '45분');
    });

    test('duration — 시간만 있을 때 시간 형식이다', () {
      final bus = _makeBus(durationHours: 2, durationMinutes: 0);
      expect(bus.duration, '2시간');
    });

    test('toJson — 모든 필드가 직렬화된다', () {
      final bus = _makeBus(id: 'BUS999', price: 15000);
      final json = bus.toJson();

      expect(json['id'], 'BUS999');
      expect(json['from'], '서울남부');
      expect(json['to'], '부산종합');
      expect(json['price'], 15000);
      expect(json['totalSeats'], 28);
      expect(json['remainingSeats'], 10);
      expect(json['busType'], '일반');
      expect(json['company'], '금호고속');
    });

    test('fromJson — JSON에서 Bus 객체가 복원된다', () {
      final original = _makeBus(id: 'BUS123', price: 22000);
      final json = original.toJson();
      final restored = Bus.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.from, original.from);
      expect(restored.to, original.to);
      expect(restored.price, original.price);
      expect(restored.totalSeats, original.totalSeats);
      expect(restored.remainingSeats, original.remainingSeats);
      expect(restored.busType, original.busType);
      expect(restored.company, original.company);
    });

    test('toJson/fromJson 직렬화 왕복이 일관성을 유지한다', () {
      final bus = _makeBus(durationHours: 4, durationMinutes: 15);
      final restored = Bus.fromJson(bus.toJson());
      expect(restored.duration, bus.duration);
      expect(restored.departureTime, bus.departureTime);
      expect(restored.arrivalTime, bus.arrivalTime);
    });
  });
}
