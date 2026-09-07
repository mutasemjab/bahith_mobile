import 'package:intl/intl.dart';

extension NumFormatting on num {
  /// Formats a number using Arabic-Indic digits, e.g. 1234 -> ١٬٢٣٤
  String get arDigits => NumberFormat.decimalPattern('ar').format(this);
}

extension DateFormatting on DateTime {
  String get arDate => DateFormat('d MMMM yyyy', 'ar').format(this);
  String get arDateTime =>
      DateFormat('d MMMM yyyy - hh:mm a', 'ar').format(this);
}

extension DurationFormatting on Duration {
  /// mm:ss or hh:mm:ss depending on length — used for exam countdowns.
  String get clock {
    final h = inHours;
    final m = inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')}:$m:$s';
    return '$m:$s';
  }
}

extension StringNullOrEmpty on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
