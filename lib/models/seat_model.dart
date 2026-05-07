enum SeatStatus { available, occupied, selected }

class Seat {
  final String id;
  final int row;
  final String column;
  SeatStatus status;

  Seat({
    required this.id,
    required this.row,
    required this.column,
    this.status = SeatStatus.available,
  });

  String get label => '$column$row';
  bool get isAvailable => status == SeatStatus.available;
  bool get isOccupied => status == SeatStatus.occupied;
  bool get isSelected => status == SeatStatus.selected;
}
