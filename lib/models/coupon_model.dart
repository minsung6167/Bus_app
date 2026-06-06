class Coupon {
  final String id;
  final String title;
  final String desc;
  final String discount;
  final String minAmount;
  final String expiry;
  final String status;

  const Coupon({
    required this.id,
    required this.title,
    required this.desc,
    required this.discount,
    required this.minAmount,
    required this.expiry,
    required this.status,
  });

  bool get isAvailable => status == 'available';

  /// 최소 사용 금액 (숫자)
  int get minAmountInt {
    final clean = minAmount.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  /// 할인 금액 계산
  int discountAmount(int totalPrice) {
    if (discount.endsWith('%')) {
      final pct = int.tryParse(discount.replaceAll('%', '')) ?? 0;
      return (totalPrice * pct / 100).round();
    }
    final clean = discount.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }
}

const availableCoupons = <Coupon>[
  Coupon(
    id: 'c1',
    title: '첫 예매 축하 쿠폰',
    desc: '신규 회원 첫 예매 혜택',
    discount: '2,000원',
    minAmount: '10,000원 이상',
    expiry: '2026.06.30',
    status: 'available',
  ),
  Coupon(
    id: 'c2',
    title: '봄맞이 할인 쿠폰',
    desc: '봄맞이 특별 이벤트',
    discount: '10%',
    minAmount: '15,000원 이상',
    expiry: '2026.05.31',
    status: 'available',
  ),
  Coupon(
    id: 'c3',
    title: '생일 축하 쿠폰',
    desc: '생일을 축하드립니다',
    discount: '3,000원',
    minAmount: '20,000원 이상',
    expiry: '2026.12.31',
    status: 'available',
  ),
];
