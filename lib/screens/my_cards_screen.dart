import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

class MyCardsScreen extends StatelessWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.get(lang, 'myCards'))),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
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
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('카드 등록'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
