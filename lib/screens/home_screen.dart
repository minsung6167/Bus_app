import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../l10n/terminal_names.dart';
import '../models/terminal_model.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/language_provider.dart';
import '../services/bus_api_service.dart';
import '../services/time_service.dart';
import '../theme/app_theme.dart';
import 'bus_list_screen.dart';
import 'coupon_screen.dart';
import 'event_screen.dart';
import 'favorite_terminals_screen.dart';
import 'my_bookings_screen.dart';
import 'my_cards_screen.dart';
import 'notice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Terminal? _fromTerminal;
  Terminal? _toTerminal;

  DateTime _selectedDate = DateTime(TimeService.now().year, TimeService.now().month, TimeService.now().day);
  List<Terminal> _terminals = [];
  bool _loadingTerminals = true;
  final ScrollController _scrollController = ScrollController();

  static const _weekdaysKo = ['월', '화', '수', '목', '금', '토', '일'];
  static const _weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _weekdaysZh = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const _weekdaysJa = ['月', '火', '水', '木', '金', '土', '日'];

  @override
  void initState() {
    super.initState();
    _loadTerminals();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  String _formattedDate(String lang) {
    final idx = _selectedDate.weekday - 1;
    final String day;
    final String datePart;
    switch (lang) {
      case 'en':
        day = _weekdaysEn[idx];
        datePart = DateFormat('MMM d, yyyy').format(_selectedDate);
        return '$datePart ($day)';
      case 'zh':
        day = _weekdaysZh[idx];
        datePart = DateFormat('yyyy年M月d日').format(_selectedDate);
        return '$datePart $day';
      case 'ja':
        day = _weekdaysJa[idx];
        datePart = DateFormat('yyyy年M月d日').format(_selectedDate);
        return '$datePart ($day)';
      default:
        day = _weekdaysKo[idx];
        datePart = DateFormat('yyyy년 M월 d일').format(_selectedDate);
        return '$datePart ($day)';
    }
  }

  Terminal? _findTerminal(String name) {
    if (_terminals.isEmpty) return null;
    // 완전 일치
    try { return _terminals.firstWhere((t) => t.name == name); } catch (_) {}
    // 포함 탐색 (긴 키 우선)
    final matches = _terminals
        .where((t) => t.name.contains(name) || name.contains(t.name))
        .toList()
      ..sort((a, b) => b.name.length.compareTo(a.name.length));
    return matches.isNotEmpty ? matches.first : null;
  }

  void setFromTerminal(Terminal terminal) {
    setState(() => _fromTerminal = terminal);
  }

  void _swapTerminals() {
    setState(() {
      final temp = _fromTerminal;
      _fromTerminal = _toTerminal;
      _toTerminal = temp;
    });
  }

  Future<void> _selectTerminal(bool isFrom, String lang) async {
    if (_terminals.isEmpty) return;
    final exclude = isFrom ? _toTerminal : _fromTerminal;
    final available = _terminals.where((t) => t.id != exclude?.id).toList();

    final selected = await showModalBottomSheet<Terminal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TerminalPickerSheet(
        title: isFrom
            ? AppStrings.get(lang, 'selectFrom')
            : AppStrings.get(lang, 'selectTo'),
        hintText: AppStrings.get(lang, 'searchTerminal'),
        lang: lang,
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
    final today = DateTime(TimeService.now().year, TimeService.now().month, TimeService.now().day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _search(String lang) {
    if (_fromTerminal == null || _toTerminal == null) return;
    if (_fromTerminal!.id == _toTerminal!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get(lang, 'sameTerminalError'))),
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
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;

    return Scaffold(
      endDrawer: _AppDrawer(onFavoriteSelected: setFromTerminal),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, lang),
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchCard(lang),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPopularRoutes(lang),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String lang) {
    final user = context.watch<AuthProvider>().currentUser;

    return Container(
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 52),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  Text(
                    AppStrings.get(lang, 'appTitle'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu_rounded,
                          color: Colors.white, size: 26),
                      onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                      tooltip: AppStrings.get(lang, 'sidebarMenu'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (user != null)
                Text(
                  AppStrings.fmt(lang, 'welcomeUser', {'name': user.name}),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              const SizedBox(height: 2),
              Text(
                AppStrings.get(lang, 'headerTitle'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.get(lang, 'headerSubtitle'),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard(String lang) {
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
          ? SizedBox(
              height: 160,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(AppStrings.get(lang, 'loadingTerminals')),
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
                        label: AppStrings.get(lang, 'labelFrom'),
                        selectLabel: AppStrings.get(lang, 'select'),
                        terminal: _fromTerminal,
                        lang: lang,
                        onTap: () => _selectTerminal(true, lang),
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
                        label: AppStrings.get(lang, 'labelTo'),
                        selectLabel: AppStrings.get(lang, 'select'),
                        terminal: _toTerminal,
                        lang: lang,
                        onTap: () => _selectTerminal(false, lang),
                        isRight: true,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
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
                            _formattedDate(lang),
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
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_fromTerminal != null && _toTerminal != null)
                        ? () => _search(lang)
                        : null,
                    icon: const Icon(Icons.search, size: 20),
                    label: Text(AppStrings.get(lang, 'btnSearch')),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPopularRoutes(String lang) {
    final routes = [
      {'from': '서울남부', 'to': '부산서부(사상)'},
      {'from': '서울남부', 'to': '통영터미널'},
      {'from': '동서울', 'to': '강릉'},
      {'from': '동서울', 'to': '속초'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            AppStrings.get(lang, 'popularRoutes'),
            style: const TextStyle(
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
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  if (_loadingTerminals) {
                    await Future.delayed(const Duration(milliseconds: 500));
                  }
                  final from = _findTerminal(route['from']!);
                  final to = _findTerminal(route['to']!);
                  if (from == null || to == null) return;
                  setState(() {
                    _fromTerminal = from;
                    _toTerminal = to;
                  });
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  );
                },
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TerminalNames.translate(route['from']!, lang),
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
                      TerminalNames.translate(route['to']!, lang),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
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
  final String selectLabel;
  final Terminal? terminal;
  final VoidCallback onTap;
  final String lang;
  final bool isRight;

  const _TerminalButton({
    required this.label,
    required this.selectLabel,
    required this.terminal,
    required this.onTap,
    required this.lang,
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
            terminal != null
                ? TerminalNames.translate(terminal!.name, lang)
                : selectLabel,
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
              TerminalNames.translateCity(terminal!.cityName, lang),
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

// 터미널 이름 앞에 도 이름이 붙은 경우(경기광주, 충북청주 등) API cityName 대신
// 이름 기반으로 올바른 행정 지역을 반환한다.
String _resolveRegion(Terminal t) {
  const provincePrefixes = ['경기', '강원', '충북', '충남', '전북', '전남', '경북', '경남'];
  for (final prefix in provincePrefixes) {
    if (t.name.startsWith(prefix)) return prefix;
  }
  return t.cityName;
}

class _TerminalPickerSheet extends StatefulWidget {
  final String title;
  final String hintText;
  final String lang;
  final List<Terminal> terminals;

  const _TerminalPickerSheet({
    required this.title,
    required this.hintText,
    required this.lang,
    required this.terminals,
  });

  @override
  State<_TerminalPickerSheet> createState() => _TerminalPickerSheetState();
}

class _TerminalPickerSheetState extends State<_TerminalPickerSheet>
    with SingleTickerProviderStateMixin {
  String _query = '';
  late TabController _tabController;

  static const _top10Names = [
    '서울남부',
    '동서울',
    '서울고속버스터미널(경부)',
    '서울고속버스터미널(호남)',
    '부산종합',
    '대전복합',
    '광주(유·스퀘어)',
    '인천',
    '수원터미널',
    '청주',
  ];

  static const _regionOrder = [
    '서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산',
    '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주', '세종',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Terminal> _getTop10() {
    final nameIndex = {for (int i = 0; i < _top10Names.length; i++) _top10Names[i]: i};
    final matched = widget.terminals
        .where((t) => nameIndex.containsKey(t.name))
        .toList()
      ..sort((a, b) =>
          (nameIndex[a.name] ?? 99).compareTo(nameIndex[b.name] ?? 99));
    return matched;
  }

  Map<String, List<Terminal>> _groupByRegion() {
    final map = <String, List<Terminal>>{};
    for (final t in widget.terminals) {
      (map[_resolveRegion(t)] ??= []).add(t);
    }
    return map;
  }

  List<String> _sortedRegions(Map<String, List<Terminal>> grouped) {
    final ordered = _regionOrder.where((r) => grouped.containsKey(r)).toList();
    final others = grouped.keys.where((k) => !_regionOrder.contains(k)).toList()..sort();
    return [...ordered, ...others];
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final favProvider = context.watch<FavoriteProvider>();
    final isSearching = _query.isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
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
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          if (!isSearching) ...[
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              tabs: [
                Tab(text: AppStrings.get(lang, 'tabTop10')),
                Tab(text: AppStrings.get(lang, 'tabByRegion')),
                Tab(text: AppStrings.get(lang, 'favorites')),
              ],
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTop10Tab(lang, favProvider),
                  _buildByRegionTab(lang, favProvider),
                  _buildFavoritesTab(lang, favProvider),
                ],
              ),
            ),
          ] else
            Expanded(child: _buildSearchResults(lang, favProvider)),
        ],
      ),
    );
  }

  Widget _buildTop10Tab(String lang, FavoriteProvider favProvider) {
    final top10 = _getTop10();
    if (top10.isEmpty) {
      return Center(
        child: Text(
          AppStrings.get(lang, 'loadingTerminals'),
          style: const TextStyle(color: AppColors.textHint),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: top10.length,
      itemBuilder: (ctx, i) {
        final t = top10[i];
        return _TerminalTile(
          terminal: t,
          lang: lang,
          rank: i + 1,
          isFavorite: favProvider.isFavorite(t.id),
          onTap: () => Navigator.of(ctx).pop(t),
          onToggle: () => favProvider.toggle(t),
        );
      },
    );
  }

  Widget _buildFavoritesTab(String lang, FavoriteProvider favProvider) {
    final favTerminals =
        widget.terminals.where((t) => favProvider.isFavorite(t.id)).toList();
    if (favTerminals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_outline_rounded, size: 52, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              AppStrings.get(lang, 'noFavoritesHint'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: favTerminals.length,
      itemBuilder: (ctx, i) {
        final t = favTerminals[i];
        return _TerminalTile(
          terminal: t,
          lang: lang,
          isFavorite: true,
          onTap: () => Navigator.of(ctx).pop(t),
          onToggle: () => favProvider.toggle(t),
        );
      },
    );
  }

  Widget _buildByRegionTab(String lang, FavoriteProvider favProvider) {
    final grouped = _groupByRegion();
    final regions = _sortedRegions(grouped);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: regions.length,
      itemBuilder: (ctx, ri) {
        final region = regions[ri];
        final terminals = grouped[region]!;
        final cityLabel = TerminalNames.translateCity(region, lang);
        return Theme(
          data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            childrenPadding: EdgeInsets.zero,
            leading: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  cityLabel.isNotEmpty ? cityLabel[0] : '?',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Text(
                  cityLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${terminals.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            children: terminals
                .map((t) => _TerminalTile(
                      terminal: t,
                      lang: lang,
                      isFavorite: favProvider.isFavorite(t.id),
                      onTap: () => Navigator.of(ctx).pop(t),
                      onToggle: () => favProvider.toggle(t),
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(String lang, FavoriteProvider favProvider) {
    final filtered = widget.terminals.where((t) {
      final translated = TerminalNames.translate(t.name, lang);
      final translatedCity = TerminalNames.translateCity(t.cityName, lang);
      return t.name.contains(_query) ||
          t.cityName.contains(_query) ||
          translated.toLowerCase().contains(_query.toLowerCase()) ||
          translatedCity.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          AppStrings.get(lang, 'noSearchResults'),
          style: const TextStyle(color: AppColors.textHint, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        final t = filtered[i];
        return _TerminalTile(
          terminal: t,
          lang: lang,
          isFavorite: favProvider.isFavorite(t.id),
          onTap: () => Navigator.of(ctx).pop(t),
          onToggle: () => favProvider.toggle(t),
        );
      },
    );
  }
}

class _TerminalTile extends StatelessWidget {
  final Terminal terminal;
  final String lang;
  final bool isFavorite;
  final int? rank;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _TerminalTile({
    required this.terminal,
    required this.lang,
    required this.isFavorite,
    required this.onTap,
    required this.onToggle,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      leading: rank != null
          ? SizedBox(
              width: 28,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: rank! <= 3 ? AppColors.primary : AppColors.textHint,
                ),
              ),
            )
          : null,
      title: Text(
        TerminalNames.translate(terminal.name, lang),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        TerminalNames.translateCity(_resolveRegion(terminal), lang),
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          color: isFavorite ? const Color(0xFFF59E0B) : AppColors.textHint,
          size: 22,
        ),
        onPressed: onToggle,
        splashRadius: 18,
      ),
    );
  }
}

// ─── 사이드바 드로어 ───────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  final void Function(Terminal terminal)? onFavoriteSelected;
  const _AppDrawer({this.onFavoriteSelected});

  void _go(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _goFavorites(BuildContext context) async {
    Navigator.pop(context); // 드로어 닫기
    final result = await Navigator.of(context).push<Terminal>(
      MaterialPageRoute(builder: (_) => const FavoriteTerminalsScreen()),
    );
    if (result != null) {
      onFavoriteSelected?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    final user = context.watch<AuthProvider>().currentUser;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.72,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── 헤더 ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(0)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.directions_bus,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppStrings.get(lang, 'sidebarMenu'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.name,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── 메뉴 목록 ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  label: AppStrings.get(lang, 'favorites'),
                  onTap: () => _goFavorites(context),
                ),
                _DrawerItem(
                  icon: Icons.credit_card_outlined,
                  label: AppStrings.get(lang, 'myCards'),
                  onTap: () => _go(context, const MyCardsScreen()),
                ),
                const Divider(indent: 20, endIndent: 20, height: 8),
                _DrawerItem(
                  icon: Icons.confirmation_number_outlined,
                  label: AppStrings.get(lang, 'bookingSearch'),
                  onTap: () => _go(context, const MyBookingsScreen()),
                ),
                const Divider(indent: 20, endIndent: 20, height: 8),
                _DrawerItem(
                  icon: Icons.local_activity_outlined,
                  label: AppStrings.get(lang, 'events'),
                  onTap: () => _go(context, const EventScreen()),
                ),
                _DrawerItem(
                  icon: Icons.campaign_outlined,
                  label: AppStrings.get(lang, 'notices'),
                  onTap: () => _go(context, const NoticeScreen()),
                ),
                _DrawerItem(
                  icon: Icons.confirmation_number_outlined,
                  label: AppStrings.get(lang, 'coupons'),
                  onTap: () => _go(context, const CouponScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, size: 22, color: iconColor ?? AppColors.textSecondary),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right,
          size: 18, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
