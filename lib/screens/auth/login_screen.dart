import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../theme/app_theme.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _login(String lang) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMsg = null; });

    final err = await context.read<AuthProvider>().login(
      _emailCtrl.text.trim(),
      _pwCtrl.text,
    );

    if (mounted) {
      if (err == null) {
        Navigator.of(context).pop();
        return;
      }
      setState(() { _loading = false; _errorMsg = AppStrings.get(lang, err); });
    }
  }

  void _showLanguagePicker(BuildContext context, LanguageProvider langProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(AppStrings.get(langProvider.langCode, 'selectLanguage'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...LanguageProvider.languages.map((lang) {
              final isSelected = langProvider.langCode == lang['code'];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
                title: Text(lang['label']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  )),
                trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                onTap: () { langProvider.setLanguage(lang['code']!); Navigator.pop(context); },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final lang = langProvider.langCode;
    final currentLang = LanguageProvider.languages
        .firstWhere((l) => l['code'] == lang, orElse: () => LanguageProvider.languages.first);

    return Scaffold(
      body: Column(
        children: [
          // 헤더
          Container(
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
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.directions_bus, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Text(AppStrings.get(lang, 'appTitle'),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showLanguagePicker(context, langProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(currentLang['flag']!, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Text(currentLang['code']!.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(AppStrings.get(lang, 'loginWelcome'),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(AppStrings.get(lang, 'loginSubtitle'),
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

          // 폼 카드
          Expanded(
            child: SingleChildScrollView(
              child: Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4)),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.get(lang, 'login'),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 24),

                          // 이메일
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: AppStrings.get(lang, 'email'),
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return AppStrings.get(lang, 'emailRequired');
                              if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v.trim())) {
                                return AppStrings.get(lang, 'emailInvalid');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 비밀번호
                          TextFormField(
                            controller: _pwCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: AppStrings.get(lang, 'password'),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return AppStrings.get(lang, 'passwordRequired');
                              return null;
                            },
                          ),

                          // 오류 메시지
                          if (_errorMsg != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(_errorMsg!,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFFE53935)))),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // 로그인 버튼
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : () => _login(lang),
                              child: _loading
                                  ? const SizedBox(width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text(AppStrings.get(lang, 'loginBtn')),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 회원가입 링크
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppStrings.get(lang, 'noAccount'),
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                                ),
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                                child: Text(AppStrings.get(lang, 'signup'),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
