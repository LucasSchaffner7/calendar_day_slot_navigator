///all date functions
abstract class DateFunctions {
  // Getter instead of a static field so "today" is always the current date,
  // not the date the class was first loaded (stale static field bug).
  static DateTime get today => DateTime.now();

  ///check date is past date
  static bool isPastDate(DateTime date) {
    return date.isBefore(DateTime(today.year, today.month, today.day));
  }

  ///check date is future date
  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime(today.year, today.month, today.day));
  }

  /// check date is today or past date
  static bool isTodayAndPastDate(DateTime date) {
    return date.isBefore(DateTime(today.year, today.month, today.day)) || isToDayDate(date);
  }

  ///check date is today or future date
  static bool isTodayAndFutureDate(DateTime date) {
    return date.isAfter(DateTime(today.year, today.month, today.day)) || isToDayDate(date);
  }

  ///check date is today date
  static bool isToDayDate(DateTime date) {
    return date.year == today.year && date.month == today.month && date.day == today.day;
  }

  ///check 2 dates are same or not
  static bool isSameDates(DateTime dateStart, DateTime dateEnd) {
    return dateStart.year == dateEnd.year && dateStart.month == dateEnd.month && dateStart.day == dateEnd.day;
  }
}
