import 'bus_model.dart';

class Booking {
  final String id;
  final Bus bus;
  final List<String> seats;
  final String passengerName;
  final String passengerPhone;
  final int totalPrice;
  final DateTime bookedAt;

  const Booking({
    required this.id,
    required this.bus,
    required this.seats,
    required this.passengerName,
    required this.passengerPhone,
    required this.totalPrice,
    required this.bookedAt,
  });

  bool get isUpcoming => bus.departureTime.isAfter(DateTime.now());
}
