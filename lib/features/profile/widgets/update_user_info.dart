import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:polygo_mobile/features/profile/widgets/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/user/update_userinfo_request.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/apis/user_service.dart';
import '../../../core/api/api_client.dart';
import '../../../../data/models/auth/me_response.dart';

class UpdateUserInfoForm extends StatefulWidget {
  final MeResponse user;
  final Function(MeResponse updatedUser) onUpdated;
  const UpdateUserInfoForm({super.key, required this.user, required this.onUpdated});

  @override
  State<UpdateUserInfoForm> createState() => _UpdateUserInfoFormState();
}

class _UpdateUserInfoFormState extends State<UpdateUserInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _introController;
  String _gender = "Female";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _introController = TextEditingController(text: widget.user.introduction);
    _gender = widget.user.gender == "Male" ? "Male" : "Female";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _introController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Token not found");

      final repo = UserRepository(UserService(ApiClient()));
      final req = UpdateInfoRequest(
        name: _nameController.text.trim(),
        introduction: _introController.text.trim(),
        gender: _gender,
        avatarUrl: widget.user.avatarUrl ?? '',
      );

      await repo.updateUserInfo(token, req);

      if (!mounted) return;

      final updatedUser = widget.user.copyWith(
        avatarUrl: widget.user.avatarUrl ?? '',
      ).copyWith(
        name: req.name,
        introduction: req.introduction,
        gender: req.gender,
      );

      widget.onUpdated(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate("update_profile_success")),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate("update_profile_failed")),
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
          constraints: BoxConstraints(maxWidth: containerWidth),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person_outline,
                          size: 36, color: const Color(0xFF2563EB)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    loc.translate("update_profile_title"),
                    textAlign: TextAlign.center,
                    style: t.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 24),

                  TextFormField(
                    controller: _nameController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: loc.translate("name"),
                      hintText: loc.translate("enter_name"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (v) =>
                    (v == null || v.isEmpty) ? loc.translate("null") : null,
                  ),
                  SizedBox(height: 16),

                  if (_introController.text.isNotEmpty) ...[
                    TextFormField(
                      controller: _introController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: loc.translate("introduction"),
                        hintText: loc.translate("enter_introduction"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],

                  Text(
                    loc.translate("gender"),
                    style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(loc.translate("female")),
                          value: "Female",
                          groupValue: _gender,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          onChanged: (value) =>
                              setState(() => _gender = value ?? "Female"),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(loc.translate("male")),
                          value: "Male",
                          groupValue: _gender,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          onChanged: (value) =>
                              setState(() => _gender = value ?? "Male"),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  AppButton(
                    text: _isLoading
                        ? loc.translate("updating")
                        : loc.translate("update_profile_button"),
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
