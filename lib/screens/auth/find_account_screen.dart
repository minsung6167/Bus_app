import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../theme/app_theme.dart';

class FindAccountScreen extends StatefulWidget {
  const FindAccountScreen({super.key});

  @override
  State<FindAccountScreen> createState() => _FindAccountScreenState();
}

class _FindAccountScreenState extends State<FindAccountScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(lang, 'findAccount')),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: AppStrings.get(lang, 'findEmail')),
            Tab(text: AppStrings.get(lang, 'findPassword')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FindEmailTab(),
          _FindPasswordTab(),
        ],
      ),
    );
  }
}

class _FindEmailTab extends StatefulWidget {
  const _FindEmailTab();

  @override
  State<_FindEmailTab> createState() => _FindEmailTabState();
}

class _FindEmailTabState extends State<_FindEmailTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _result;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _find(String lang) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _result = null; _error = null; });
    final email = await context.read<AuthProvider>().findEmail(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
    );
    if (mounted) {
      setState(() {
        _loading = false;
        if (email != null) {
          _result = email;
        } else {
          _error = AppStrings.get(lang, 'findAccountFailed');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: AppStrings.get(lang, 'name'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.get(lang, 'nameRequired')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: AppStrings.get(lang, 'phone'),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.get(lang, 'phoneRequired')
                  : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : () => _find(lang),
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(AppStrings.get(lang, 'findEmail')),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.get(lang, 'findEmailResult'),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text(_result!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 24),
              _ErrorBox(message: _error!),
            ],
          ],
        ),
      ),
    );
  }
}

class _FindPasswordTab extends StatefulWidget {
  const _FindPasswordTab();

  @override
  State<_FindPasswordTab> createState() => _FindPasswordTabState();
}

class _FindPasswordTabState extends State<_FindPasswordTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _reset(String lang) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final err = await context.read<AuthProvider>().resetPassword(
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      newPassword: _newPwCtrl.text,
    );
    if (mounted) {
      setState(() => _loading = false);
      if (err == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.get(lang, 'passwordResetDone'))),
        );
        Navigator.of(context).pop();
      } else {
        setState(() => _error = AppStrings.get(lang, err));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().langCode;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 8),
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
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: AppStrings.get(lang, 'phone'),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.get(lang, 'phoneRequired')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPwCtrl,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: AppStrings.get(lang, 'newPw'),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return AppStrings.get(lang, 'passwordRequired');
                if (v.length < 6) return AppStrings.get(lang, 'passwordTooShort');
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPwCtrl,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: AppStrings.get(lang, 'confirmNewPw'),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return AppStrings.get(lang, 'passwordRequired');
                if (v != _newPwCtrl.text) return AppStrings.get(lang, 'passwordMismatch');
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : () => _reset(lang),
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(AppStrings.get(lang, 'resetPasswordBtn')),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              _ErrorBox(message: _error!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Expanded(child: Text(message,
              style: const TextStyle(fontSize: 13, color: Color(0xFFE53935)))),
        ],
      ),
    );
  }
}
