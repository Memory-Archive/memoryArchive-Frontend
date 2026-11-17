/// Date formatting without an extra package. English only for now; swap for
/// package:intl when the app is localised.
abstract final class AppDateFormat {
  static const List<String> _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static String monthName(DateTime date) => _months[date.month - 1];

  static String weekdayName(DateTime date) => _weekdays[date.weekday - 1];

  /// 15 November 2023
  static String dayMonthYear(DateTime date) =>
      '${date.day} ${monthName(date)} ${date.year}';

  /// 15 Nov 2026
  static String short(DateTime date) =>
      '${date.day} ${monthName(date).substring(0, 3)} ${date.year}';

  /// Sunday, 15 November
  static String weekdayDayMonth(DateTime date) =>
      '${weekdayName(date)}, ${date.day} ${monthName(date)}';

  /// Wednesday, 15 November 2023
  static String full(DateTime date) =>
      '${weekdayName(date)}, ${dayMonthYear(date)}';

  /// 2023-11-15, the format sent to and expected from the API.
  static String iso(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  /// Good morning / afternoon / evening.
  static String greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  /// "3 years ago", "1 year ago".
  static String yearsAgo(DateTime date, DateTime now) {
    final years = now.year - date.year;
    return years == 1 ? '1 year ago' : '$years years ago';
  }

  /// "active now", "5 hours ago", "3 days ago".
  static String relative(DateTime date, DateTime now) {
    final difference = now.difference(date);
    if (difference.inMinutes < 5) return 'active now';
    if (difference.inHours < 1) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    }
    return difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
  }
}
