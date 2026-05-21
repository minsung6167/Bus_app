import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _pwError;
  bool _pwSuccess = false;

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword(String lang) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _pwError = null; _pwSuccess = false; });

    final err = await context.read<AuthProvider>().changePassword(
      currentPassword: _currentPwCtrl.text,
      newPassword: _newPwCtrl.text,
    );

    if (mounted) {
      if (err == null) {
        _currentPwCtrl.clear();
        _newPwCtrl.clear();
        _confirmPwCtrl.clear();
        setState(() { _loading = false; _pwSuccess = true; });
      } else {
        setState(() { _loading = false; _pwError = AppStrings.get(lang, err); });
      }
    }
  }

  void _showDeleteDialog(BuildContext context, String lang) {
    final pwCtrl = TextEditingController();
    bool obscure = true;
    String? error;
    bool deleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935), size: 22),
              const SizedBox(width: 8),
              Text(AppStrings.get(lang, 'deleteAccountTitle'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get(lang, 'deleteAccountDesc'),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.get(lang, 'deleteConfirmPw'),
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: pwCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  hintText: AppStrings.get(lang, 'password'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(fontSize: 12, color: Color(0xFFE53935))),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () { pwCtrl.dispose(); Navigator.pop(ctx); },
              child: Text(AppStrings.get(lang, 'cancel'),
                style: const TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: deleting
                  ? null
                  : () async {
                      setDialogState(() { error = null; deleting = true; });
                      final err = await context.read<AuthProvider>().deleteAccount(pwCtrl.text);
                      if (ctx.mounted) {
                        if (err != null) {
                          setDialogState(() {
                            deleting = false;
                            error = AppStrings.get(lang, err);
                          });
                        } else {
                          Navigator.of(ctx).pop();
                        }
                      }
                    },
              child: deleting
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE53935)))
                  : Text(AppStrings.get(lang, 'deleteBtn'),
                      style: const TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    final user = context.watch<AuthProvider>().currentUser!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.get(lang, 'myInfo'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 계정 정보 카드
              _SectionCard(
                title: AppStrings.get(lang, 'accountInfo'),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: AppStrings.get(lang, 'myId'),
                      value: user.email,
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: AppStrings.get(lang, 'nameLabel'),
                      value: user.name,
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: AppStrings.get(lang, 'phoneLabel'),
                      value: user.phone,
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: AppStrings.get(lang, 'email'),
                      value: user.email,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 비밀번호 변경 카드
              _SectionCard(
                title: AppStrings.get(lang, 'changePw'),
                child: Column(
                  children: [
                    _PwField(
                      controller: _currentPwCtrl,
                      label: AppStrings.get(lang, 'currentPw'),
                      obscure: _obscureCurrent,
                      onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                      validator: (v) {
                        if (v == null || v.isEmpty) return AppStrings.get(lang, 'passwordRequired');
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _PwField(
                      controller: _newPwCtrl,
                      label: AppStrings.get(lang, 'newPw'),
                      obscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                      validator: (v) {
                        if (v == null || v.isEmpty) return AppStrings.get(lang, 'passwordRequired');
                        if (v.length < 6) return AppStrings.get(lang, 'passwordTooShort');
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _PwField(
                      controller: _confirmPwCtrl,
                      label: AppStrings.get(lang, 'confirmNewPw'),
                      obscure: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) {
                        if (v == null || v.isEmpty) return AppStrings.get(lang, 'passwordRequired');
                        if (v != _newPwCtrl.text) return AppStrings.get(lang, 'passwordMismatch');
                        return null;
                      },
                    ),

                    if (_pwError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 15),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_pwError!,
                              style: const TextStyle(fontSize: 12, color: Color(0xFFE53935)))),
                          ],
                        ),
                      ),
                    ],

                    if (_pwSuccess) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.success, size: 15),
                            const SizedBox(width: 8),
                            Expanded(child: Text(AppStrings.get(lang, 'pwChanged'),
                              style: const TextStyle(fontSize: 12, color: AppColors.success))),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : () => _changePassword(lang),
                        child: _loading
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(AppStrings.get(lang, 'changeBtn')),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 회원탈퇴
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteDialog(context, lang),
                  icon: const Icon(Icons.person_remove_outlined, size: 18, color: Color(0xFFE53935)),
                  label: Text(
                    AppStrings.get(lang, 'deleteAccount'),
                    style: const TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE53935)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textHint),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _PwField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  const _PwField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }
}
