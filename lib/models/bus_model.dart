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
    if (h == 0) return '$m분';
    if (m == 0) return '$h시간';
    return '$h시간 $m분';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from,
        'to': to,
        'departureTime': departureTime.toIso8601String(),
        'arrivalTime': arrivalTime.toIso8601String(),
        'price': price,
        'totalSeats': totalSeats,
        'remainingSeats': remainingSeats,
        'busType': busType,
        'company': company,
      };

  factory Bus.fromJson(Map<String, dynamic> j) => Bus(
        id: j['id'] as String,
        from: j['from'] as String,
        to: j['to'] as String,
        departureTime: DateTime.parse(j['departureTime'] as String),
        arrivalTime: DateTime.parse(j['arrivalTime'] as String),
        price: j['price'] as int,
        totalSeats: j['totalSeats'] as int,
        remainingSeats: j['remainingSeats'] as int,
        busType: j['busType'] as String,
        company: j['company'] as String,
      );
}
