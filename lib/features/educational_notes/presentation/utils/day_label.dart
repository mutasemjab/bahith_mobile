import '../../../../core/utils/extensions.dart';

/// "اليوم" / "غداً" for the next two days, otherwise the full Arabic date.
String dayLabel(DateTime date) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = day.difference(todayDate).inDays;
  if (diff == 0) return 'اليوم';
  if (diff == 1) return 'غداً';
  return date.arDate;
}
