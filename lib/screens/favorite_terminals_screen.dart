import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../l10n/terminal_names.dart';
import '../providers/favorite_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

String _resolveRegion(String name, String cityName) {
  const prefixes = ['경기', '강원', '충북', '충남', '전북', '전남', '경북', '경남'];
  for (final p in prefixes) {
    if (name.startsWith(p)) return p;
  }
  return cityName;
}

class FavoriteTerminalsScreen extends StatelessWidget {
  const FavoriteTerminalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    final favorites = context.watch<FavoriteProvider>().favoriteTerminals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.get(lang, 'favorites'))),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_outline_rounded,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.get(lang, 'noFavoritesHint'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (ctx, i) {
                final t = favorites[i];
                final region = _resolveRegion(t.name, t.cityName);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    TerminalNames.translate(t.name, lang),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    TerminalNames.translateCity(region, lang),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 22,
                    ),
                    splashRadius: 18,
                    onPressed: () => context.read<FavoriteProvider>().toggle(t),
                  ),
                );
              },
            ),
    );
  }
}
