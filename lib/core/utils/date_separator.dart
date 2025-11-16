import 'package:flutter/cupertino.dart';

import '../localization/app_localizations.dart';

String formatDateSeparator(BuildContext context, DateTime date) {
  final loc = AppLocalizations.of(context);

  final localDate = date.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final msgDay = DateTime(localDate.year, localDate.month, localDate.day);

  if (msgDay == today) return loc.translate('today');
  if (msgDay == yesterday) return loc.translate('yesterday');

  final diff = today.difference(msgDay).inDays;
  if (diff < 7 && diff > 0) {
    final weekdays = [
      '', // 0-index bỏ trống
      loc.translate('monday'),
      loc.translate('tuesday'),
      loc.translate('wednesday'),
      loc.translate('thursday'),
      loc.translate('friday'),
      loc.translate('saturday'),
      loc.translate('sunday'),
    ];
    return weekdays[msgDay.weekday];
  }

  return '${msgDay.day.toString().padLeft(2, '0')}/${msgDay.month.toString().padLeft(2, '0')}/${msgDay.year}';
}
