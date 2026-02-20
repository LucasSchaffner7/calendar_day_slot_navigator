import 'package:flutter/material.dart';

import 'calendar_day_slot_navigator_controller.dart';
import 'selected_date_range_widget.dart';

/// Enum for specifying different date selection behaviors.
enum DateSelectionType {
  activeAllDates,
  activePastDates,
  activeFutureDates,
  activeTodayAndPastDates,
  activeTodayAndFutureDates,
  activeRangeDates,
  deActiveRangeDates,
}

/// Enum for choosing the display mode of days within date boxes.
enum DayDisplayMode {
  outsideDateBox,
  inDateBox,
}

/// Enum to control month and year selector position in the header.
enum MonthYearSelectorPosition {
  top,
  bottom,
  left,
  right,
}

/// Enum to specify the starting day of the week in the calendar.
enum WeekStartDay {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
}

@immutable
class CalendarDaySlotNavigator extends StatelessWidget {
  /// Number of days shown in each calendar day slot navigator.
  final int? slotLength;

  /// Color for highlighting selected dates.
  final Color? activeColor;

  /// Color for non-selected dates.
  final Color? deActiveColor;

  /// Gradient for highlighted selected dates.
  final bool? isGradientColor;

  /// Gradient for non-selected dates.
  final LinearGradient? activeGradientColor;

  /// Border radius for each day box.
  final LinearGradient? deActiveGradientColor;

  /// Border radius for month and year selection tabs.
  final double? dayBoxBorderRadius;

  /// Custom header text for the widget.
  final double? monthYearTabBorderRadius;

  /// Custom header text for the widget.
  final String? headerText;

  /// Callback triggered when a date is selected.
  final Function(DateTime selectedDate)? onDateSelect;

  /// List of specific dates to enable or disable.
  final List<DateTime>? rangeDates;

  /// Type of date selection functionality.
  final DateSelectionType? dateSelectionType;

  /// Display mode for days in the calendar. there are 2 types of design variants DayDisplayMode.outsideDateBox, DayDisplayMode.inDateBox
  final DayDisplayMode? dayDisplayMode;

  /// Font family name for text styling.
  final String? fontFamilyName;

  /// Specifies if Google Fonts are used.
  final bool? isGoogleFont;

  /// Width of the border around day boxes.
  final double? dayBorderWidth;

  /// Width for each day box.
  final double? dayBoxWidth;

  /// Height for each day box.
  final double? dayBoxHeight;

  /// Locale used to localize weekday and month labels.
  final Locale? locale;

  /// Position of month and year selectors in header.
  final MonthYearSelectorPosition? monthYearSelectorPosition;

  /// Scale factor for icons used in the widget, if any.
  final double? fontIconScale;

  /// Starting day of the week in the calendar. Only available when slotLength is 7.
  final WeekStartDay? weekStartDay;

  /// Optional controller to programmatically control selection and stay synced
  /// with other widgets.
  final CalendarDaySlotNavigatorController? controller;

  /// Label for the quick action "Jump to today" button.
  /// If null, defaults to "Today".
  final String? todayButtonText;

  /// Whether the "Today" quick action button is shown.
  final bool jumpToTodayButton;

  /// Constructor for CalendarDaySlotNavigator widget with optional parameters.
  const CalendarDaySlotNavigator({
    super.key,
    this.slotLength = 5,
    this.activeColor = const Color(0xffb644ae),
    this.deActiveColor = const Color(0xffffffff),
    this.isGradientColor = false,
    this.activeGradientColor = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xffb644ae),
        Color(0xffe06e6d),
      ],
    ),
    this.deActiveGradientColor = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xffffffff),
        Color(0xffffffff),
      ],
    ),
    this.dayBoxBorderRadius = 5,
    this.monthYearTabBorderRadius = 15,
    this.headerText,
    this.onDateSelect,
    this.rangeDates = const [],
    this.dateSelectionType = DateSelectionType.activeAllDates,
    this.dayDisplayMode = DayDisplayMode.outsideDateBox,
    this.fontFamilyName,
    this.isGoogleFont = false,
    this.dayBorderWidth = 1.0,
    this.dayBoxWidth,
    this.dayBoxHeight,
    this.locale = const Locale('en'),
    this.monthYearSelectorPosition = MonthYearSelectorPosition.top,
    this.fontIconScale = 1.0,
    this.weekStartDay = WeekStartDay.sunday,
    this.controller,
    this.todayButtonText,
    this.jumpToTodayButton = true,
  });

  @override
  Widget build(BuildContext context) {
    /// Determine text style based on whether Google Fonts are used.
    ///
    /// Note: Using `GoogleFonts.getFont` can trigger runtime attempts to load font
    /// assets (and thus the asset manifest) in environments like Flutter web.
    /// To keep this widget package-safe, we avoid reading asset manifests here.
    TextStyle textStyle = TextStyle(fontFamily: fontFamilyName);

    /// Return the configured widget with its customized properties.
    return SelectedDateRangeWidget(
      slotLength: slotLength,
      activeColor: activeColor,
      deActiveColor: deActiveColor,
      isGradientColor: isGradientColor,
      activeGradientColor: activeGradientColor,
      deActiveGradientColor: deActiveGradientColor,
      monthYearTabBorderRadius: monthYearTabBorderRadius,
      dayBoxBorderRadius: dayBoxBorderRadius,
      headerText: headerText,
      onDateSelect: onDateSelect,
      rangeDates: rangeDates,
      dateSelectionType: dateSelectionType,
      dayDisplayMode: dayDisplayMode,
      textStyle: textStyle,
      dayBorderWidth: dayBorderWidth,
      dayBoxWidth: dayBoxWidth,
      dayBoxHeight: dayBoxHeight,
      locale: locale,
      monthYearSelectorPosition: monthYearSelectorPosition,
      fontIconScale: fontIconScale,
      weekStartDay: weekStartDay,
      controller: controller,
      todayButtonText: todayButtonText,
      jumpToTodayButton: jumpToTodayButton,
    );
  }
}
