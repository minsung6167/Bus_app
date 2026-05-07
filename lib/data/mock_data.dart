import '../models/bus_model.dart';

class MockData {
  static const List<String> cities = [
    '서울', '부산', '대구', '인천', '광주', '대전',
    '울산', '수원', '춘천', '강릉', '전주', '청주',
  ];

  static const List<Map<String, String>> popularRoutes = [
    {'from': '서울', 'to': '부산'},
    {'from': '서울', 'to': '대전'},
    {'from': '서울', 'to': '광주'},
    {'from': '부산', 'to': '서울'},
    {'from': '대전', 'to': '부산'},
  ];

  static List<Bus> getBuses(String from, String to, DateTime date) {
    final base = DateTime(date.year, date.month, date.day);

    return [
      Bus(
        id: 'b1', from: from, to: to,
        departureTime: base.add(const Duration(hours: 6, minutes: 30)),
        arrivalTime: base.add(const Duration(hours: 11, minutes: 0)),
        price: 26700, totalSeats: 44, remainingSeats: 21,
        busType: '일반', company: '금호고속',
      ),
      Bus(
        id: 'b2', from: from, to: to,
        departureTime: base.add(const Duration(hours: 8, minutes: 0)),
        arrivalTime: base.add(const Duration(hours: 12, minutes: 20)),
        price: 33600, totalSeats: 27, remainingSeats: 6,
        busType: '우등', company: '동양고속',
      ),
      Bus(
        id: 'b3', from: from, to: to,
        departureTime: base.add(const Duration(hours: 9, minutes: 30)),
        arrivalTime: base.add(const Duration(hours: 14, minutes: 0)),
        price: 26700, totalSeats: 44, remainingSeats: 32,
        busType: '일반', company: '중앙고속',
      ),
      Bus(
        id: 'b4', from: from, to: to,
        departureTime: base.add(const Duration(hours: 11, minutes: 0)),
        arrivalTime: base.add(const Duration(hours: 15, minutes: 10)),
        price: 44800, totalSeats: 20, remainingSeats: 4,
        busType: '프리미엄', company: '금호고속',
      ),
      Bus(
        id: 'b5', from: from, to: to,
        departureTime: base.add(const Duration(hours: 13, minutes: 0)),
        arrivalTime: base.add(const Duration(hours: 17, minutes: 20)),
        price: 33600, totalSeats: 27, remainingSeats: 15,
        busType: '우등', company: '코리아익스프레스',
      ),
      Bus(
        id: 'b6', from: from, to: to,
        departureTime: base.add(const Duration(hours: 15, minutes: 30)),
        arrivalTime: base.add(const Duration(hours: 20, minutes: 0)),
        price: 26700, totalSeats: 44, remainingSeats: 38,
        busType: '일반', company: '동양고속',
      ),
      Bus(
        id: 'b7', from: from, to: to,
        departureTime: base.add(const Duration(hours: 17, minutes: 0)),
        arrivalTime: base.add(const Duration(hours: 21, minutes: 20)),
        price: 33600, totalSeats: 27, remainingSeats: 11,
        busType: '우등', company: '금호고속',
      ),
      Bus(
        id: 'b8', from: from, to: to,
        departureTime: base.add(const Duration(hours: 19, minutes: 0)),
        arrivalTime: base.add(const Duration(hours: 23, minutes: 30)),
        price: 26700, totalSeats: 44, remainingSeats: 28,
        busType: '일반', company: '중앙고속',
      ),
    ];
  }
}
