import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

const _noticeData = [
  {
    'title': '[필독] 5월 연휴 버스 운행 특별 안내',
    'date': '2026-05-08',
    'content':
        '5월 어린이날(5일) 및 어버이날(8일) 연휴 기간 동안 일부 노선의 증차 및 시간표가 변경됩니다.\n\n'
        '• 서울↔부산 노선: 오전 6시 ~ 오후 8시 30분 간격 배차\n'
        '• 서울↔강릉 노선: 오전 7시 ~ 오후 6시 30분 간격 배차\n'
        '• 예매는 출발 3일 전부터 가능하며, 연휴 기간 좌석이 빠르게 소진될 수 있으니 미리 예매하시기 바랍니다.\n\n'
        '이용에 불편을 드려 죄송합니다.',
  },
  {
    'title': '앱 업데이트 안내 (v2.1.0)',
    'date': '2026-04-25',
    'content':
        '버스티켓 앱이 v2.1.0으로 업데이트되었습니다.\n\n'
        '【주요 변경사항】\n'
        '• 비회원 노선 조회 기능 추가\n'
        '• 좌석 선택 화면 UI 개선\n'
        '• 다국어 지원 (한국어, 영어, 중국어, 일본어)\n'
        '• 일부 버그 수정 및 성능 향상\n\n'
        '앱스토어에서 최신 버전으로 업데이트해 주세요.',
  },
  {
    'title': '고객센터 운영시간 변경 안내',
    'date': '2026-04-10',
    'content':
        '고객 서비스 향상을 위해 고객센터 운영시간이 변경됩니다.\n\n'
        '【변경 전】 평일 09:00 ~ 18:00\n'
        '【변경 후】 평일 08:00 ~ 20:00, 토요일 09:00 ~ 15:00\n\n'
        '※ 일요일 및 공휴일은 운영하지 않습니다.\n'
        '더 나은 서비스로 보답하겠습니다.',
  },
  {
    'title': '개인정보처리방침 개정 안내',
    'date': '2026-03-20',
    'content':
        '관련 법령 개정에 따라 개인정보처리방침이 일부 개정되었습니다.\n\n'
        '• 시행일: 2026년 4월 1일\n'
        '• 주요 변경 내용: 개인정보 보유 기간 명확화, 제3자 제공 항목 정비\n\n'
        '자세한 내용은 앱 내 [설정 > 개인정보처리방침]에서 확인하실 수 있습니다.',
  },
  {
    'title': '정기 시스템 점검 안내',
    'date': '2026-03-05',
    'content':
        '서비스 안정성 향상을 위한 정기 시스템 점검이 진행되었습니다.\n\n'
        '• 점검 일시: 2026년 3월 10일(화) 새벽 2:00 ~ 4:00\n'
        '• 점검 내용: 서버 보안 패치 및 DB 최적화\n\n'
        '점검 시간 동안 서비스 이용이 일시 중단되었습니다. 불편을 드려 죄송합니다.',
  },
];

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.get(lang, 'notices'))),
      body: _noticeData.isEmpty
          ? Center(
              child: Text(
                AppStrings.get(lang, 'noNotices'),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _noticeData.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _NoticeItem(notice: _noticeData[i]),
            ),
    );
  }
}

class _NoticeItem extends StatelessWidget {
  final Map<String, String> notice;
  const _NoticeItem({required this.notice});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              AppStrings.get(lang, 'noticeLabel'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          title: Text(
            notice['title']!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              notice['date']!,
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                notice['content']!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
