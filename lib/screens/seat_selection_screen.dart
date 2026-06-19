import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../l10n/terminal_names.dart';
import '../models/seat_model.dart';
import '../providers/booking_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../services/time_service.dart';
import '../widgets/seat_widget.dart';
import 'booking_confirm_screen.dart';

// 유형 선택 팝업
void showPassengerTypePicker(
  BuildContext context,
  Seat seat,
  BookingProvider provider,
  String lang,
) {
  final base = provider.selectedBus!.price;
  final fmt = NumberFormat('#,###');

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.fmt(lang, 'passengerTypePicker', {'seat': seat.label}),
            style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _TypeOption(
            label: AppStrings.get(lang, 'general'),
            desc: AppStrings.get(lang, 'generalDesc'),
            price: '${fmt.format(base)}원',
            color: AppColors.primary,
            onTap: () { provider.selectSeat(seat, PassengerType.general); Navigator.pop(context); },
          ),
          const SizedBox(height: 8),
          _TypeOption(
            label: AppStrings.get(lang, 'student'),
            desc: AppStrings.get(lang, 'studentDesc'),
            price: '${fmt.format((base * 0.8).round())}원',
            color: const Color(0xFF7C3AED),
            onTap: () { provider.selectSeat(seat, PassengerType.student); Navigator.pop(context); },
          ),
          const SizedBox(height: 8),
          _TypeOption(
            label: AppStrings.get(lang, 'child'),
            desc: AppStrings.get(lang, 'childDesc'),
            price: '${fmt.format((base * 0.5).round())}원',
            color: const Color(0xFFD97706),
            onTap: () { provider.selectSeat(seat, PassengerType.child); Navigator.pop(context); },
          ),
        ],
      ),
    ),
  );
}

class _TypeOption extends StatelessWidget {
  final String label;
  final String desc;
  final String price;
  final Color color;
  final VoidCallback onTap;

