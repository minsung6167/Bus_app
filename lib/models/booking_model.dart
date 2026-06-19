import '../services/time_service.dart';
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

  bool get isUpcoming => bus.departureTime.isAfter(TimeService.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'bus': bus.toJson(),
        'seats': seats,
        'passengerName': passengerName,
        'passengerPhone': passengerPhone,
        'totalPrice': totalPrice,
        'bookedAt': bookedAt.toIso8601String(),
      };

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: j['id'] as String,
        bus: Bus.fromJson(j['bus'] as Map<String, dynamic>),
        seats: List<String>.from(j['seats'] as List),
        passengerName: j['passengerName'] as String,
        passengerPhone: j['passengerPhone'] as String,
        totalPrice: j['totalPrice'] as int,
        bookedAt: DateTime.parse(j['bookedAt'] as String),
      );
}
