

import 'package:easy_localization/easy_localization.dart';

String formatConversationTime(String? sentAt) {
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
    const weekdays = [
      '', // placeholder
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    return weekdays[date.weekday];
  }
}


