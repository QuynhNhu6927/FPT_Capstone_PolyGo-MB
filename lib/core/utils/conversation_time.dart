

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import '../localization/app_localizations.dart';

String formatConversationTime(BuildContext context, String? sentAt) {
  final loc = AppLocalizations.of(context);
  if (sentAt == null || sentAt.isEmpty) return '';

  final date = DateTime.tryParse(sentAt)?.toLocal();
  if (date == null) return '';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final messageDay = DateTime(date.year, date.month, date.day);

  if (messageDay == today) {
    return DateFormat('HH:mm').format(date);
  } else {
    // Thứ 2 = Monday = 1, Sunday = 7
    final weekdays = [
      '', // placeholder
      loc.translate('monday'),
      loc.translate('tuesday'),
      loc.translate('wednesday'),
      loc.translate('thursday'),
      loc.translate('friday'),
      loc.translate('saturday'),
      loc.translate('sunday'),
    ];
    return weekdays[date.weekday];
  }
}


