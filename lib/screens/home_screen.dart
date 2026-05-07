import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/terminal_model.dart';
import '../services/bus_api_service.dart';
import '../theme/app_theme.dart';
import 'bus_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Terminal? _fromTerminal;
  Terminal? _toTerminal;

  DateTime _selectedDate = DateTime.now();
  int _passengerCount = 1;
  List<Terminal> _terminals = [];
  bool _loadingTerminals = true;

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  void initState() {
    super.initState();
    _loadTerminals();
  }

  Future<void> _loadTerminals() async {
    final terminals = await BusApiService.getTerminals();
    if (mounted) {
      setState(() {
        _terminals = terminals;
        _loadingTerminals = false;
      });
    }
  }

  String get _formattedDate {
    final day = _weekdays[_selectedDate.weekday - 1];
    return '${DateFormat('yyyy년 M월 d일').format(_selectedDate)} ($day)';
  }

  void _swapTerminals() {
    setState(() {
      final temp = _fromTerminal;
      _fromTerminal = _toTerminal;
      _toTerminal = temp;
    });
  }

  Future<void> _selectTerminal(bool isFrom) async {
    if (_terminals.isEmpty) return;
    final exclude = isFrom ? _toTerminal : _fromTerminal;
    final available = _terminals.where((t) => t.id != exclude?.id).toList();

    final selected = await showModalBottomSheet<Terminal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TerminalPickerSheet(
        title: isFrom ? '출발지 선택' : '도착지 선택',
        terminals: available,
      ),
    );
    if (selected != null) {
      setState(() {
        if (isFrom) {
          _fromTerminal = selected;
        } else {
          _toTerminal = selected;
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _search() {
    if (_fromTerminal == null || _toTerminal == null) return;
    if (_fromTerminal!.id == _toTerminal!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('출발지와 도착지가 같습니다')),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BusListScreen(
        fromTerminalId: _fromTerminal!.id,
        fromTerminalName: _fromTerminal!.name,
        toTerminalId: _toTerminal!.id,
        toTerminalName: _toTerminal!.name,
        date: _selectedDate,
        passengerCount: _passengerCount,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchCard(),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPopularRoutes(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_bus,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '버스티켓',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                '어디로 떠나시나요?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '빠르고 편리하게 버스를 예매하세요',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: _loadingTerminals
          ? const SizedBox(
              height: 160,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('터미널 정보를 불러오는 중...'),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TerminalButton(
                        label: '출발지',
                        terminal: _fromTerminal,
                        onTap: () => _selectTerminal(true),
                      ),
                    ),
                    GestureDetector(
                      onTap: _swapTerminals,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.swap_horiz,
                            color: AppColors.primary, size: 20),
                      ),
                    ),
                    Expanded(
                      child: _TerminalButton(
                        label: '도착지',
                        terminal: _toTerminal,
                        onTap: () => _selectTerminal(false),
                        isRight: true,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          _formattedDate,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textHint, size: 20),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Text(
                      '인원',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    _CounterButton(
                      onTap: () {
                        if (_passengerCount > 1) {
                          setState(() => _passengerCount--);
                        }
                      },
                      icon: Icons.remove,
                      enabled: _passengerCount > 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '$_passengerCount명',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _CounterButton(
                      onTap: () {
                        if (_passengerCount < 9) {
                          setState(() => _passengerCount++);
                        }
                      },
                      icon: Icons.add,
                      enabled: _passengerCount < 9,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        (_fromTerminal != null && _toTerminal != null)
                            ? _search
                            : null,
                    icon: const Icon(Icons.search, size: 20),
                    label: const Text('버스 검색하기'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPopularRoutes() {
    final routes = [
      {'from': '서울경부', 'to': '부산'},
      {'from': '서울경부', 'to': '대전복합'},
      {'from': '서울경부', 'to': '광주'},
      {'from': '부산', 'to': '서울경부'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '인기 노선',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: routes.map((route) {
            return GestureDetector(
              onTap: () {
                if (_terminals.isEmpty) return;
                final from = _terminals.firstWhere(
                  (t) => t.name == route['from'],
                  orElse: () => _terminals.first,
                );
                final to = _terminals.firstWhere(
                  (t) => t.name == route['to'],
                  orElse: () => _terminals.last,
                );
                setState(() {
                  _fromTerminal = from;
                  _toTerminal = to;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      route['from']!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.arrow_forward,
                          size: 12, color: AppColors.primary),
                    ),
                    Text(
                      route['to']!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TerminalButton extends StatelessWidget {
  final String label;
  final Terminal? terminal;
  final VoidCallback onTap;
  final bool isRight;

  const _TerminalButton({
    required this.label,
    required this.terminal,
    required this.onTap,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment:
            isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
          const SizedBox(height: 2),
          Text(
            terminal?.name ?? '선택',
            style: TextStyle(
              fontSize: terminal != null ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: terminal != null
                  ? AppColors.textPrimary
                  : AppColors.textHint,
            ),
          ),
          if (terminal != null)
            Text(
              terminal!.cityName,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final bool enabled;

  const _CounterButton({
    required this.onTap,
    required this.icon,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.divider,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.textHint,
        ),
      ),
    );
  }
}

class _TerminalPickerSheet extends StatefulWidget {
  final String title;
  final List<Terminal> terminals;

  const _TerminalPickerSheet({
    required this.title,
    required this.terminals,
  });

  @override
  State<_TerminalPickerSheet> createState() => _TerminalPickerSheetState();
}

class _TerminalPickerSheetState extends State<_TerminalPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.terminals
        .where((t) =>
            t.name.contains(_query) || t.cityName.contains(_query))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: '터미널 검색',
              prefixIcon: Icon(Icons.search, size: 20),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final t = filtered[i];
                return ListTile(
                  onTap: () => Navigator.of(ctx).pop(t),
                  title: Text(
                    t.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    t.cityName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.textHint, size: 18),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
