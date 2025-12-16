import 'package:flutter/material.dart';
import '../../../../data/models/events/joined_event_model.dart';
import '../../../../../core/utils/render_utils.dart';
import '../../../../../core/localization/app_localizations.dart';

class DescriptionSection extends StatelessWidget {
  final JoinedEventModel event;

  const DescriptionSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    final double fontSize = 14;
    final double lineHeight = 1.4;
    final double maxLines = 9;
    final double maxHeight = fontSize * lineHeight * maxLines + 8; // + padding nhỏ

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      child: SingleChildScrollView(
        child: RenderUtils.selectableMarkdownText(
          context,
          event.description.isNotEmpty
              ? event.description
              : loc.translate('no_description'),
          style: TextStyle(
            fontSize: fontSize,
            height: lineHeight,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
