import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/interests/me_interests_model.dart';
import '../../../data/repositories/interest_repository.dart';
import '../../../data/services/apis/interest_service.dart';
import '../../../main.dart';
import '../../shared/app_error_state.dart';

class UpdateInterests extends StatefulWidget {
  final void Function(List<String> selected) onFinish;
  final VoidCallback onBack;
  final List<String>? initialSelected;

  const UpdateInterests({
    super.key,
    required this.onFinish,
    required this.onBack,
    this.initialSelected,
  });

  @override
  State<UpdateInterests> createState() => _UpdateInterestsState();
}

class _UpdateInterestsState extends State<UpdateInterests> {
  late List<String> _selected;
  List<MeInterestModel> _interests = [];
  bool _isLoading = true;
  String? _error;
  late final InterestRepository _repo;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _repo = InterestRepository(InterestService(ApiClient()));
    _selected = widget.initialSelected ?? [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = InheritedLocale.of(context).locale;
    if (_currentLocale == null || _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _fetchInterests(lang: locale.languageCode);
    }
  }

  Future<void> _fetchInterests({String? lang}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final interests = await _repo.getMeInterests(token, lang: lang ?? 'vi');

      setState(() {
        _interests = interests;
        if (_selected.isEmpty) {
          _selected = interests.where((e) => e.has).map((e) => e.id).toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load interests: $e';
        _isLoading = false;
      });
    }
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    final borderColorDefault = theme.dividerColor;
    final borderColorSelected = theme.colorScheme.primary;
    final textColorDefault = theme.textTheme.bodyMedium!.color;
    final textColorSelected = theme.colorScheme.primary;
    final backgroundDefault = theme.cardColor;
    final backgroundSelected = theme.colorScheme.primary.withOpacity(0.1);

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth ~/ 220).clamp(2, 6);

    return SingleChildScrollView(
      padding: EdgeInsets.all(sw(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.all(sw(context, 12)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(sw(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite,
                size: sw(context, 36),
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: sh(context, 20)),
          Text(
            loc.translate("step_interests_title"),
            textAlign: TextAlign.center,
            style: t.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: st(context, 24),
            ),
          ),
          SizedBox(height: sh(context, 6)),
          Text(
            loc.translate("choose_your_interests"),
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: st(context, 14),
            ),
          ),
          SizedBox(height: sh(context, 20)),
          Container(
            padding: EdgeInsets.all(sw(context, 16)),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(sw(context, 16)),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.dark
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? AppErrorState(onRetry: () => _fetchInterests(lang: _currentLocale?.languageCode))
                : GridView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _interests.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3.8,
              ),
              itemBuilder: (context, index) {
                final interest = _interests[index];
                final selected = _selected.contains(interest.id);
                return GestureDetector(
                  onTap: () => _toggle(interest.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? borderColorSelected : borderColorDefault,
                        width: 1,
                      ),
                      color: selected ? backgroundSelected : backgroundDefault,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (interest.iconUrl.isNotEmpty)
                          Image.network(
                            interest.iconUrl,
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        if (interest.iconUrl.isNotEmpty) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            interest.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: t.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: selected ? textColorSelected : textColorDefault,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: sh(context, 32)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton(
                text: loc.translate("back"),
                variant: ButtonVariant.outline,
                onPressed: widget.onBack,
              ),
              AppButton(
                text: loc.translate("finish"),
                onPressed: _selected.isEmpty ? null : () => widget.onFinish(_selected),
                disabled: _selected.isEmpty,
              ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
