import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

const _faqs = [
  {
    'q': '예매 취소는 어떻게 하나요?',
    'a': '마이페이지 → 예매내역 탭에서 취소할 예매를 선택한 후 [취소] 버튼을 누르시면 됩니다.\n\n출발 1시간 전까지는 100% 환불이 가능합니다.',
    'keywords': ['취소', '환불', 'cancel', 'refund'],
  },
  {
    'q': '모바일 발권은 어떻게 사용하나요?',
    'a': '예매 완료 후 예매내역에서 QR코드를 확인할 수 있습니다.\n\n버스 탑승 시 기사님께 QR코드를 보여주시면 별도 발권 없이 탑승 가능합니다.',
    'keywords': ['발권', 'qr', 'QR', '모바일', '탑승', 'ticket'],
  },
  {
    'q': '짐은 얼마나 가져갈 수 있나요?',
    'a': '좌석 1개당 20kg 이내의 수하물을 무료로 보관하실 수 있습니다.\n\n초과 시 추가 요금이 발생할 수 있으니 터미널에 문의해 주세요.',
    'keywords': ['짐', '수하물', '가방', '무게', 'luggage', 'baggage'],
  },
  {
    'q': '앱 언어를 바꾸고 싶어요',
    'a': '마이페이지 → 언어 설정에서 한국어, English, 中文, 日本語 중 원하는 언어를 선택하실 수 있습니다.',
    'keywords': ['언어', '영어', '중국어', '일본어', 'language', '바꾸'],
  },
  {
    'q': '회원가입 없이 예매할 수 있나요?',
    'a': '비회원 예매는 지원하지 않습니다. 로그인 후 예매가 가능합니다.\n\n회원가입은 이메일 주소만 있으면 빠르게 완료할 수 있습니다.',
    'keywords': ['비회원', '회원가입', '로그인', '가입', 'login', 'signup'],
  },
];

class _ChatMessage {
  final String text;
  final bool isBot;
  _ChatMessage({required this.text, required this.isBot});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _faqVisible = true;

  @override
  void initState() {
    super.initState();
    _addBot('안녕하세요! 시외버스 예약 앱 고객센터입니다 😊\n자주 묻는 질문을 선택하거나 직접 입력해 주세요.');
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBot(String text) {
    setState(() => _messages.add(_ChatMessage(text: text, isBot: true)));
    _scrollToBottom();
  }

  void _addUser(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isBot: false));
      _faqVisible = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onFaqTap(Map<String, dynamic> faq) {
    _addUser(faq['q'] as String);
    Future.delayed(const Duration(milliseconds: 400), () {
      _addBot(faq['a'] as String);
      setState(() => _faqVisible = true);
    });
  }

  void _onSendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _addUser(text);

    final lower = text.toLowerCase();
    Map<String, dynamic>? matched;
    for (final faq in _faqs) {
      final keywords = faq['keywords'] as List<String>;
      if (keywords.any((k) => lower.contains(k.toLowerCase()))) {
        matched = faq;
        break;
      }
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      if (matched != null) {
        _addBot(matched['a'] as String);
      } else {
        _addBot('죄송해요, 해당 질문에 대한 답변을 찾지 못했어요 😅\n아래 자주 묻는 질문을 이용해 주세요.');
      }
      setState(() => _faqVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white24,
              child: Icon(Icons.support_agent, size: 18, color: Colors.white),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('고객센터 챗봇', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('자동응답', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _BubbleTile(message: _messages[i]),
            ),
          ),
          if (_faqVisible) _buildFaqChips(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildFaqChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 6),
            child: Text('자주 묻는 질문', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _faqs.map((faq) {
              return GestureDetector(
                onTap: () => _onFaqTap(faq),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    faq['q'] as String,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _onSendText(),
              decoration: InputDecoration(
                hintText: '질문을 입력하세요...',
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _onSendText,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleTile extends StatelessWidget {
  final _ChatMessage message;
  const _BubbleTile({required this.message});

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.support_agent, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isBot ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isBot ? 4 : 16),
                  bottomRight: Radius.circular(isBot ? 16 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color: isBot ? AppColors.textPrimary : Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (!isBot) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
