class Bus {
  final String id;
  final String from;
  final String to;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int price;
  final int totalSeats;
  final int remainingSeats;
  final String busType;
  final String company;

  const Bus({
    required this.id,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.totalSeats,
    required this.remainingSeats,
    required this.busType,
    required this.company,
  });

  String get duration {
    final diff = arrivalTime.difference(departureTime);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h == 0) return '${m}분';
    if (m == 0) return '$h시간';
    return '$h시간 $m분';
  }
}
