class PaymentCard {
  final String id;
  final String nickname;
  final String maskedNumber;
  final String expiry;
  final String cardType;

  const PaymentCard({
    required this.id,
    required this.nickname,
    required this.maskedNumber,
    required this.expiry,
    required this.cardType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'maskedNumber': maskedNumber,
        'expiry': expiry,
        'cardType': cardType,
      };

  factory PaymentCard.fromJson(Map<String, dynamic> json) => PaymentCard(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        maskedNumber: json['maskedNumber'] as String,
        expiry: json['expiry'] as String,
        cardType: json['cardType'] as String,
      );
}
