import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

final _eventData = [
  {
    'title': '봄맞이 특별 할인 이벤트',
    'subtitle': '전 노선 10% 할인 혜택',
    'period': '2026.04.01 ~ 2026.05.31',
    'desc':
        '따뜻한 봄을 맞아 전국 모든 노선에서 10% 할인 혜택을 드립니다!\n\n'
        '• 대상: 앱에서 예매하는 모든 고객\n'
        '• 할인 방식: 결제 금액에서 자동 차감\n'
        '• 적용 노선: 전 노선\n\n'
        '봄 여행을 더 저렴하게 떠나세요!',
    'gradientColors': [Color(0xFF43A047), Color(0xFF81C784)],
    'isActive': true,
    'icon': Icons.local_florist_outlined,
  },
  {
    'title': '신규 회원 첫 예매 혜택',
    'subtitle': '첫 예매 시 2,000원 할인 쿠폰 지급',
    'period': '2026.01.01 ~ 2026.12.31',
    'desc':
        '버스티켓에 처음 오신 것을 환영합니다!\n\n'
        '회원가입 후 첫 예매 완료 시 다음 예매에 사용 가능한 2,000원 할인 쿠폰을 드립니다.\n\n'
        '• 쿠폰 유효기간: 지급일로부터 30일\n'
        '• 최소 결제금액: 10,000원 이상\n'
        '• 중복 사용 불가\n\n'
        '지금 바로 시작해보세요!',
    'gradientColors': [Color(0xFF1E88E5), Color(0xFF64B5F6)],
    'isActive': true,
    'icon': Icons.card_giftcard_outlined,
  },
  {
    'title': '설 연휴 특별 프로모션',
    'subtitle': '귀성·귀경길 우등버스 20% 할인',
    'period': '2026.01.25 ~ 2026.02.02',
    'desc':
        '설 연휴 기간 동안 우등버스 이용 시 20% 할인을 제공합니다.\n\n'
        '• 적용 등급: 우등, 프리미엄\n'
        '• 할인 기간: 설 전날 ~ 설 연휴 마지막 날\n'
        '• 사전 예매 필수 (현장 발권 불가)\n\n'
        '즐거운 설 명절 되세요!',
    'gradientColors': [Color(0xFFE53935), Color(0xFFEF9A9A)],
    'isActive': false,
    'icon': Icons.celebration_outlined,
  },
  {
    'title': 'SNS 후기 이벤트',
    'subtitle': '이용 후기 작성 시 커피 기프티콘 증정',
    'period': '2026.03.01 ~ 2026.03.31',
    'desc':
        '버스티켓 이용 후기를 SNS에 공유해주세요!\n\n'
        '• 참여 방법: 예매 후 이용 사진 + #버스티켓 해시태그와 함께 SNS 업로드\n'
        '• 링크를 고객센터로 전송\n'
        '• 당첨자 발표: 매주 금요일\n'
        '• 경품: 스타벅스 아메리카노 기프티콘\n\n'
        '많은 참여 부탁드립니다!',
    'gradientColors': [Color(0xFF7C3AED), Color(0xFFB39DDB)],
    'isActive': false,
    'icon': Icons.share_outlined,
  },
];

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.get(lang, 'events'))),
      body: _eventData.isEmpty
          ? Center(
              child: Text(
                AppStrings.get(lang, 'noEvents'),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _eventData.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) =>
                  _EventCard(event: _eventData[i], lang: lang),
            ),
    );
  }
}

class _EventCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final String lang;
  const _EventCard({required this.event, required this.lang});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final lang = widget.lang;
    final isActive = e['isActive'] as bool;
    final colors = e['gradientColors'] as List<Color>;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // 배너 영역
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? colors
                      : [Colors.grey.shade400, Colors.grey.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      e['icon'] as IconData,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          e['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e['subtitle'] as String,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Text(
                      isActive
                          ? AppStrings.get(lang, 'eventOngoing')
                          : AppStrings.get(lang, 'eventEnded'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 기간 + 펼치기
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${AppStrings.get(lang, 'eventPeriod')}  ${e['period']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),

            // 상세 내용
            if (_expanded) ...[
              const Divider(
                height: 1,
                color: AppColors.divider,
                indent: 16,
                endIndent: 16,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Text(
                  e['desc'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
