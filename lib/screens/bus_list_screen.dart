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

enum SortOption { time, price, seats }

class _BusListScreenState extends State<BusListScreen> {
  SortOption _sortOption = SortOption.time;
  List<Bus> _buses = [];
  bool _loading = true;
  String? _errorMessage;

  static const _weekdaysKo = ['월', '화', '수', '목', '금', '토', '일'];
  static const _weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _weekdaysZh = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const _weekdaysJa = ['月', '火', '水', '木', '金', '土', '日'];

  @override
  void initState() {
    super.initState();
    _fetchBuses();
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
        date: widget.date,
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
    final filtered = _buses.toList();
    switch (_sortOption) {
      case SortOption.time:
        filtered.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      case SortOption.price:
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.seats:
        filtered.sort((a, b) => b.remainingSeats.compareTo(a.remainingSeats));
    }
    return filtered;
  }

  String _dateLabel(String lang) {
    final idx = widget.date.weekday - 1;
    switch (lang) {
      case 'en':
        return '${DateFormat('MMM d').format(widget.date)} (${_weekdaysEn[idx]})';
      case 'zh':
        return '${DateFormat('M月d日').format(widget.date)} ${_weekdaysZh[idx]}';
      case 'ja':
        return '${DateFormat('M月d日').format(widget.date)} (${_weekdaysJa[idx]})';
      default:
        return '${DateFormat('M월 d일').format(widget.date)} (${_weekdaysKo[idx]})';
    }
  }

  void _selectBus(Bus bus) {
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
          const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            _dateLabel(lang),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
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
          const SizedBox(width: 6),
          _SortChip(
            label: AppStrings.get(lang, 'sortSeats'),
            selected: _sortOption == SortOption.seats,
            onTap: () => setState(() => _sortOption = SortOption.seats),
          ),
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
