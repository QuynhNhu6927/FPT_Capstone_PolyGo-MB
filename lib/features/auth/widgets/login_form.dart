import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/auth/login_request.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/apis/auth_service.dart';
import '../../../data/services/signalr/user_presence.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/utils/responsive.dart';

class LoginForm extends StatefulWidget {
  final bool isTablet;
  final bool isDesktop;

  const LoginForm({super.key, this.isTablet = false, this.isDesktop = false});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _showPassword = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;


  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _onSubmit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final loc = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool hasError = false;
    if (email.isEmpty) {
      setState(() => _emailError = loc.translate("email_required"));
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = loc.translate("password_required"));
      hasError = true;
    }
    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final req = LoginRequest(mail: email, password: password);
      final repo = AuthRepository(AuthService(ApiClient()));
      final token = await repo.login(req);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await UserPresenceManager().init();
      final decoded = JwtDecoder.decode(token);
      final isNew = decoded['IsNew']?.toString().toLowerCase() == 'true';

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate("login_success"))),
      );

      if (isNew) {
        Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      final msg = e.toString();

      if (msg.contains('InvalidMailOrPassword')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate("invalid_email_or_password"))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate("system_error_try_again"))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              Center(
                child: Image.asset(
                  'assets/Primary.png',
                  width: st(context, 150),
                  height: st(context, 150),
                  fit: BoxFit.contain,
                ),
              ),
              // Email
              Text(
                loc.translate("email"),
                style: t.labelLarge?.copyWith(fontSize: st(context, 14)),
              ),
              SizedBox(height: sh(context, 8)),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "user@example.com",
                  errorText: _emailError,
                  prefixIcon: Icon(Icons.mail_outline, size: sw(context, 20)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(sw(context, 10)),
                  ),
                ),
                validator: (v) => (v == null || !v.contains('@'))
                    ? loc.translate("invalid_email")
                    : null,
              ),
              SizedBox(height: sh(context, 16)),

              // Password
              Text(
                loc.translate("password"),
                style: t.labelLarge?.copyWith(fontSize: st(context, 14)),
              ),
              SizedBox(height: sh(context, 8)),
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: "••••••••",
                  errorText: _passwordError,
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
              ),
              SizedBox(height: sh(context, 12)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v!),
                        ),
                        Flexible(
                          child: Text(
                            loc.translate("remember_me"),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    text: loc.translate("forgot_password"),
                    variant: ButtonVariant.link,
                    size: ButtonSize.sm,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.forgetPassword);
                    },
                  ),
                ],
              ),
              SizedBox(height: sh(context, 20)),

              AppButton(
                text: _isLoading
                    ? "Logging in..."
                    : loc.translate("login_button"),
                onPressed: _isLoading ? null : _onSubmit,
                size: ButtonSize.lg,
                variant: ButtonVariant.primary,
                disabled: _isLoading,
              ),

              SizedBox(height: sh(context, 24)),
              Row(
                children: [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw(context, 12)),
                    child: Text(
                      loc.translate("or_continue_with"),
                      style: t.bodySmall?.copyWith(
                          color: Colors.grey, fontSize: st(context, 12)),
                    ),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),

              SizedBox(height: sh(context, 24)),
              AppButton(
                text: loc.translate("login_google"),
                icon: const Icon(Icons.g_mobiledata, size: 28),
                variant: ButtonVariant.outline,
                size: ButtonSize.lg,
                onPressed: () {},
              ),

              SizedBox(height: sh(context, 24)),
              Text.rich(
                TextSpan(
                  text: loc.translate("no_account") + ' ',
                  style: t.bodyMedium?.copyWith(
                      color: Colors.grey, fontSize: st(context, 14)),
                  children: [
                    TextSpan(
                      text: loc.translate("signup_now"),
                      style: TextStyle(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                        fontSize: st(context, 14),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, AppRoutes.register);
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
