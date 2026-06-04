import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/card_model.dart';
import '../providers/card_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

class MyCardsScreen extends StatelessWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    final cards = context.watch<CardProvider>().cards;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.get(lang, 'myCards'))),
      body: cards.isEmpty
          ? _EmptyState(lang: lang, onAdd: () => _showAddCard(context))
          : _CardList(cards: cards, onAdd: () => _showAddCard(context)),
    );
  }

  void _showAddCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddCardSheet(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String lang;
  final VoidCallback onAdd;
  const _EmptyState({required this.lang, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.credit_card_outlined,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.get(lang, 'noCards'),
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.get(lang, 'noCardsHint'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('카드 등록'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  final List<PaymentCard> cards;
  final VoidCallback onAdd;
  const _CardList({required this.cards, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...cards.map((card) => _CardTile(
              card: card,
              isDefault: context.watch<CardProvider>().defaultCardId == card.id,
            )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('카드 등록'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _CardTile extends StatelessWidget {
  final PaymentCard card;
  final bool isDefault;
  const _CardTile({required this.card, required this.isDefault});

  Color get _cardColor {
    switch (card.cardType) {
      case '신한':
        return const Color(0xFF0066B3);
      case '국민':
        return const Color(0xFFFFAC00);
      case '하나':
        return const Color(0xFF009B77);
      case '우리':
        return const Color(0xFF0066CC);
      case '현대':
        return const Color(0xFF333333);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<CardProvider>().setDefault(card.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [_cardColor, _cardColor.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _cardColor.withOpacity(0.3),
              blurRadius: isDefault ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: isDefault
              ? Border.all(color: Colors.white, width: 2.5)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        card.nickname,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('자주쓰는카드',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 10)),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Text(card.cardType,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _confirmDelete(context),
                        child: const Icon(Icons.close,
                            color: Colors.white70, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                card.maskedNumber,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                '유효기간 ${card.expiry}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('카드 삭제'),
        content: Text('${card.nickname} 카드를 삭제하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소')),
          TextButton(
            onPressed: () {
              context.read<CardProvider>().removeCard(card.id);
              Navigator.pop(context);
            },
            child:
                const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  String _cardType = '신한';

  static const _cardTypes = ['신한', '국민', '하나', '우리', '현대', '기타'];

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final raw = _numberCtrl.text.replaceAll(' ', '');
    final masked =
        '**** **** **** ${raw.substring(raw.length - 4)}';
    final card = PaymentCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nickname: _nicknameCtrl.text.trim().isEmpty
          ? '$_cardType 카드'
          : _nicknameCtrl.text.trim(),
      maskedNumber: masked,
      expiry: _expiryCtrl.text,
      cardType: _cardType,
    );

    context.read<CardProvider>().addCard(card);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('카드 등록',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              // 카드사 선택
              DropdownButtonFormField<String>(
                value: _cardType,
                decoration: const InputDecoration(labelText: '카드사'),
                items: _cardTypes
                    .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _cardType = v!),
              ),
              const SizedBox(height: 12),
              // 카드 번호
              TextFormField(
                controller: _numberCtrl,
                decoration: const InputDecoration(
                    labelText: '카드 번호', hintText: '0000 0000 0000 0000'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                validator: (v) {
                  if (v == null || v.replaceAll(' ', '').length < 16)
                    return '16자리 카드 번호를 입력해주세요';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // 유효기간
              TextFormField(
                controller: _expiryCtrl,
                decoration: const InputDecoration(
                    labelText: '유효기간', hintText: 'MM/YY'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ExpiryFormatter(),
                ],
                validator: (v) {
                  if (v == null || v.length < 5) return '유효기간을 입력해주세요';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // 카드 별칭
              TextFormField(
                controller: _nicknameCtrl,
                decoration: const InputDecoration(
                    labelText: '카드 별칭 (선택)',
                    hintText: '예: 주거래 카드'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('등록'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 16) return oldValue;
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) return oldValue;
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
