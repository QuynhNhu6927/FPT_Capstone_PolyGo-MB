import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';

class PolyGoTerms extends StatefulWidget {
  const PolyGoTerms({super.key});

  @override
  State<PolyGoTerms> createState() => _PolyGoTermsState();
}

class _PolyGoTermsState extends State<PolyGoTerms> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryText = isDark ? Colors.grey[400] : Colors.grey[600];

    Widget _dot({required bool isActive}) {
      return Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? theme.colorScheme.primary : secondaryText,
        ),
      );
    }

    Widget _section(String titleKey, List<String> contentKeys) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate(titleKey),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            ...contentKeys.map(
                  (k) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  loc.translate(k),
                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TITLE của slide hiện tại
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _pageIndex == 0
                    ? loc.translate("terms_of_service")
                    : loc.translate("privacy_policy"),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Divider(color: secondaryText, thickness: 0.5),
            const SizedBox(height: 8),

            // Nội dung PAGEVIEW
            SizedBox(
              height: 450,
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                children: [
                  // Slide 1: Terms of Service (6 mục)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _section("tos_section1_title", [
                          "tos_section1_line1",
                          "tos_section1_line2",
                          "tos_section1_line3",
                        ]),
                        _section("tos_section2_title", [
                          "tos_section2_line1",
                          "tos_section2_line2",
                        ]),
                        _section("tos_section3_title", [
                          "tos_section3_line1",
                          "tos_section3_line2",
                          "tos_section3_line3",
                          "tos_section3_line4",
                          "tos_section3_line5",
                          "tos_section3_line6",
                        ]),
                        _section("tos_section4_title", [
                          "tos_section4_line1",
                          "tos_section4_line2",
                        ]),
                        _section("tos_section5_title", [
                          "tos_section5_line1",
                          "tos_section5_line2",
                          "tos_section5_line3",
                          "tos_section5_line4",
                        ]),
                        _section("tos_section6_title", [
                          "tos_section6_line1",
                          "tos_section6_line2",
                        ]),
                      ],
                    ),
                  ),

                  // Slide 2: Privacy Policy (9 mục)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _section("pp_section1_title", [
                          "pp_section1_line1",
                          "pp_section1_line2",
                          "pp_section1_line3",
                          "pp_section1_line4",
                        ]),
                        _section("pp_section2_title", [
                          "pp_section2_line1",
                          "pp_section2_line2",
                          "pp_section2_line3",
                          "pp_section2_line4",
                        ]),
                        _section("pp_section3_title", [
                          "pp_section3_line1",
                          "pp_section3_line2",
                          "pp_section3_line3",
                        ]),
                        _section("pp_section4_title", [
                          "pp_section4_line1",
                          "pp_section4_line2",
                          "pp_section4_line3",
                          "pp_section4_line4",
                        ]),
                        _section("pp_section5_title", [
                          "pp_section5_line1",
                          "pp_section5_line2",
                          "pp_section5_line3",
                          "pp_section5_line4",
                        ]),
                        _section("pp_section6_title", [
                          "pp_section6_line1",
                          "pp_section6_line2",
                          "pp_section6_line3",
                        ]),
                        _section("pp_section7_title", [
                          "pp_section7_line1",
                          "pp_section7_line2",
                          "pp_section7_line3",
                        ]),
                        _section("pp_section8_title", [
                          "pp_section8_line1",
                          "pp_section8_line2",
                        ]),
                        _section("pp_section9_title", [
                          "pp_section9_line1",
                          "pp_section9_line2",
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // DOT INDICATOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(isActive: _pageIndex == 0),
                _dot(isActive: _pageIndex == 1),
              ],
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
