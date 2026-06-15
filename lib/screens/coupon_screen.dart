import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/booking_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

const _available = 'available';
const _used = 'used';
const _expired = 'expired';

final _coupons = [
  {
    'id': 'c1',
    'discount': '2,000원',
    'title': '첫 예매 축하 쿠폰',
    'desc': '신규 회원 첫 예매 혜택',
    'minAmount': '10,000원 이상',
    'expiry': '2026.06.30',
    'status': _available,
    'color': const Color(0xFF1E40AF),
  },
  {
    'id': 'c2',
    'discount': '10%',
    'title': '봄맞이 할인 쿠폰',
    'desc': '봄맞이 특별 이벤트',
    'minAmount': '15,000원 이상',
    'expiry': '2026.05.31',
    'status': _available,
    'color': const Color(0xFF059669),
  },
  {
    'id': 'c3',
    'discount': '3,000원',
    'title': '생일 축하 쿠폰',
    'desc': '생일을 축하드립니다 🎂',
    'minAmount': '20,000원 이상',
    'expiry': '2026.12.31',
    'status': _available,
    'color': const Color(0xFF7C3AED),
  },
  {
    'id': '',
    'discount': '5,000원',
    'title': '추석 특별 쿠폰',
    'desc': '2025 추석 연휴 프로모션',
    'minAmount': '30,000원 이상',
    'expiry': '2025.10.10',
    'status': _expired,
    'color': const Color(0xFF94A3B8),
  },
  {
    'id': '',
    'discount': '15%',
    'title': '겨울 시즌 쿠폰',
    'desc': '2026 겨울 특별 할인',
    'minAmount': '20,000원 이상',
    'expiry': '2026.02.28',
    'status': _used,
    'color': const Color(0xFF94A3B8),
  },
];

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  int _selectedFilter = 0; // 0: 전체, 1: 사용 가능, 2: 사용·만료

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    final bookingProvider = context.watch<BookingProvider>();

    String effectiveStatus(Map<String, dynamic> c) {
      final id = c['id'] as String;
      if (c['status'] != _available) return c['status'] as String;
      return (id.isNotEmpty && bookingProvider.isCouponUsed(id)) ? _used : _available;
    }

    final filtered = _coupons.where((c) {
      final status = effectiveStatus(c);
      if (_selectedFilter == 1) return status == _available;
      if (_selectedFilter == 2) return status == _used || status == _expired;
      return true;
    }).toList();

    final availableCount = _coupons
        .where((c) => effectiveStatus(c) == _available)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.get(lang, 'coupons'))),
      body: Column(
        children: [
          // 보유 쿠폰 수
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              AppStrings.fmt(lang, 'couponCount', {'n': '$availableCount'}),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),

          // 필터 칩
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _FilterChip(
                  label: AppStrings.get(lang, 'couponTabAll'),
                  selected: _selectedFilter == 0,
                  onTap: () => setState(() => _selectedFilter = 0),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: AppStrings.get(lang, 'couponAvailable'),
                  selected: _selectedFilter == 1,
                  onTap: () => setState(() => _selectedFilter = 1),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: AppStrings.get(lang, 'couponTabUsed'),
                  selected: _selectedFilter == 2,
                  onTap: () => setState(() => _selectedFilter = 2),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // 쿠폰 목록
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.confirmation_number_outlined,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.get(lang, 'noCoupons'),
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _CouponCard(
                      coupon: filtered[i],
                      lang: lang,
                      effectiveStatus: effectiveStatus(filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final String lang;
  final String effectiveStatus;

  const _CouponCard({required this.coupon, required this.lang, required this.effectiveStatus});

  @override
  Widget build(BuildContext context) {
    final isActive = effectiveStatus == _available;
    final color = coupon['color'] as Color;

    final String statusLabel;
    final Color statusColor;
    final Color statusBg;
    if (effectiveStatus == _available) {
      statusLabel = AppStrings.get(lang, 'couponAvailable');
      statusColor = AppColors.primary;
      statusBg = AppColors.primary.withOpacity(0.1);
    } else if (effectiveStatus == _used) {
      statusLabel = AppStrings.get(lang, 'couponUsed');
      statusColor = AppColors.textHint;
      statusBg = AppColors.divider;
    } else {
      statusLabel = AppStrings.get(lang, 'couponExpired');
      statusColor = AppColors.textHint;
      statusBg = AppColors.divider;
    }

    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 왼쪽 색상 띠
                Container(
                  width: 88,
                  color: color,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        coupon['discount'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'COUPON',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // 점선 구분 (CustomPaint)
                SizedBox(
                  width: 14,
                  child: CustomPaint(
                    painter: _DashedLinePainter(color: color.withOpacity(0.35)),
                  ),
                ),

                // 오른쪽 정보
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                coupon['title'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coupon['desc'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.receipt_outlined,
                              size: 12,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${AppStrings.get(lang, 'couponMinAmount')} ${coupon['minAmount']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${AppStrings.get(lang, 'couponExpiry')} ${coupon['expiry']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashH = 4.0;
    const gap = 3.0;
    final x = size.width / 2;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dashH), paint);
      y += dashH + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
