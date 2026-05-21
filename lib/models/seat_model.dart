enum PassengerType { general, student, child }

enum SeatStatus { available, occupied, selected }

class Seat {
  final String id;
  final int row;
  final String column;
  SeatStatus status;
  PassengerType passengerType;

  Seat({
    required this.id,
    required this.row,
    required this.column,
    this.status = SeatStatus.available,
    this.passengerType = PassengerType.general,
  });

  String get label => '$column$row';
  bool get isAvailable => status == SeatStatus.available;
  bool get isOccupied => status == SeatStatus.occupied;
  bool get isSelected => status == SeatStatus.selected;

  String get passengerTypeShort {
    switch (passengerType) {
      case PassengerType.student:
        return '중고';
      case PassengerType.child:
        return '아동';
      case PassengerType.general:
        return '일반';
    }
  }

  double get priceMultiplier {
    switch (passengerType) {
      case PassengerType.student:
        return 0.8;
      case PassengerType.child:
        return 0.5;
      case PassengerType.general:
        return 1.0;
    }
  }
}
