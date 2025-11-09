import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/auth/change_password_request.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/apis/auth_service.dart';
import '../../../core/api/api_client.dart';
import '../../../../core/utils/responsive.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  late final AuthRepository _authRepository;
  final apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    final authService = AuthService(apiClient);
    _authRepository = AuthRepository(authService);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _passwordValidator(String? v) {
    final loc = AppLocalizations.of(context);
    if (v == null || v.isEmpty) return loc.translate("null");
    if (v.length < 6) return loc.translate("min_6_char");
    final upperCase = RegExp(r'[A-Z]');
    final number = RegExp(r'\d');
    final special = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!upperCase.hasMatch(v)) return loc.translate("min_6_char");
    if (!number.hasMatch(v)) return loc.translate("min_6_char");
    if (!special.hasMatch(v)) return loc.translate("min_6_char");
    return null;
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final req = ChangePasswordRequest(
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Token not found");

      await _authRepository.changePassword(req, token);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate("change_password_success")),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate("change_password_failed")),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final loc = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final containerWidth = screenWidth < 500
        ? screenWidth * 0.9
        : screenWidth < 800
        ? 450.0
        : 500.0;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 40,
          bottom: MediaQuery.of(context).viewInsets.bottom + 40,
          left: 16,
          right: 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: containerWidth,
          ),
          child: Container(
            padding: EdgeInsets.all(sw(context, 24)),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(sw(context, 16)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x11000000), blurRadius: 20, offset: Offset(0, 8)),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(sw(context, 12)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(sw(context, 12)),
                      ),
                      child: Icon(Icons.lock_outline,
                          size: sw(context, 36), color: const Color(0xFF2563EB)),
                    ),
                  ),
                  SizedBox(height: sh(context, 20)),

                  Text(
                    loc.translate("change_password_title"),
                    textAlign: TextAlign.center,
                    style: t.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: st(context, 24)),
                  ),
                  SizedBox(height: sh(context, 24)),

                Text(loc.translate("current_password"), style: t.labelLarge),
                SizedBox(height: sh(context, 8)),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: !_showCurrentPassword,
                  decoration: InputDecoration(
                    hintText: "••••••••",
                    prefixIcon: Icon(Icons.lock_outline, size: sw(context, 20)),
                    suffixIcon: IconButton(
                      icon: Icon(_showCurrentPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
                    ),
                    border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(sw(context, 10))),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? loc.translate("null") : null,
                ),
                SizedBox(height: sh(context, 16)),

                Text(loc.translate("new_password"), style: t.labelLarge),
                SizedBox(height: sh(context, 8)),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_showNewPassword,
                  decoration: InputDecoration(
                    hintText: "••••••••",
                    prefixIcon: Icon(Icons.lock_outline, size: sw(context, 20)),
                    suffixIcon: IconButton(
                      icon: Icon(_showNewPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
                    ),
                    border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(sw(context, 10))),
                  ),
                  validator: _passwordValidator,
                ),
                SizedBox(height: sh(context, 16)),

                Text(loc.translate("confirm_new_password"), style: t.labelLarge),
                SizedBox(height: sh(context, 8)),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  decoration: InputDecoration(
                    hintText: "••••••••",
                    prefixIcon: Icon(Icons.lock_outline, size: sw(context, 20)),
                    suffixIcon: IconButton(
                      icon: Icon(_showConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                    ),
                    border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(sw(context, 10))),
                  ),
                  validator: (v) =>
                  (v != _newPasswordController.text) ? loc.translate("not_match") : null,
                ),
                SizedBox(height: sh(context, 24)),

                AppButton(
                  text: _isLoading
                      ? loc.translate("changing_password")
                      : loc.translate("change_password_button"),
                  onPressed: _isLoading ? null : _onSubmit,
                  size: ButtonSize.lg,
                  variant: ButtonVariant.primary,
                  disabled: _isLoading,
                ),
              ],
            ),
          ),
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }
}