  const _TypeOption({
    required this.label,
    required this.desc,
    required this.price,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(desc,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
            Text(price,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class SeatSelectionScreen extends StatelessWidget {
  const SeatSelectionScreen({super.key});

  void _showBookingGuide(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dragHandle(),
            const SizedBox(height: 16),
            Text(
              AppStrings.get(lang, 'bookingGuideTitle'),
              style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              ),
              title: Text(AppStrings.get(lang, 'bookingConditions'),
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
              onTap: () {
                Navigator.pop(context);
                _showBookingConditions(context, lang);
              },
            ),
            const Divider(height: 1, color: AppColors.divider),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long_outlined, color: Color(0xFFE53935), size: 20),
              ),
              title: Text(AppStrings.get(lang, 'cancellationInfo'),
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
              onTap: () {
                Navigator.pop(context);
                _showCancellationInfo(context, lang);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingConditions(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _sheetHeader(AppStrings.get(lang, 'bookingConditions')),
              Expanded(
                child: ListView(
                  controller: sc,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    const Text(
                      '만 6세 미만의 아동은 무임입니다.',
                      style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
                    ),
                    const Text(
                      '(단 만 6세 미만의 아동이라도 좌석을 요구할 경우 아동 승차권 구입 후 승차 바랍니다.)',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                    ),
                    const Text(
                      '- 아동: 50% 할인\n- 만 6세 이상 ~ 만 13세 미만\n- 일부 터미널 제외',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '중고생은 현장 발권 및 승차 시 학생증(청소년증) 지참 바랍니다.',
                      style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
                    ),
                    const Text(
                      '- 중고생: 20% 할인\n- 만 13세 이상 ~ 만 18세 이하\n- 중고생 할인 시 학생증(청소년증) 필수 지참 (일부 터미널 제외)',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Text(
                        '※ 상기 운임은 대중교통 청소년 요금관련 권고 사항을 기준으로 적용되었으며, 각 지역 터미널 운영 방침에 따라 할인 운임기준이 상이할 수 있으니 이점 양해 부탁드립니다.',
                        style: TextStyle(fontSize: 12, color: AppColors.textHint, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '일부 터미널 사정에 따라 중고생 예매가 불가한 터미널 있습니다.\n'
                      '당일 출발하는 차량의 출발시간 20분 이전까지 예매가 가능합니다.\n'
                      '인터넷을 이용한 예매 후 취소 및 수정은 인터넷으로만 가능합니다.\n'
                      '(해당 터미널 창구에서 취소 및 수정불가)\n'
                      '종이 승차권 발권 시 버스타고에서는 예매 변경 및 취소가 불가합니다.\n'
                      '[중고생] 요금으로 예매 후 승차 시에는 학생증(청소년증)을 지참하셔야 합니다.\n'
                      '예매(또는 취소)단계 에서 회선장애나 기타 통신장애 발생 시 예매(취소)여부를 조회를 통해 반드시 직접, 확인하셔야 합니다. 확인하시지 않으신 경우에 부도위약금이 청구될 수 있으니 유의하시기 바랍니다.\n'
                      '소요시간은 도로사정과 버스회사의 사정에 따라 변경될 수 있습니다.\n'
                      '선택하신 좌석은 실제 좌석과 상이 할 수 있습니다.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancellationInfo(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _sheetHeader(AppStrings.get(lang, 'cancellationInfo')),
              Expanded(
                child: ListView(
                  controller: sc,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    _sectionTitle(AppStrings.get(lang, 'cancellationFee')),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.get(lang, 'cancellationFeeSubtitle'),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    _buildCancellationTable(lang),
                    const SizedBox(height: 24),
                    _sectionTitle(AppStrings.get(lang, 'penalty')),
                    const SizedBox(height: 10),
                    _buildPenaltyTable(lang),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancellationTable(String lang) {
    final beforeDep = AppStrings.get(lang, 'beforeDep');
    final afterDep = AppStrings.get(lang, 'afterDep');

    return Table(
      border: TableBorder.all(color: const Color(0xFFDDDDDD)),
      columnWidths: const {
        0: FlexColumnWidth(2.5),
        1: FlexColumnWidth(1.3),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
      },
      children: [
        _feeHeaderRow(['취소시기', '월~목', '금~일\n공휴일', '명절*\n(설·추석)']),
        _feeSectionRow(beforeDep),
        _feeRow(['2일 전', '0%', '0%', '0%'], red: false),
        _feeRow(['1일전~\n3시간 이전', '5%', '7.5%', '10%']),
        _feeRow(['3시간 미만~\n출발 전', '10%', '15%', '20%']),
        _feeSectionRow(afterDep),
        _feeRow(['출발 후~\n1시간 이전', '40%', '40%', '40%']),
        _feeRow(['1시간 초과~\n4시간 이전**', '50%~70%', '50%~70%', '50%~70%']),
        _feeRow(['4시간 초과', '100%', '100%', '100%']),
      ],
    );
  }

  TableRow _feeHeaderRow(List<String> labels) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
      children: labels.map((l) => TableCell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Text(l,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
        ),
      )).toList(),
    );
  }

  TableRow _feeSectionRow(String label) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFFFF3F3)),
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
          ),
        ),
        const TableCell(child: SizedBox()),
        const TableCell(child: SizedBox()),
        const TableCell(child: SizedBox()),
      ],
    );
  }

  TableRow _feeRow(List<String> cells, {bool red = true}) {
    return TableRow(
      children: cells.asMap().entries.map((e) {
        final isFirst = e.key == 0;
        return TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Text(e.value,
              textAlign: isFirst ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: (!isFirst && red) ? const Color(0xFFE53935) : AppColors.textPrimary,
                fontWeight: isFirst ? FontWeight.normal : FontWeight.w500,
              )),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPenaltyTable(String lang) {
    return Table(
      border: TableBorder.all(color: const Color(0xFFDDDDDD)),
      columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1)},
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
          children: [
            TableCell(child: Padding(padding: const EdgeInsets.all(8),
              child: Text(AppStrings.get(lang, 'penaltyTime'), textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)))),
            TableCell(child: Padding(padding: const EdgeInsets.all(8),
              child: Text(AppStrings.get(lang, 'penaltyFee'), textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)))),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.get(lang, 'penaltyAfter4h'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(AppStrings.get(lang, 'penaltyNote'),
                      style: const TextStyle(fontSize: 11, color: Color(0xFFE53935), height: 1.4)),
                    const SizedBox(height: 6),
                    Text(AppStrings.get(lang, 'penaltyDesc'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5)),
                  ],
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: const Text('100%', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (ctx, provider, _) {
        final lang = ctx.watch<LanguageProvider>().langCode;
        final bus = provider.selectedBus!;
        final minutesLeft = bus.departureTime.difference(TimeService.now()).inMinutes;
        final isOnsite = minutesLeft <= 20;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('${AppStrings.get(lang, 'seatSelectTitle')} · ${TerminalNames.translateBusType(bus.busType, lang)}'),
            actions: [
              if (provider.selectedSeats.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: AppStrings.get(lang, 'resetTooltip'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(AppStrings.get(lang, 'resetTitle')),
                        content: Text(AppStrings.get(lang, 'resetContent')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppStrings.get(lang, 'cancel')),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.clearSelection();
                              Navigator.pop(context);
                            },
                            child: Text(
                              AppStrings.get(lang, 'resetConfirm'),
                              style: const TextStyle(color: Color(0xFFE53935)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              TextButton(
                onPressed: () => _showBookingGuide(context, lang),
                child: Text(
                  AppStrings.get(lang, 'bookingGuideBtn'),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (isOnsite) _buildOnsiteNotice(lang),
                      if (!isOnsite) _buildLegend(lang),
                      const SizedBox(height: 20),
                      _buildBusFront(lang),
                      const SizedBox(height: 8),
                      _buildSeatMap(provider, context, lang),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.get(lang, 'seatNote'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(context, provider, isOnsite, lang),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOnsiteNotice(String lang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.orange.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.get(lang, 'onsiteNotice'),
              style: TextStyle(fontSize: 13, color: Colors.orange.shade700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: AppColors.seatAvailable,
          borderColor: AppColors.seatAvailableBorder,
          label: AppStrings.get(lang, 'legendAvailable'),
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: AppColors.seatOccupied,
          borderColor: AppColors.seatOccupiedBorder,
          label: AppStrings.get(lang, 'legendOccupied'),
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: AppColors.seatSelected,
          borderColor: AppColors.seatSelected,
          label: AppStrings.get(lang, 'legendSelected'),
          textColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildBusFront(String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_bus, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            AppStrings.get(lang, 'driverSeat'),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatMap(BookingProvider provider, BuildContext context, String lang) {
    final bus = provider.selectedBus!;
    final rows = _getRows(bus.busType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          _buildColumnHeader(bus.busType),
          const SizedBox(height: 8),
          ...List.generate(rows, (i) => _buildSeatRow(i + 1, provider, context, lang)),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String busType) {
    final List<String> leftCols;
    final List<String> rightCols;
    if (busType == '일반') { leftCols = ['A', 'B']; rightCols = ['C', 'D']; }
    else if (busType == '우등') { leftCols = ['A']; rightCols = ['B', 'C']; }
    else { leftCols = ['A']; rightCols = ['B']; }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 24),
        ...leftCols.map((c) => SizedBox(width: 50,
          child: Center(child: Text(c,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))))),
        const SizedBox(width: 28),
        ...rightCols.map((c) => SizedBox(width: 50,
          child: Center(child: Text(c,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))))),
      ],
    );
  }

  Widget _buildSeatRow(int rowNum, BookingProvider provider, BuildContext context, String lang) {
    final busType = provider.selectedBus!.busType;
    final rowSeats = provider.seats.where((s) => s.row == rowNum).toList();

    final List<Seat> leftSeats;
    final List<Seat> rightSeats;
    if (busType == '일반') {
      leftSeats = rowSeats.where((s) => s.column == 'A' || s.column == 'B').toList();
      rightSeats = rowSeats.where((s) => s.column == 'C' || s.column == 'D').toList();
    } else if (busType == '우등') {
      leftSeats = rowSeats.where((s) => s.column == 'A').toList();
      rightSeats = rowSeats.where((s) => s.column == 'B' || s.column == 'C').toList();
    } else {
      leftSeats = rowSeats.where((s) => s.column == 'A').toList();
      rightSeats = rowSeats.where((s) => s.column == 'B').toList();
    }

    void onSeatTap(Seat seat) {
      if (seat.isSelected) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),
                Text(
                  AppStrings.fmt(lang, 'selectedSeat', {'seat': seat.label, 'type': seat.passengerTypeShort}),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
                  title: Text(AppStrings.get(lang, 'changeType')),
                  onTap: () {
                    Navigator.pop(context);
                    showPassengerTypePicker(context, seat, provider, lang);
                  },
                ),
                const Divider(height: 1, color: AppColors.divider),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.remove_circle_outline, color: Color(0xFFE53935)),
                  title: Text(AppStrings.get(lang, 'deselect'),
                    style: const TextStyle(color: Color(0xFFE53935))),
                  onTap: () {
                    provider.deselectSeat(seat);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      } else {
        showPassengerTypePicker(context, seat, provider, lang);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          child: Text('$rowNum',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        ),
        ...leftSeats.map((seat) => SeatWidget(seat: seat, onTap: () => onSeatTap(seat))),
        const SizedBox(width: 28),
        ...rightSeats.map((seat) => SeatWidget(seat: seat, onTap: () => onSeatTap(seat))),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, BookingProvider provider, bool isOnsite, String lang) {
    const boxDeco = BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, -2))],
    );

    if (isOnsite) {
      return Container(
        decoration: boxDeco,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
            ),
            child: Text(AppStrings.get(lang, 'onsiteTicket')),
          ),
        ),
      );
    }

    final fmt = NumberFormat('#,###');
    final hasSelection = provider.selectedSeats.isNotEmpty;
    final general = provider.generalCount;
    final student = provider.studentCount;
    final child = provider.childCount;

    return Container(
      decoration: boxDeco,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasSelection) ...[
            Row(
              children: [
                if (general > 0) _countChip(AppStrings.get(lang, 'general'), general, AppColors.primary, lang),
                if (student > 0) _countChip(AppStrings.get(lang, 'student'), student, const Color(0xFF7C3AED), lang),
                if (child > 0) _countChip(AppStrings.get(lang, 'child'), child, const Color(0xFFD97706), lang),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(AppStrings.get(lang, 'estimatedPrice'),
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const Spacer(),
                Text('${fmt.format(provider.totalPrice)}원',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasSelection
                  ? () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookingConfirmScreen())); }
                  : null,
              child: Text(
                hasSelection
                    ? AppStrings.fmt(lang, 'bookNSeats', {'n': '${provider.selectedSeats.length}'})
                    : AppStrings.get(lang, 'selectSeatHint'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _countChip(String label, int count, Color color, String lang) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text('$label $count명',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  int _getRows(String busType) {
    switch (busType) {
      case '일반': return 11;
      case '우등': return 9;
      case '프리미엄': return 10;
      default: return 11;
    }
  }

  static Widget _dragHandle() => Container(
    width: 40, height: 4,
    decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
  );

  static Widget _sheetHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Column(
      children: [
        _dragHandle(),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: 12),
      ],
    ),
  );

  static Widget _sectionTitle(String title) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
  );
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;
  final Color textColor;

  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
    this.textColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: textColor)),
      ],
    );
  }
}
