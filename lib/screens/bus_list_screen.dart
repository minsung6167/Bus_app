import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/bus_model.dart';
import '../providers/booking_provider.dart';
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
  final int passengerCount;

  const BusListScreen({
    super.key,
    required this.fromTerminalId,
    required this.fromTerminalName,
    required this.toTerminalId,
    required this.toTerminalName,
    required this.date,
    required this.passengerCount,
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

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

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
          _errorMessage = '버스 정보를 불러오지 못했습니다';
          _loading = false;
        });
      }
    }
  }

  List<Bus> get _sortedBuses {
    final sorted = List<Bus>.from(_buses);
    switch (_sortOption) {
      case SortOption.time:
        sorted.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      case SortOption.price:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.seats:
        sorted.sort((a, b) => b.remainingSeats.compareTo(a.remainingSeats));
    }
    return sorted;
  }

  String get _dateLabel {
    final d = _weekdays[widget.date.weekday - 1];
    return '${DateFormat('M월 d일').format(widget.date)} ($d)';
  }

  void _selectBus(Bus bus) {
    context.read<BookingProvider>().selectBus(bus);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const SeatSelectionScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.fromTerminalName} → ${widget.toTerminalName}'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          _buildSubHeader(),
          if (!_loading) _buildSortBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '버스 정보를 불러오는 중...',
              style: TextStyle(color: AppColors.textSecondary),
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
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(_errorMessage!,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBuses,
              child: const Text('다시 시도'),
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
              const Icon(Icons.directions_bus_outlined,
                  size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              const Text(
                '해당 노선의 버스가 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.fromTerminalName}(${widget.fromTerminalId}) → ${widget.toTerminalName}(${widget.toTerminalId})\n다른 날짜나 노선을 선택해보세요',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('돌아가기'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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

  Widget _buildSubHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            _dateLabel,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.person, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            '${widget.passengerCount}명',
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

  Widget _buildSortBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Text(
            '정렬',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: '출발시간',
            selected: _sortOption == SortOption.time,
            onTap: () => setState(() => _sortOption = SortOption.time),
          ),
          const SizedBox(width: 6),
          _SortChip(
            label: '가격순',
            selected: _sortOption == SortOption.price,
            onTap: () => setState(() => _sortOption = SortOption.price),
          ),
          const SizedBox(width: 6),
          _SortChip(
            label: '잔여석순',
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

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
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
