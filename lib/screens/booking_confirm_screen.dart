import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../l10n/terminal_names.dart';
import '../models/bus_model.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'booking_complete_screen.dart';

enum _PayMethod { normalCard, corpCard, myCard, naver, kakao }

class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({super.key});

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cardNumCtrl = TextEditingController();
  final _expiryMCtrl = TextEditingController();
  final _expiryYCtrl = TextEditingController();
  final _cardPwCtrl = TextEditingController();

  _PayMethod? _payMethod;

  bool get _isCardPay =>
      _payMethod == _PayMethod.normalCard ||
      _payMethod == _PayMethod.corpCard ||
      _payMethod == _PayMethod.myCard;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cardNumCtrl.dispose();
    _expiryMCtrl.dispose();
    _expiryYCtrl.dispose();
    _cardPwCtrl.dispose();
    super.dispose();
  }

  void _confirm(String lang) {
    if (_payMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.get(lang, 'selectPaymentError')),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<BookingProvider>();
    final booking = provider.createBooking(
      passengerName: _nameCtrl.text.trim(),
      passengerPhone: _phoneCtrl.text.trim(),
    );
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BookingCompleteScreen(booking: booking)));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    return Consumer<BookingProvider>(
      builder: (ctx, provider, _) {
        final bus = provider.selectedBus!;
        final timeFormat = DateFormat('HH:mm');
        final dateFormat = DateFormat(AppStrings.dateFormat(lang));
        final fmt = NumberFormat('#,###');

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text(AppStrings.get(lang, 'bookingConfirm'))),
          body: Form(
            key: _formKey,
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                // ── 여행 정보 ──────────────────────────────
                _SectionCard(
                  title: AppStrings.get(lang, 'tripInfo'),
                  child: _buildTripInfo(bus, timeFormat, dateFormat, provider, lang),
                ),
                const SizedBox(height: 16),

                if (!isLoggedIn) ...[
                  _loginPrompt(lang),
                  const SizedBox(height: 16),
                ] else ...[
                  // ── 탑승객 정보 ─────────────────────────
                  _SectionCard(
                    title: AppStrings.get(lang, 'passengerInfo'),
                    child: _buildPassengerForm(lang),
                  ),
                  const SizedBox(height: 16),

                  // ── 탑승 인원 ───────────────────────────
                  _SectionCard(
                    title: AppStrings.get(lang, 'passengerCount'),
                    child: _buildPassengerCount(provider, bus, fmt, lang),
                  ),
                  const SizedBox(height: 16),

                  // ── 결제 수단 ───────────────────────────
                  _SectionCard(
                    title: AppStrings.get(lang, 'paymentMethod'),
                    child: _buildPaymentMethod(lang),
                  ),
                  const SizedBox(height: 16),

                  // ── 카드 정보 (일반결제 선택 시) ─────────
                  if (_isCardPay) ...[
                    _SectionCard(
                      title: AppStrings.get(lang, 'cardInfo'),
                      child: _buildCardInput(lang),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── 예상 결제금액 ───────────────────────
                  _SectionCard(
                    title: AppStrings.get(lang, 'paymentAmount'),
                    child: _buildPriceSummary(provider, bus, fmt, lang),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _confirm(lang),
                      child: Text(AppStrings.get(lang, 'pay'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 여행 정보 ───────────────────────────────────────────────────────────────

  Widget _buildTripInfo(Bus bus, DateFormat tFmt, DateFormat dFmt,
      BookingProvider provider, String lang) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.get(lang, 'departure'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                  Text(tFmt.format(bus.departureTime),
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text(TerminalNames.translate(bus.from, lang),
                      style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              children: [
                Text(bus.duration,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const Icon(Icons.arrow_forward, color: AppColors.primaryLight),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppStrings.get(lang, 'arrival'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                  Text(tFmt.format(bus.arrivalTime),
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text(TerminalNames.translate(bus.to, lang),
                      style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 24, color: AppColors.divider),
        _InfoRow(label: AppStrings.get(lang, 'date'), value: dFmt.format(bus.departureTime)),
        const SizedBox(height: 8),
        _InfoRow(
            label: AppStrings.get(lang, 'busType'),
            value: '${TerminalNames.translateBusType(bus.busType, lang)} · ${bus.company}'),
        const SizedBox(height: 8),
        _InfoRow(
          label: AppStrings.get(lang, 'seats'),
          value: provider.selectedSeats.map((s) => s.label).join(', '),
        ),
      ],
    );
  }

  // ── 비로그인 안내 ─────────────────────────────────────────────────────────

  Widget _loginPrompt(String lang) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 52, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(AppStrings.get(context.read<LanguageProvider>().langCode, 'loginToBook'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: Text(AppStrings.get(lang, 'goToLogin')),
            ),
          ),
        ],
      ),
    );
  }

  // ── 탑승객 정보 입력 ────────────────────────────────────────────────────────

  Widget _buildPassengerForm(String lang) {
    return Column(
      children: [
        TextFormField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            labelText: AppStrings.get(lang, 'nameLabel'),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? AppStrings.get(lang, 'nameEmpty') : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneCtrl,
          decoration: InputDecoration(
            labelText: AppStrings.get(lang, 'phoneLabel'),
            prefixIcon: const Icon(Icons.phone_outlined),
            hintText: AppStrings.get(lang, 'phoneHint'),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [_PhoneInputFormatter()],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return AppStrings.get(lang, 'phoneEmpty');
            if (!RegExp(r'^\d{3}-\d{4}-\d{4}$').hasMatch(v.trim())) {
              return AppStrings.get(lang, 'phoneFormat');
            }
            return null;
          },
        ),
      ],
    );
  }

  // ── 탑승 인원 ────────────────────────────────────────────────────────────────

  Widget _buildPassengerCount(
      BookingProvider provider, Bus bus, NumberFormat fmt, String lang) {
    final generalPrice = bus.price;
    final studentPrice = (bus.price * 0.8).round();
    final childPrice = (bus.price * 0.5).round();

    final rows = <Widget>[];
    if (provider.generalCount > 0) {
      rows.add(_PassengerCountRow(
        label: AppStrings.get(lang, 'general'),
        count: provider.generalCount,
        unitPrice: generalPrice,
        fmt: fmt,
      ));
    }
    if (provider.studentCount > 0) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 10));
      rows.add(_PassengerCountRow(
        label: AppStrings.get(lang, 'student'),
        count: provider.studentCount,
        unitPrice: studentPrice,
        fmt: fmt,
        discountLabel: '-20%',
      ));
    }
    if (provider.childCount > 0) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 10));
      rows.add(_PassengerCountRow(
        label: AppStrings.get(lang, 'child'),
        count: provider.childCount,
        unitPrice: childPrice,
        fmt: fmt,
        discountLabel: '-50%',
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  // ── 결제 수단 선택 ──────────────────────────────────────────────────────────

  Widget _buildPaymentMethod(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 일반결제
        _PayGroupLabel(label: AppStrings.get(lang, 'generalPayment')),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PayMethodBtn(
                icon: Icons.credit_card_outlined,
                label: AppStrings.get(lang, 'generalCard'),
                selected: _payMethod == _PayMethod.normalCard,
                onTap: () => setState(() => _payMethod = _PayMethod.normalCard),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PayMethodBtn(
                icon: Icons.business_center_outlined,
                label: AppStrings.get(lang, 'corpCard'),
                selected: _payMethod == _PayMethod.corpCard,
                onTap: () => setState(() => _payMethod = _PayMethod.corpCard),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PayMethodBtn(
                icon: Icons.star_outline_rounded,
                label: AppStrings.get(lang, 'myCards'),
                selected: _payMethod == _PayMethod.myCard,
                onTap: () => setState(() => _payMethod = _PayMethod.myCard),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // 간편결제
        _PayGroupLabel(label: AppStrings.get(lang, 'easyPayment')),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _EasyPayBtn(
                label: '네이버페이',
                labelColor: Colors.white,
                bgColor: const Color(0xFF03C75A),
                selected: _payMethod == _PayMethod.naver,
                prefix: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('N',
                      style: TextStyle(
                          color: Color(0xFF03C75A),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                onTap: () => setState(() => _payMethod = _PayMethod.naver),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _EasyPayBtn(
                label: '카카오페이',
                labelColor: const Color(0xFF3C1E1E),
                bgColor: const Color(0xFFFFE600),
                selected: _payMethod == _PayMethod.kakao,
                prefix: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3C1E1E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('K',
                      style: TextStyle(
                          color: Color(0xFF3C1E1E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                onTap: () => setState(() => _payMethod = _PayMethod.kakao),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 카드 정보 입력 ──────────────────────────────────────────────────────────

  Widget _buildCardInput(String lang) {
    return Column(
      children: [
        // 카드번호
        TextFormField(
          controller: _cardNumCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [_CardNumberFormatter()],
          decoration: InputDecoration(
            labelText: AppStrings.get(lang, 'cardNumber'),
            hintText: '0000 - 0000 - 0000 - 0000',
            prefixIcon: const Icon(Icons.credit_card_outlined),
          ),
          validator: (v) {
            final digits = v?.replaceAll(RegExp(r'\D'), '') ?? '';
            if (digits.length != 16) return AppStrings.get(lang, 'cardNumberError');
            return null;
          },
        ),
        const SizedBox(height: 12),

        // 유효기간 월 / 년 / 비밀번호 앞 2자리
        LayoutBuilder(
          builder: (context, constraints) {
            final labelStyle = TextStyle(
              fontSize: (constraints.maxWidth / 3 < 100) ? 11.0 : 13.0,
            );
            final fieldDecoration = InputDecoration(
              isDense: true,
              labelStyle: labelStyle,
              floatingLabelStyle: labelStyle,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            );
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryMCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: fieldDecoration.copyWith(
                      labelText: AppStrings.get(lang, 'expiryMonth'),
                      hintText: 'MM',
                    ),
                    validator: (v) {
                      final m = int.tryParse(v ?? '');
                      if (m == null || m < 1 || m > 12) {
                        return AppStrings.get(lang, 'expiryError');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _expiryYCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: fieldDecoration.copyWith(
                      labelText: AppStrings.get(lang, 'expiryYear'),
                      hintText: 'YY',
                    ),
                    validator: (v) {
                      if ((v ?? '').length != 2) return AppStrings.get(lang, 'expiryError');
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _cardPwCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: fieldDecoration.copyWith(
                      labelText: AppStrings.get(lang, 'cardPw2'),
                      hintText: '••',
                    ),
                    validator: (v) {
                      if ((v ?? '').length != 2) return AppStrings.get(lang, 'cardPwError');
                      return null;
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ── 예상 결제금액 ────────────────────────────────────────────────────────────

  Widget _buildPriceSummary(
      BookingProvider provider, Bus bus, NumberFormat fmt, String lang) {
    final generalPrice = bus.price;
    final studentPrice = (bus.price * 0.8).round();
    final childPrice = (bus.price * 0.5).round();

    return Column(
      children: [
        if (provider.generalCount > 0)
          _PriceRow(
            label:
                '${AppStrings.get(lang, 'general')} × ${provider.generalCount}',
            amount: '${fmt.format(generalPrice * provider.generalCount)}원',
          ),
        if (provider.studentCount > 0) ...[
          if (provider.generalCount > 0) const SizedBox(height: 8),
          _PriceRow(
            label:
                '${AppStrings.get(lang, 'student')} × ${provider.studentCount}',
            amount: '${fmt.format(studentPrice * provider.studentCount)}원',
          ),
        ],
        if (provider.childCount > 0) ...[
          if (provider.generalCount > 0 || provider.studentCount > 0)
            const SizedBox(height: 8),
          _PriceRow(
            label:
                '${AppStrings.get(lang, 'child')} × ${provider.childCount}',
            amount: '${fmt.format(childPrice * provider.childCount)}원',
          ),
        ],
        const Divider(height: 24, color: AppColors.divider),
        Row(
          children: [
            Text(AppStrings.get(lang, 'totalAmount'),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const Spacer(),
            Text('${fmt.format(provider.totalPrice)}원',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
          ],
        ),
      ],
    );
  }
}

// ── 공통 섹션 카드 ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── 여행 정보 행 ───────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

// ── 인원 행 ────────────────────────────────────────────────────────────────────

class _PassengerCountRow extends StatelessWidget {
  final String label;
  final int count;
  final int unitPrice;
  final NumberFormat fmt;
  final String? discountLabel;

  const _PassengerCountRow({
    required this.label,
    required this.count,
    required this.unitPrice,
    required this.fmt,
    this.discountLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ),
        const SizedBox(width: 6),
        Text('$count명',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        if (discountLabel != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(discountLabel!,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935))),
          ),
        ],
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${fmt.format(unitPrice)}원 × $count',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            Text('${fmt.format(unitPrice * count)}원',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }
}

// ── 결제 수단 그룹 레이블 ──────────────────────────────────────────────────────

class _PayGroupLabel extends StatelessWidget {
  final String label;
  const _PayGroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: AppColors.primary),
        const SizedBox(width: 7),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── 일반결제 버튼 ──────────────────────────────────────────────────────────────

class _PayMethodBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PayMethodBtn({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 22,
                color: selected ? AppColors.primary : AppColors.textHint),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 간편결제 버튼 ──────────────────────────────────────────────────────────────

class _EasyPayBtn extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color labelColor;
  final Widget prefix;
  final bool selected;
  final VoidCallback onTap;

  const _EasyPayBtn({
    required this.label,
    required this.bgColor,
    required this.labelColor,
    required this.prefix,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.textPrimary : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: bgColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            prefix,
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: labelColor)),
          ],
        ),
      ),
    );
  }
}

// ── 가격 행 ────────────────────────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  final String label;
  final String amount;
  const _PriceRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const Spacer(),
        Text(amount,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
      ],
    );
  }
}

// ── 포맷터 ─────────────────────────────────────────────────────────────────────

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buf = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 3 || i == 7) buf.write('-');
      buf.write(limited[i]);
    }
    final s = buf.toString();
    return TextEditingValue(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buf = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' - ');
      buf.write(limited[i]);
    }
    final s = buf.toString();
    return TextEditingValue(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}
