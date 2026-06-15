import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../l10n/terminal_names.dart';
import '../models/bus_model.dart';
import '../providers/booking_provider.dart';
import '../providers/language_provider.dart';
import '../services/bus_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bus_card.dart';
import 'seat_selection_screen.dart';

class BusListScreen extends StatefulWidget {
  final String fromTerminalId;
  final String fromTerminalName;
  final String toTerminalId;
  final String toTerminalName;
  final DateTime date;

  const BusListScreen({
    super.key,
    required this.fromTerminalId,
    required this.fromTerminalName,
    required this.toTerminalId,
    required this.toTerminalName,
    required this.date,
  });

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

enum SortOption { time, price }

class _BusListScreenState extends State<BusListScreen> {
  SortOption _sortOption = SortOption.time;
  List<Bus> _buses = [];
  bool _loading = true;
  String? _errorMessage;
  late DateTime _selectedDate;
  Timer? _refreshTimer;

  static const _weekdaysKo = ['월', '화', '수', '목', '금', '토', '일'];
  static const _weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _weekdaysZh = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const _weekdaysJa = ['月', '火', '水', '木', '金', '土', '日'];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
    _fetchBuses();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickDate(String lang) async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomDatePicker(initialDate: _selectedDate),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchBuses();
    }
  }

  Future<void> _fetchBuses() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final buses = await BusApiService.getSchedules(
        depTerminalId: widget.fromTerminalId,
        arrTerminalId: widget.toTerminalId,
        depTerminalName: widget.fromTerminalName,
        arrTerminalName: widget.toTerminalName,
        date: _selectedDate,
      );
      if (mounted) {
        setState(() {
          _buses = buses;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<Bus> get _sortedBuses {
    final buses = List<Bus>.from(_buses);
    switch (_sortOption) {
      case SortOption.time:
        buses.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      case SortOption.price:
        buses.sort((a, b) {
          final cmp = a.price.compareTo(b.price);
          return cmp != 0 ? cmp : a.departureTime.compareTo(b.departureTime);
        });
    }
    return buses;
  }

  String _dateLabel(String lang) {
    final idx = _selectedDate.weekday - 1;
    switch (lang) {
      case 'en':
        return '${DateFormat('MMM d').format(_selectedDate)} (${_weekdaysEn[idx]})';
      case 'zh':
        return '${DateFormat('M月d日').format(_selectedDate)} ${_weekdaysZh[idx]}';
      case 'ja':
        return '${DateFormat('M月d日').format(_selectedDate)} (${_weekdaysJa[idx]})';
      default:
        return '${DateFormat('M월 d일').format(_selectedDate)} (${_weekdaysKo[idx]})';
    }
  }

  Future<void> _selectBus(Bus bus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _MobileTicketDialog(),
    );
    if (confirmed != true || !mounted) return;
    context.read<BookingProvider>().selectBus(bus);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const SeatSelectionScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${TerminalNames.translate(widget.fromTerminalName, lang)} → ${TerminalNames.translate(widget.toTerminalName, lang)}',
        ),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          _buildSubHeader(lang),
          if (!_loading) _buildSortBar(lang),
          Expanded(child: _buildBody(lang)),
        ],
      ),
    );
  }

  Widget _buildBody(String lang) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              AppStrings.get(lang, 'loadingBuses'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(AppStrings.get(lang, 'loadingBusesError'),
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBuses,
              child: Text(AppStrings.get(lang, 'retry')),
            ),
          ],
        ),
      );
    }

    if (_sortedBuses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.directions_bus_outlined, size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text(
                AppStrings.get(lang, 'noBuses'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${TerminalNames.translate(widget.fromTerminalName, lang)} → ${TerminalNames.translate(widget.toTerminalName, lang)}\n${AppStrings.get(lang, 'noBusesHint')}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textHint),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text(AppStrings.get(lang, 'goBack')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBuses,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: _sortedBuses.length,
        itemBuilder: (ctx, i) => BusCard(
          bus: _sortedBuses[i],
          onSelect: () => _selectBus(_sortedBuses[i]),
        ),
      ),
    );
  }

  Widget _buildSubHeader(String lang) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickDate(lang),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  _dateLabel(lang),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white70),
              ],
            ),
          ),
          const Spacer(),
          if (!_loading)
            Text(
              '${_buses.length}편',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortBar(String lang) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            AppStrings.get(lang, 'sort'),
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: AppStrings.get(lang, 'sortTime'),
            selected: _sortOption == SortOption.time,
            onTap: () => setState(() => _sortOption = SortOption.time),
          ),
          const SizedBox(width: 6),
          _SortChip(
            label: AppStrings.get(lang, 'sortPrice'),
            selected: _sortOption == SortOption.price,
            onTap: () => setState(() => _sortOption = SortOption.price),
          ),
        ],
      ),
    );
  }
}

