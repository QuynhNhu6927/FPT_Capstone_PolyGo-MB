import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/auth/reset_password_request.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/apis/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/utils/responsive.dart';

class ForgetPasswordForm extends StatefulWidget {
  final bool isTablet;
  final bool isDesktop;

  const ForgetPasswordForm({super.key, this.isTablet = false, this.isDesktop = false});

  @override
  State<ForgetPasswordForm> createState() => _ForgetPasswordFormState();

}

class _ForgetPasswordFormState extends State<ForgetPasswordForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSendingOtp = false;
  bool _isLoading = false;
  bool _showOtpField = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  String? _otpMessage;
  bool _otpSuccess = false;

  int _otpCountdown = 0;
  Timer? _otpTimer;

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
    _otpTimer?.cancel();
    super.dispose();
  }

  void _startOtpCountdown() {
    setState(() => _otpCountdown = 90);
    _otpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_otpCountdown == 0) {
        timer.cancel();
      } else {
        setState(() => _otpCountdown--);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() {
        _otpMessage = AppLocalizations.of(context).translate("invalid_email");
        _otpSuccess = false;
      });
      return;
    }

    setState(() {
      _isSendingOtp = true;
      _otpMessage = null;
    });

    try {
      await _authRepository.sendOtp(
        mail: _emailController.text.trim(),
        verificationType: 1,
      );
      setState(() {
        _showOtpField = true;
        _otpMessage = AppLocalizations.of(context).translate("otp_sent_success");
        _otpSuccess = true;
      });
      _startOtpCountdown();
    } catch (e) {
      setState(() {
        _otpMessage = AppLocalizations.of(context).translate("otp_sent_failed");
        _otpSuccess = false;
      });
    } finally {
      setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final req = ResetPasswordRequest(
        mail: _emailController.text.trim(),
        otp: _otpController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _authRepository.resetPassword(req);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate("reset_success")),
          duration: const Duration(seconds: 2),
        ),
      );

      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.login);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate("reset_failed")),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _passwordValidator(String? v) {
    final loc = AppLocalizations.of(context);
    if (v == null || v.isEmpty) return AppLocalizations.of(context).translate("null");
    if (v.length < 6) return AppLocalizations.of(context).translate("min_6_char");
    final upperCase = RegExp(r'[A-Z]');
    final number = RegExp(r'\d');
    final special = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!upperCase.hasMatch(v)) return loc.translate("min_6_char");
    if (!number.hasMatch(v)) return loc.translate("min_6_char");
    if (!special.hasMatch(v)) return loc.translate("min_6_char");
    return null;
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
      child: Container(
        width: containerWidth,
        padding: EdgeInsets.all(sw(context, 24)),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(sw(context, 16)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
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
                  child: Icon(
                    Icons.lock_reset_rounded,
                    size: sw(context, 36),
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
              SizedBox(height: sh(context, 20)),

              // Title
              Text(
                loc.translate("forget_password_title"),
                textAlign: TextAlign.center,
                style: t.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: st(context, 24),
                ),
              ),
              SizedBox(height: sh(context, 6)),
              Text(
                loc.translate("forget_password_subtitle"),
                textAlign: TextAlign.center,
                style: t.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                  fontSize: st(context, 14),
                ),
              ),
              SizedBox(height: sh(context, 32)),

              Text(
                loc.translate("email"),
                style: t.labelLarge?.copyWith(fontSize: st(context, 14)),
              ),
              SizedBox(height: sh(context, 8)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "user@example.com",
                        prefixIcon: Icon(Icons.mail_outline, size: sw(context, 20)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(sw(context, 10)),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return loc.translate("null");
                        if (!v.contains('@')) return loc.translate("invalid_email");
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: sw(context, 8)),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _otpCountdown > 0 ? Colors.grey : const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw(context, 10)),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: sw(context, 16)),
                      ),
                      onPressed: (_isSendingOtp || _otpCountdown > 0) ? null : _sendOtp,
                      child: _isSendingOtp
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : Text(
                        _otpCountdown > 0 ? "Resend in $_otpCountdown s" : loc.translate("send_otp"),
                        style: TextStyle(fontSize: st(context, 14), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),

              if (_otpMessage != null) ...[
                SizedBox(height: sh(context, 4)),
                Text(
                  _otpMessage!,
                  style: TextStyle(
                    color: _otpSuccess ? Colors.green : Colors.red,
                    fontSize: st(context, 12),
                  ),
                ),
              ],

              SizedBox(height: sh(context, 16)),

              if (_showOtpField) ...[
                Text(loc.translate("enter_otp"),
                    style: t.labelLarge?.copyWith(fontSize: st(context, 14))),
                SizedBox(height: sh(context, 8)),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "123456",
                    prefixIcon: Icon(Icons.numbers_outlined, size: sw(context, 20)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(sw(context, 10)),
                    ),
                  ),
                  validator: (v) =>
                  (v == null || v.isEmpty) ? loc.translate("null") : null,
                ),
                SizedBox(height: sh(context, 16)),
              ],

              Text(loc.translate("new_password"),
                  style: t.labelLarge?.copyWith(fontSize: st(context, 14))),
              SizedBox(height: sh(context, 8)),
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: "••••••••",
                  prefixIcon: Icon(Icons.lock_outline, size: sw(context, 20)),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(sw(context, 10)),
                  ),
                ),
                validator: _passwordValidator,
              ),
              SizedBox(height: sh(context, 16)),

              // Confirm password
              Text(loc.translate("confirm_new_password"),
                  style: t.labelLarge?.copyWith(fontSize: st(context, 14))),
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
                    onPressed: () => setState(
                            () => _showConfirmPassword = !_showConfirmPassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(sw(context, 10)),
                  ),
                ),
                validator: (v) =>
                (v != _passwordController.text) ? loc.translate("not_match") : null,
              ),

              SizedBox(height: sh(context, 24)),

              AppButton(
                text: _isLoading
                    ? loc.translate("resetting_password")
                    : loc.translate("reset_password_button"),
                onPressed: _isLoading ? null : _onSubmit,
                size: ButtonSize.lg,
                variant: ButtonVariant.primary,
                disabled: _isLoading,
              ),

              SizedBox(height: sh(context, 24)),
              Text.rich(
                TextSpan(
                  text: loc.translate("remember_password") + ' ',
                  style: t.bodyMedium?.copyWith(
                      color: Colors.grey, fontSize: st(context, 14)),
                  children: [
                    TextSpan(
                      text: loc.translate("login_now"),
                      style: TextStyle(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                        fontSize: st(context, 14),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
