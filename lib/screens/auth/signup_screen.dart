import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfirmCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _pwConfirmCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup(String lang) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMsg = null; });

    final err = await context.read<AuthProvider>().signup(
      email: _emailCtrl.text.trim(),
      password: _pwCtrl.text,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    if (mounted) {
      if (err != null) {
        setState(() { _loading = false; _errorMsg = AppStrings.get(lang, err); });
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;

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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.directions_bus, color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(AppStrings.get(lang, 'signupTitle'),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(AppStrings.get(lang, 'signupSubtitle'),
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

          // 폼
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
                          Text(AppStrings.get(lang, 'signup'),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 24),

                          // 이름
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: AppStrings.get(lang, 'nameLabel'),
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? AppStrings.get(lang, 'nameEmpty') : null,
                          ),
                          const SizedBox(height: 14),

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
                          const SizedBox(height: 14),

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
                              if (v.length < 6) return AppStrings.get(lang, 'passwordTooShort');
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // 비밀번호 확인
                          TextFormField(
                            controller: _pwConfirmCtrl,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              labelText: AppStrings.get(lang, 'confirmPassword'),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return AppStrings.get(lang, 'passwordRequired');
                              if (v != _pwCtrl.text) return AppStrings.get(lang, 'passwordMismatch');
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // 연락처
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_PhoneFormatter()],
                            decoration: InputDecoration(
                              labelText: AppStrings.get(lang, 'phoneLabel'),
                              prefixIcon: const Icon(Icons.phone_outlined),
                              hintText: '010-0000-0000',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return AppStrings.get(lang, 'phoneEmpty');
                              if (!RegExp(r'^\d{3}-\d{4}-\d{4}$').hasMatch(v.trim())) {
                                return AppStrings.get(lang, 'phoneFormat');
                              }
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

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : () => _signup(lang),
                              child: _loading
                                  ? const SizedBox(width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text(AppStrings.get(lang, 'signupBtn')),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppStrings.get(lang, 'hasAccount'),
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                                child: Text(AppStrings.get(lang, 'login'),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
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

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buf = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 3 || i == 7) buf.write('-');
      buf.write(limited[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