class _MobileTicketDialog extends StatelessWidget {
  const _MobileTicketDialog();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get(lang, 'mobileTicketGuideTitle'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Container(height: 2, color: Colors.red),
              const SizedBox(height: 60),
              Text(
                AppStrings.get(lang, 'mobileTicketGuideBody'),
                style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6),
              ),
              const SizedBox(height: 80),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    AppStrings.get(lang, 'confirm'),
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  const _CustomDatePicker({required this.initialDate});

  @override
  State<_CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<_CustomDatePicker> {
  late int _year;
  late int _month;
  int? _selectedDay;
  bool _showDays = false;

  static const _months = ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'];
  static const _weekdays = ['일','월','화','수','목','금','토'];

  @override
  void initState() {
    super.initState();
    _year = widget.initialDate.year;
    _month = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
  }

  int get _daysInMonth => DateTime(_year, _month + 1, 0).day;
  int get _firstWeekday => DateTime(_year, _month, 1).weekday % 7;

  bool _isSelectable(int day) {
    final date = DateTime(_year, _month, day);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final maxDate = todayDate.add(const Duration(days: 60));
    return !date.isBefore(todayDate) && !date.isAfter(maxDate);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),

          // 헤더: 년도 + 좌우 화살표
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() { _year--; _showDays = false; }),
              ),
              GestureDetector(
                onTap: () => setState(() => _showDays = false),
                child: Text('$_year년', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() { _year++; _showDays = false; }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!_showDays) ...[
            // 월 선택 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (_, i) {
                final isSelected = (i + 1) == _month;
                return GestureDetector(
                  onTap: () => setState(() { _month = i + 1; _selectedDay = null; _showDays = true; }),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                    ),
                    child: Text(_months[i],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      )),
                  ),
                );
              },
            ),
          ] else ...[
            // 월 헤더 (탭하면 다시 월 선택)
            GestureDetector(
              onTap: () => setState(() => _showDays = false),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${_months[_month - 1]}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const Icon(Icons.arrow_drop_up, color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 요일 헤더
            Row(
              children: _weekdays.map((d) => Expanded(
                child: Center(child: Text(d,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: d == '일' ? Colors.red : d == '토' ? Colors.blue : AppColors.textSecondary))),
              )).toList(),
            ),
            const SizedBox(height: 8),

            // 날짜 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.1,
              ),
              itemCount: _firstWeekday + _daysInMonth,
              itemBuilder: (_, i) {
                if (i < _firstWeekday) return const SizedBox();
                final day = i - _firstWeekday + 1;
                final selectable = _isSelectable(day);
                final isSelected = day == _selectedDay;
                final col = i % 7;
                Color textColor = col == 0 ? Colors.red : col == 6 ? Colors.blue : AppColors.textPrimary;
                if (!selectable) textColor = AppColors.textHint;

                return GestureDetector(
                  onTap: selectable ? () {
                    final date = DateTime(_year, _month, day);
                    Navigator.of(context).pop(date);
                  } : null,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : textColor,
                      )),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
