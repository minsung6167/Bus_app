import 'package:test/test.dart';
import 'package:bus_app/models/seat_model.dart';

void main() {
  group('Seat 모델 단위 테스트', () {
    test('label은 column+row 문자열을 반환한다', () {
      final seat = Seat(id: 'A1', row: 1, column: 'A');
      expect(seat.label, 'A1');

      final seat2 = Seat(id: 'C5', row: 5, column: 'C');
      expect(seat2.label, 'C5');
    });

    test('기본 status는 available이다', () {
      final seat = Seat(id: 'A1', row: 1, column: 'A');
      expect(seat.isAvailable, true);
      expect(seat.isOccupied, false);
      expect(seat.isSelected, false);
    });

    test('occupied 상태 getter가 정확하다', () {
      final seat = Seat(id: 'B2', row: 2, column: 'B', status: SeatStatus.occupied);
      expect(seat.isOccupied, true);
      expect(seat.isAvailable, false);
      expect(seat.isSelected, false);
    });

    test('selected 상태 getter가 정확하다', () {
      final seat = Seat(id: 'C3', row: 3, column: 'C', status: SeatStatus.selected);
      expect(seat.isSelected, true);
      expect(seat.isAvailable, false);
      expect(seat.isOccupied, false);
    });

    test('일반 승객 priceMultiplier는 1.0이다', () {
      final seat = Seat(id: 'A1', row: 1, column: 'A', passengerType: PassengerType.general);
      expect(seat.priceMultiplier, 1.0);
    });

    test('중고생 승객 priceMultiplier는 0.8이다', () {
      final seat = Seat(id: 'A1', row: 1, column: 'A', passengerType: PassengerType.student);
      expect(seat.priceMultiplier, 0.8);
    });

    test('아동 승객 priceMultiplier는 0.5이다', () {
      final seat = Seat(id: 'A1', row: 1, column: 'A', passengerType: PassengerType.child);
      expect(seat.priceMultiplier, 0.5);
    });

    test('passengerTypeShort가 올바른 문자열을 반환한다', () {
      final general = Seat(id: 'A1', row: 1, column: 'A', passengerType: PassengerType.general);
      final student = Seat(id: 'A2', row: 2, column: 'A', passengerType: PassengerType.student);
      final child = Seat(id: 'A3', row: 3, column: 'A', passengerType: PassengerType.child);

      expect(general.passengerTypeShort, '일반');
      expect(student.passengerTypeShort, '중고');
      expect(child.passengerTypeShort, '아동');
    });

    test('status는 변경 가능하다', () {
      final seat = Seat(id: 'A1', row: 1, column: 'A');
      expect(seat.isAvailable, true);

      seat.status = SeatStatus.selected;
      expect(seat.isSelected, true);

      seat.status = SeatStatus.occupied;
      expect(seat.isOccupied, true);
    });
  });
}
