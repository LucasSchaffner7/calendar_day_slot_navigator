import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_day_slot_navigator/src/date_functions.dart';

void main() {
  group('DateFunctions', () {
    test('isPastDate returns true for a date before today', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFunctions.isPastDate(past), isTrue);
    });

    test('isPastDate returns false for today', () {
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      expect(DateFunctions.isPastDate(todayMidnight), isFalse);
    });

    test('isPastDate returns false for a future date', () {
      final future = DateTime.now().add(const Duration(days: 1));
      expect(DateFunctions.isPastDate(future), isFalse);
    });

    test('isFutureDate returns true for a date after today', () {
      final future = DateTime.now().add(const Duration(days: 1));
      expect(DateFunctions.isFutureDate(future), isTrue);
    });

    test('isFutureDate returns false for today', () {
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      expect(DateFunctions.isFutureDate(todayMidnight), isFalse);
    });

    test('isFutureDate returns false for a past date', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFunctions.isFutureDate(past), isFalse);
    });

    test('isTodayAndPastDate returns true for today', () {
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      expect(DateFunctions.isTodayAndPastDate(todayMidnight), isTrue);
    });

    test('isTodayAndPastDate returns true for a past date', () {
      final past = DateTime.now().subtract(const Duration(days: 5));
      expect(DateFunctions.isTodayAndPastDate(past), isTrue);
    });

    test('isTodayAndPastDate returns false for a future date', () {
      final future = DateTime.now().add(const Duration(days: 1));
      expect(DateFunctions.isTodayAndPastDate(future), isFalse);
    });

    test('isTodayAndFutureDate returns true for today', () {
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      expect(DateFunctions.isTodayAndFutureDate(todayMidnight), isTrue);
    });

    test('isTodayAndFutureDate returns true for a future date', () {
      final future = DateTime.now().add(const Duration(days: 3));
      expect(DateFunctions.isTodayAndFutureDate(future), isTrue);
    });

    test('isTodayAndFutureDate returns false for a past date', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFunctions.isTodayAndFutureDate(past), isFalse);
    });

    test('isToDayDate returns true for today', () {
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      expect(DateFunctions.isToDayDate(todayMidnight), isTrue);
    });

    test('isToDayDate returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFunctions.isToDayDate(yesterday), isFalse);
    });

    test('isToDayDate returns false for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(DateFunctions.isToDayDate(tomorrow), isFalse);
    });

    test('isSameDates returns true for two identical dates', () {
      final a = DateTime(2024, 6, 15);
      final b = DateTime(2024, 6, 15, 23, 59, 59);
      expect(DateFunctions.isSameDates(a, b), isTrue);
    });

    test('isSameDates returns false for different dates', () {
      final a = DateTime(2024, 6, 15);
      final b = DateTime(2024, 6, 16);
      expect(DateFunctions.isSameDates(a, b), isFalse);
    });

    test('isSameDates returns false for same day in different months', () {
      final a = DateTime(2024, 5, 15);
      final b = DateTime(2024, 6, 15);
      expect(DateFunctions.isSameDates(a, b), isFalse);
    });

    test('isSameDates returns false for same day in different years', () {
      final a = DateTime(2023, 6, 15);
      final b = DateTime(2024, 6, 15);
      expect(DateFunctions.isSameDates(a, b), isFalse);
    });
  });
}
