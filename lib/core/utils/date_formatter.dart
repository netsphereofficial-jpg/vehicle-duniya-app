import 'package:intl/intl.dart';

/// Date and time formatting utilities
class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM');
  static final DateFormat _fullDateFormat = DateFormat('EEEE, dd MMMM yyyy');

  /// Format date as "dd MMM yyyy" (e.g., "25 Dec 2024")
  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return _dateFormat.format(date);
  }

  /// Format date and time as "dd MMM yyyy, hh:mm a"
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _dateTimeFormat.format(dateTime);
  }

  /// Format time only as "hh:mm a"
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _timeFormat.format(dateTime);
  }

  /// Format date as "dd/MM/yyyy"
  static String formatShortDate(DateTime? date) {
    if (date == null) return '-';
    return _shortDateFormat.format(date);
  }

  /// Format as "MMM yyyy" (e.g., "Dec 2024")
  static String formatMonthYear(DateTime? date) {
    if (date == null) return '-';
    return _monthYearFormat.format(date);
  }

  /// Format as "dd MMM" (e.g., "25 Dec")
  static String formatDayMonth(DateTime? date) {
    if (date == null) return '-';
    return _dayMonthFormat.format(date);
  }

  /// Format as full date (e.g., "Wednesday, 25 December 2024")
  static String formatFullDate(DateTime? date) {
    if (date == null) return '-';
    return _fullDateFormat.format(date);
  }

  /// Get relative time string (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return '-';

    final now = DateTime.now();
    final difference = dateTime.difference(now);
    final isPast = difference.isNegative;
    final duration = difference.abs();

    String timeStr;

    if (duration.inSeconds < 60) {
      timeStr = 'just now';
      return timeStr;
    } else if (duration.inMinutes < 60) {
      final minutes = duration.inMinutes;
      timeStr = '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else if (duration.inHours < 24) {
      final hours = duration.inHours;
      timeStr = '$hours ${hours == 1 ? 'hour' : 'hours'}';
    } else if (duration.inDays < 7) {
      final days = duration.inDays;
      timeStr = '$days ${days == 1 ? 'day' : 'days'}';
    } else if (duration.inDays < 30) {
      final weeks = (duration.inDays / 7).floor();
      timeStr = '$weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else if (duration.inDays < 365) {
      final months = (duration.inDays / 30).floor();
      timeStr = '$months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = (duration.inDays / 365).floor();
      timeStr = '$years ${years == 1 ? 'year' : 'years'}';
    }

    return isPast ? '$timeStr ago' : 'in $timeStr';
  }

  /// Get countdown string for auctions (e.g., "2d 5h 30m")
  static String getCountdown(DateTime? endTime) {
    if (endTime == null) return '-';

    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      return 'Ended';
    }

    final days = difference.inDays;
    final hours = difference.inHours.remainder(24);
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime? date) {
    if (date == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Get auction time label (e.g., "Today at 2:30 PM", "Tomorrow at 10:00 AM")
  static String getAuctionTimeLabel(DateTime? dateTime) {
    if (dateTime == null) return '-';

    if (isToday(dateTime)) {
      return 'Today at ${formatTime(dateTime)}';
    } else if (isTomorrow(dateTime)) {
      return 'Tomorrow at ${formatTime(dateTime)}';
    } else {
      return formatDateTime(dateTime);
    }
  }
}
