String formatDateSeparator(DateTime date) {
  final localDate = date.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final msgDay = DateTime(localDate.year, localDate.month, localDate.day);

  if (msgDay == today) return 'Hôm nay';
  if (msgDay == yesterday) return 'Hôm qua';

  final diff = today.difference(msgDay).inDays;
  if (diff < 7 && diff > 0) {
    const weekdays = [
      '', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'
    ];
    return weekdays[msgDay.weekday];
  }

  return '${msgDay.day.toString().padLeft(2, '0')}/${msgDay.month.toString().padLeft(2, '0')}/${msgDay.year}';
}
