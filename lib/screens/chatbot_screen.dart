import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../l10n/chatbot_strings.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = context.read<LanguageProvider>().langCode;
      _addBot(AppStrings.get(lang, 'chatbotGreeting'));
    });
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

    final lang = context.read<LanguageProvider>().langCode;
    final faqs = getChatbotFaqs(lang);
    final lower = text.toLowerCase();
    Map<String, dynamic>? matched;
    for (final faq in faqs) {
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
        _addBot(AppStrings.get(lang, 'chatbotNoAnswer'));
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
        title: Builder(builder: (ctx) {
          final lang = ctx.watch<LanguageProvider>().langCode;
          return Row(
            children: [
              const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white24,
                child: Icon(Icons.support_agent, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.get(lang, 'chatbotTitle'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(AppStrings.get(lang, 'chatbotAuto'),
                      style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ],
          );
        }),
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
    final lang = context.read<LanguageProvider>().langCode;
    final faqs = getChatbotFaqs(lang);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(AppStrings.get(lang, 'faqTitle'),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: faqs.map((faq) {
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
                hintText: AppStrings.get(context.read<LanguageProvider>().langCode, 'chatbotHint'),
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
