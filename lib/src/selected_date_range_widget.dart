import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';

import 'calendar_day_slot_navigator.dart';
import 'calendar_day_slot_navigator_controller.dart';
import 'date_functions.dart';

/// Enum for choosing the month page index.
enum MonthType {
  selected,
  previous,
  next,
}

/// StatefulWidget for displaying and interacting with a calendar with selectable date ranges.
class SelectedDateRangeWidget extends StatefulWidget {
  /// Number of days shown in each slot.
  final int? slotLength;

  /// Color for highlighting selected dates.
  final Color? activeColor;

  /// show other dates
  final Color? deActiveColor;

  /// Color for non-selected dates.
  final bool? isGradientColor;

  /// Gradient for selected date highlighting.
  final LinearGradient? activeGradientColor;

  /// Gradient for non-selected dates.
  final LinearGradient? deActiveGradientColor;

  /// Border radius for the day boxes.
  final double? dayBoxBorderRadius;

  /// Border radius for the tabs switching months and years.
  final double? monthYearTabBorderRadius;

  /// Customizable header text.
  final String? headerText;

  /// Callback function when a date is selected.
  final Function(DateTime selectedDate)? onDateSelect;

  /// List of specific dates to enable or disable.
  final List<DateTime>? rangeDates;

  /// Enum for different date selection scenarios.
  final DateSelectionType? dateSelectionType;

  /// there are 2 types of design variants DayDisplayMode.outsideDateBox, DayDisplayMode.inDateBox
  final DayDisplayMode? dayDisplayMode;

  /// Custom text style.
  final TextStyle? textStyle;

  ///  Border width for the day boxes.
  final double? dayBorderWidth;

  /// Aspect ratio for the height of day boxes.
  final double? dayBoxHeightAspectRatio;

  /// Locale used to localize weekday and month labels.
  final Locale? locale;

  /// Position of month and year selectors in header.
  final MonthYearSelectorPosition? monthYearSelectorPosition;

  /// Scale factor for font size and icon size
  final double? fontIconScale;

  /// Week start day for the calendar, default is Sunday.
  final WeekStartDay? weekStartDay;

  /// Optional controller to programmatically control selection and stay synced
  /// with other widgets.
  final CalendarDaySlotNavigatorController? controller;

  /// Whether the "Today" quick action button is shown.
  final bool jumpToTodayButton;

  const SelectedDateRangeWidget(
      {super.key,
      this.slotLength,
      this.activeColor,
      this.deActiveColor,
      this.isGradientColor,
      this.activeGradientColor,
      this.deActiveGradientColor,
      this.dayBoxBorderRadius,
      this.monthYearTabBorderRadius,
      this.headerText,
      this.onDateSelect,
      this.rangeDates,
      this.dateSelectionType,
      this.dayDisplayMode,
      this.textStyle,
      this.dayBorderWidth,
      this.dayBoxHeightAspectRatio,
      this.locale,
      this.monthYearSelectorPosition,
      this.fontIconScale,
      this.weekStartDay,
      this.controller,
      this.jumpToTodayButton = true});

  @override
  State<SelectedDateRangeWidget> createState() => _SelectedDateRangeWidgetState();
}

/// Private State class for SelectedDateRangeWidget to manage its state.
class _SelectedDateRangeWidgetState extends State<SelectedDateRangeWidget> implements CalendarDaySlotNavigatorHandle {
  String? dailyDate;
  DateTime? yearSelected;
  DateTime? monthSelected;
  int dateSelected = 0;
  var month = DateTime.now().month;
  List<List<DateTime>> listDate = [];
  List<DateTime> dates = [];
  var year = DateTime.now().year;
  var weekDays = [];
  bool isPreviousArrow = true;
  bool isNextArrow = true;
  int days = 0;
  int pageIndex = 0;
  DateTime nullDateTime = DateTime(0001, 1, 1);
  DateTime selectedDate = DateTime.now();
  DateTime todayDate = DateTime.now();
  late String _localeName = (widget.locale ?? WidgetsBinding.instance.platformDispatcher.locale).toString();
  double fontIconScale = 1.0;

  /// PageController to control the visible month.
  PageController pageController = PageController(viewportFraction: 1, keepPage: true);
  String? selectMonth;
  String? selectYear;
  late final currentMonth = DateFormat('MMMM', _localeName).format(DateTime.now());

  int slotLengthLocal = 0;

  void _updateLocaleFromContext() {
    final String resolvedLocale =
        (Localizations.maybeLocaleOf(context) ?? WidgetsBinding.instance.platformDispatcher.locale).toString();
    if (resolvedLocale != _localeName) {
      _localeName = resolvedLocale;
    }
  }

  CalendarDaySlotNavigatorController? _attachedController;

  void _attachControllerIfNeeded() {
    final newController = widget.controller;
    if (identical(_attachedController, newController)) return;

    _attachedController?.detach(this);
    _attachedController = newController;
    _attachedController?.attach(this);

    // Don’t notify during build; defer to post-frame to avoid setState-during-build
    // when parents listen to the controller.
    if (_attachedController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _attachedController?.updateSelectedDateFromWidget(selectedDate);
      });
    }
  }

  @override
  void didUpdateWidget(covariant SelectedDateRangeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _attachControllerIfNeeded();
    }

    if (widget.locale != oldWidget.locale) {
      _updateLocaleFromContext();
      getDatesInMonth(selectedDate, MonthType.selected);
    }

    if (widget.slotLength != oldWidget.slotLength) {
      slotLengthLocal = widget.slotLength!;
      nullDateTime = DateTime(0001, 1, 1);
      selectedDate = DateTime.now();
      todayDate = DateTime.now();
      getDatesInMonth(todayDate, MonthType.selected);
    }

    if (widget.weekStartDay != oldWidget.weekStartDay && slotLengthLocal == 7) {
      getDatesInMonth(selectedDate, MonthType.selected);
    }
  }

  @override
  void initState() {
    super.initState();

    /// Initialize locale for date formatting based on widget property or system settings.
    _localeName = WidgetsBinding.instance.platformDispatcher.locale.toString();

    /// Set the font and icon scale based on widget property or default to 1.0.
    fontIconScale = widget.fontIconScale!;

    /// Set the slot length for pagination based on widget property.
    slotLengthLocal = widget.slotLength!;

    /// initialize page view controller
    pageController = PageController(viewportFraction: 1, keepPage: true);

    /// Default today's date as selected.
    dateSelected = DateTime.now().day;

    /// Get all dates from current month.
    getDatesInMonth(DateTime.now(), MonthType.selected);

    /// Add listener to update arrows based on page position.
    pageController.addListener(
      () {
        if ((pageController.position.pixels == pageController.position.maxScrollExtent)) {
          isNextArrow = true;
          setState(() {});
        } else {
          isNextArrow = false;
          setState(() {});
        }
        if ((pageController.position.pixels == pageController.position.minScrollExtent)) {
          isPreviousArrow = true;
          setState(() {});
        } else {
          isPreviousArrow = false;
          setState(() {});
        }
      },
    );
    _attachControllerIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachControllerIfNeeded();

    final String oldLocale = _localeName;
    _updateLocaleFromContext();

    if (oldLocale != _localeName && listDate.isNotEmpty) {
      getDatesInMonth(selectedDate, MonthType.selected);
    }
  }

  /// Get all dates for the given month and organize them into weeks
  void getDatesInMonth(DateTime date, MonthType type) {
    listDate.clear();
    dates.clear();
    weekDays.clear();

    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    if (date.month == DateTime.now().month && date.year == DateTime.now().year) {
      dateSelected = DateTime.now().day;
    }

    selectMonth = DateFormat("MMMM", _localeName).format(date);

    /// Set year tab text and dialog box initial values.
    year = date.year;

    monthSelected = date;
    yearSelected = date;

    if (slotLengthLocal == 7) {
      final int leadingEmptySlots = widget.weekStartDay == WeekStartDay.monday
          ? firstDayOfMonth.weekday - DateTime.monday
          : firstDayOfMonth.weekday % 7;

      for (int i = 0; i < leadingEmptySlots; i++) {
        dates.add(nullDateTime);
        weekDays.add('');
      }
    }

    final difference = lastDayOfMonth.difference(firstDayOfMonth);
    for (int i = 0; i <= difference.inDays; i++) {
      var currentDay = firstDayOfMonth.add(Duration(days: i));
      dates.add(currentDay);
      weekDays.add(DateFormat('EEE', _localeName).format(currentDay));
    }

    int pageLength = (dates.length / slotLengthLocal).ceil();
    for (var i = 0; i < pageLength; i++) {
      var localList = dates.sublist(
        i * slotLengthLocal,
        (i * slotLengthLocal + slotLengthLocal) > dates.length ? dates.length : (i * slotLengthLocal + slotLengthLocal),
      );

      // Add remaining dates in slots if any.
      if (localList.length < slotLengthLocal) {
        int totalBlankDateSlots = slotLengthLocal - localList.length;
        int i = 0;
        do {
          localList.add(DateTime(0001, 1, 1));
          i++;
        } while (i < totalBlankDateSlots);
      }
      listDate.add(localList);
    }
    setPage(date, type);
  }

  /// Set the page index based on the selected date and update navigation flags.
  void setPage(DateTime date, MonthType type) {
    days = date.day;
    dailyDate = DateFormat("d/M/yyyy", _localeName).format(date);

    switch (type) {
      case MonthType.selected:
        {
          int currentDatePageIndex = -1;
          for (int i = 0; i < listDate.length; i++) {
            if (listDate[i].contains(DateTime(date.year, date.month, date.day))) {
              currentDatePageIndex = i;
              break;
            }
          }
          pageIndex = currentDatePageIndex;
          break;
        }

      case MonthType.previous:
        pageIndex = listDate.length - 1;
        break;

      case MonthType.next:
        pageIndex = 0;
        break;
    }

    ///show previous next date slot call back
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(pageIndex);
      }
    });

    setState(() {});
  }

  /// Determines if a date should be active or disabled based on DateSelectionType.
  bool isDateActive(DateTime date) {
    switch (widget.dateSelectionType) {
      case DateSelectionType.activeAllDates:
        return true;

      case DateSelectionType.activePastDates:
        return DateFunctions.isPastDate(date);

      case DateSelectionType.activeFutureDates:
        return DateFunctions.isFutureDate(date);

      case DateSelectionType.activeTodayAndPastDates:
        return DateFunctions.isTodayAndPastDate(date);

      case DateSelectionType.activeTodayAndFutureDates:
        return DateFunctions.isTodayAndFutureDate(date);

      case DateSelectionType.activeRangeDates:
        return (widget.rangeDates!.where((e) => DateFunctions.isSameDates(e, date)).toList().isNotEmpty) ? true : false;

      case DateSelectionType.deActiveRangeDates:
        return (widget.rangeDates!.where((e) => DateFunctions.isSameDates(e, date)).toList().isNotEmpty) ? false : true;

      default:
        return true;
    }
  }

  /// Navigate to the previous month's view.
  funcSetPreviousMonth() {
    if (pageController.page == 0.0) {
      if (listDate.isNotEmpty) {
        final List<DateTime> validDates =
            listDate.expand((week) => week).where((date) => date != nullDateTime).toList();

        if (validDates.isEmpty) {
          return;
        }

        DateTime varYesterdayDate = validDates.first.subtract(const Duration(days: 1));
        getDatesInMonth(varYesterdayDate, MonthType.previous);
      }
    }
  }

  /// Navigate to the next month's view.
  funcSetNextMonth() {
    if (pageController.page == listDate.length - 1) {
      if (listDate.isNotEmpty) {
        final List<DateTime> validDates =
            listDate.expand((week) => week).where((date) => date != nullDateTime).toList();

        if (validDates.isEmpty) {
          return;
        }

        DateTime varTomorrowDate = validDates.last.add(const Duration(days: 1));
        getDatesInMonth(varTomorrowDate, MonthType.next);
      }
    }
  }

  void _jumpToToday({bool animate = false}) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    // If the controller is driving us with animateToDate, it already animates.
    // For the inline UI button, a simple jump is the most predictable.
    setState(() {
      _setSelectedDateInternal(today, notify: true);
    });

    // Keep month/year tabs in sync.
    monthSelected = today;
    yearSelected = today;
    month = today.month;
    year = today.year;
    selectMonth = DateFormat('MMMM', _localeName).format(today);

    if (animate) {
      // Best-effort animation: after paging is ready, animate to computed page.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !pageController.hasClients) return;
        pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  Widget _buildMonthYearSelectors(context) {
    return Row(
      children: [
        // Month selection interactive tab.
        InkWell(
          onTap: () async {
            var selected = await showMonthPicker(
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: widget.activeColor!,
                      secondary: widget.deActiveColor!,
                      onSurface: widget.activeColor!,
                      onPrimary: widget.deActiveColor!,
                    ),
                    dialogTheme: DialogThemeData(backgroundColor: widget.activeColor!),
                    textTheme: TextTheme(
                      headlineSmall: widget.textStyle,
                      titleLarge: widget.textStyle,
                      labelSmall: widget.textStyle,
                      bodyLarge: widget.textStyle,
                      titleMedium: widget.textStyle,
                      titleSmall: widget.textStyle,
                      bodySmall: widget.textStyle,
                      labelLarge: widget.textStyle!.copyWith(color: Colors.white),
                      bodyMedium: widget.textStyle,
                      displayLarge: widget.textStyle,
                      displayMedium: widget.textStyle,
                      displaySmall: widget.textStyle,
                      headlineMedium: widget.textStyle,
                      headlineLarge: widget.textStyle,
                      labelMedium: widget.textStyle,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: widget.activeColor!,
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
              context: context,
              locale: Locale.fromSubtags(languageCode: _localeName),
              firstDate: DateTime(1900, 1, 1),
              lastDate: DateTime(2050, 12, 31),
              initialDate: monthSelected ?? DateTime.now(),
            );
            if (selected != null) {
              dates.clear();
              setState(() {
                monthSelected = selected;
                yearSelected = selected;
                month = selected.month;
                year = selected.year;
                selectMonth = DateFormat('MMMM', _localeName).format(selected);
                getDatesInMonth(selected, MonthType.selected);
              });
              // Selected month implies a new visible month; keep controller in sync.
              _attachedController?.updateSelectedDateFromWidget(selectedDate);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: widget.activeColor,
              borderRadius: BorderRadius.circular(widget.monthYearTabBorderRadius!),
            ),
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
              children: [
                Text(
                  selectMonth ?? currentMonth,
                  style: widget.textStyle!.copyWith(color: widget.deActiveColor!, fontSize: 16 * fontIconScale),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: widget.deActiveColor!,
                  size: 20 * fontIconScale,
                ),
              ],
            ),
          ),
        ),

        /// Year selection interactive tab
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: () async {
              var selected = await showDatePicker(
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: widget.activeColor!,
                        onPrimary: widget.deActiveColor!,
                        onSurface: widget.activeColor!,
                        surface: widget.deActiveColor!,
                      ),
                      dialogTheme: DialogThemeData(backgroundColor: widget.activeColor!),
                      textTheme: TextTheme(
                        headlineSmall: widget.textStyle,
                        titleLarge: widget.textStyle,
                        labelSmall: widget.textStyle,
                        bodyLarge: widget.textStyle,
                        titleMedium: widget.textStyle,
                        titleSmall: widget.textStyle,
                        bodySmall: widget.textStyle,
                        labelLarge: widget.textStyle!.copyWith(color: widget.activeColor!),
                        bodyMedium: widget.textStyle,
                        displayLarge: widget.textStyle,
                        displayMedium: widget.textStyle,
                        displaySmall: widget.textStyle,
                        headlineMedium: widget.textStyle,
                        headlineLarge: widget.textStyle,
                        labelMedium: widget.textStyle,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: widget.activeColor!,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
                context: context,
                locale: Locale.fromSubtags(languageCode: _localeName),
                firstDate: DateTime(1900, 1, 1),
                lastDate: DateTime(2050, 12, 31),
                initialDate: yearSelected ?? DateTime.now(),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (selected != null) {
                setState(() {
                  yearSelected = selected;
                  year = selected.year;
                  getDatesInMonth(selected, MonthType.selected);
                  monthSelected = selected;
                  selectMonth = DateFormat('MMMM', _localeName).format(selected);
                  selectedDate = selected;
                  widget.onDateSelect!(selectedDate);
                });
                _attachedController?.updateSelectedDateFromWidget(selectedDate);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: widget.activeColor,
                borderRadius: BorderRadius.circular(widget.monthYearTabBorderRadius!),
              ),
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                children: [
                  Text(
                    year.toString(),
                    style: widget.textStyle!.copyWith(color: widget.deActiveColor!, fontSize: 16 * fontIconScale),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: widget.deActiveColor!,
                    size: 20 * fontIconScale,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Jump to today button
        if (widget.jumpToTodayButton)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: _jumpToToday,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  // Slightly different look: outlined pill.
                  color: widget.deActiveColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: (widget.activeColor ?? Theme.of(context).colorScheme.primary),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.today_outlined,
                      size: 18 * fontIconScale,
                      color: widget.activeColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Today',
                      style: widget.textStyle?.copyWith(
                            fontSize: 14 * fontIconScale,
                            fontWeight: FontWeight.w600,
                            color: widget.activeColor,
                          ) ??
                          TextStyle(
                            fontSize: 14 * fontIconScale,
                            fontWeight: FontWeight.w600,
                            color: widget.activeColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _attachedController?.detach(this);
    super.dispose();
  }

  void _setSelectedDateInternal(DateTime date, {required bool notify}) {
    selectedDate = date;
    dateSelected = date.day;
    dailyDate = DateFormat("d/M/yyyy", _localeName).format(date);

    // Recompute list/page for the month that contains [date].
    getDatesInMonth(date, MonthType.selected);

    if (notify) {
      widget.onDateSelect?.call(date);
      _attachedController?.updateSelectedDateFromWidget(date);
    }
  }

  @override
  void jumpToDate(DateTime date, {required bool notify}) {
    if (!mounted) return;
    setState(() {
      _setSelectedDateInternal(date, notify: notify);
    });
  }

  @override
  Future<void> animateToDate(
    DateTime date, {
    required Duration duration,
    required Curve curve,
    required bool notify,
  }) async {
    if (!mounted) return;

    // Compute pages for the target month.
    setState(() {
      // We want the selection applied immediately so the highlight updates.
      selectedDate = date;
      dateSelected = date.day;
      dailyDate = DateFormat("d/M/yyyy", _localeName).format(date);
      getDatesInMonth(date, MonthType.selected);
    });

    // Wait until after current build.
    await Future<void>.delayed(Duration.zero);

    if (pageController.hasClients) {
      await pageController.animateToPage(
        pageIndex,
        duration: duration,
        curve: curve,
      );
    } else {
      // Fallback.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients) {
          pageController.jumpToPage(pageIndex);
        }
      });
    }

    if (notify) {
      widget.onDateSelect?.call(date);
      _attachedController?.updateSelectedDateFromWidget(date);
    }
  }

  double _clampDouble(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  double _preferredDayRowHeightFor(double availableWidth) {
    // Treat dayBoxHeightAspectRatio as a *preference*.
    // Historically this widget used an AspectRatio; that breaks in tight height
    // constraints (e.g. inside a pill container). We convert it into a preferred
    // height based on the available width.
    final double ratio = (widget.dayBoxHeightAspectRatio ?? 9).toDouble();
    final double clampedRatio = _clampDouble(ratio, 1.5, 20.0);

    // Approximate the width available to the PageView by removing arrows.
    // This doesn’t need to be exact; it’s only used as a preferred height.
    const double arrowWidth = 36;
    final double pageWidth = (availableWidth - (arrowWidth * 2)).clamp(0.0, availableWidth);

    // Same behavior as AspectRatio (width / height = aspectRatio).
    final double preferredHeight = pageWidth == 0 ? 0 : (pageWidth / clampedRatio);

    // Keep a sensible min/max so it stays tappable.
    return _clampDouble(preferredHeight, 40.0, 96.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _attachControllerIfNeeded();

        final double parentWidth = constraints.maxWidth;
        final double maxHeight = constraints.hasBoundedHeight ? constraints.maxHeight : double.infinity;

        // Reserve room for the optional bottom month/year selectors.
        final bool hasBottomSelectors = widget.monthYearSelectorPosition == MonthYearSelectorPosition.bottom;
        final double bottomSelectorsReserve = hasBottomSelectors ? 52.0 : 0.0;

        final double preferredDayRowHeight = _preferredDayRowHeightFor(parentWidth);
        final double availableForDayRow =
            maxHeight.isFinite ? (maxHeight - bottomSelectorsReserve) : preferredDayRowHeight;

        // If we’re in a tight container, shrink the day row instead of overflowing.
        final double dayRowHeight = availableForDayRow.isFinite
            ? _clampDouble(preferredDayRowHeight, 32.0, availableForDayRow)
            : preferredDayRowHeight;

        const double arrowWidth = 36.0;

        return SizedBox(
            width: parentWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Header text, month and year selection tabs.
                if (widget.headerText != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                    child: Row(
                      children: [
                        // Display header text.
                        Expanded(
                          child: Text(
                            widget.headerText!,
                            style: widget.textStyle!.copyWith(
                                fontSize: 22 * fontIconScale, color: widget.activeColor, fontWeight: FontWeight.w500),
                          ),
                        ),

                        if (widget.monthYearSelectorPosition == MonthYearSelectorPosition.top) ...[
                          _buildMonthYearSelectors(context),
                          const SizedBox(
                            width: 12,
                          )
                        ],
                      ],
                    ),
                  ),

                // Container for navigation arrows and calendar days.
                Container(
                  padding: EdgeInsets.only(top: widget.headerText == null ? 0 : 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.monthYearSelectorPosition == MonthYearSelectorPosition.left) ...[
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _buildMonthYearSelectors(context),
                            ),
                          ),
                        ),
                      ],

                      // Previous button
                      SizedBox(
                        width: arrowWidth,
                        height: dayRowHeight,
                        child: Center(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: arrowWidth,
                              height: arrowWidth,
                            ),
                            onPressed: () {
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                              funcSetPreviousMonth();
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_outlined,
                              color: widget.activeColor,
                              size: 20 * fontIconScale,
                            ),
                          ),
                        ),
                      ),

                      /// Display the calendar day slots within a PageView builder.
                      Expanded(
                        child: SizedBox(
                          height: dayRowHeight,
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: listDate.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: listDate[index].map((date) {
                                  bool isActive = isDateActive(date);
                                  bool isSelected = date.day == selectedDate.day &&
                                          date.month == selectedDate.month &&
                                          date.year == selectedDate.year
                                      ? true
                                      : false;

                                  if (date.day == selectedDate.day && !isActive) {
                                    isSelected = false;
                                  }

                                  return Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 5),
                                    child: DateFormat('yyyy', _localeName).format(date) == "0001"
                                        ? const SizedBox()
                                        : GestureDetector(
                                            onTap: !isActive
                                                ? null
                                                : () {
                                                    setState(() {
                                                      selectedDate = date;
                                                      dateSelected = date.day;
                                                      dailyDate = DateFormat("d/M/yyyy", _localeName).format(date);
                                                      if (widget.onDateSelect != null) {
                                                        widget.onDateSelect!(date);
                                                      }
                                                      _attachedController?.updateSelectedDateFromWidget(date);
                                                    });
                                                  },
                                            child:

                                                /// Layout 1: Display mode for day outside date box.
                                                widget.dayDisplayMode == DayDisplayMode.outsideDateBox
                                                    ? Column(
                                                        children: [
                                                          Text(
                                                            DateFormat('EEE', _localeName).format(date),
                                                            style: widget.textStyle!.copyWith(
                                                              fontSize: 16 * fontIconScale,
                                                              color: isActive
                                                                  ? widget.activeColor
                                                                  : widget.activeColor!.withValues(alpha: .5),
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              decoration: !widget.isGradientColor!
                                                                  ? BoxDecoration(
                                                                      color: isSelected
                                                                          ? widget.activeColor
                                                                          : widget.deActiveColor,
                                                                      borderRadius: BorderRadius.circular(
                                                                          widget.dayBoxBorderRadius!),
                                                                      border: (widget.dayBorderWidth == null ||
                                                                              widget.dayBorderWidth == 0)
                                                                          ? null
                                                                          : Border.all(
                                                                              width: widget.dayBorderWidth!,
                                                                              color: !isSelected
                                                                                  ? widget.activeColor!
                                                                                  : widget.activeColor!
                                                                                      .withValues(alpha: 0.1),
                                                                            ))
                                                                  : BoxDecoration(
                                                                      gradient: isSelected
                                                                          ? widget.activeGradientColor
                                                                          : widget.deActiveGradientColor,
                                                                      borderRadius: BorderRadius.circular(
                                                                          widget.dayBoxBorderRadius!),
                                                                      border: (widget.dayBorderWidth == null ||
                                                                              widget.dayBorderWidth == 0)
                                                                          ? null
                                                                          : Border.all(
                                                                              width: widget.dayBorderWidth!,
                                                                              color: !isSelected
                                                                                  ? widget.activeColor!
                                                                                  : widget.activeColor!
                                                                                      .withValues(alpha: 0.1),
                                                                            )),
                                                              child: Center(
                                                                child: FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  // Adjusts the text to fit the box
                                                                  child: Text(
                                                                    date.day.toString(),
                                                                    style: widget.textStyle!.copyWith(
                                                                      fontSize: 16 * fontIconScale,
                                                                      color: !isActive
                                                                          ? widget.activeColor!.withValues(alpha: 0.5)
                                                                          : isSelected
                                                                              ? widget.deActiveColor
                                                                              : widget.activeColor,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 1,
                                                          )
                                                        ],
                                                      )
                                                    :

                                                    /// Layout 2: Display mode for day inside date box.
                                                    Container(
                                                        decoration: !widget.isGradientColor!
                                                            ? BoxDecoration(
                                                                color: isSelected
                                                                    ? widget.activeColor
                                                                    : widget.deActiveColor,
                                                                borderRadius:
                                                                    BorderRadius.circular(widget.dayBoxBorderRadius!),
                                                                border: Border.all(
                                                                  width: widget.dayBorderWidth!,
                                                                  color: (widget.dayBorderWidth == null ||
                                                                          widget.dayBorderWidth == 0)
                                                                      ? widget.activeColor!.withValues(alpha: 0)
                                                                      : !isSelected
                                                                          ? widget.activeColor!
                                                                          : widget.activeColor!.withValues(alpha: 0.1),
                                                                ))
                                                            : BoxDecoration(
                                                                gradient: isSelected
                                                                    ? widget.activeGradientColor
                                                                    : widget.deActiveGradientColor,
                                                                borderRadius:
                                                                    BorderRadius.circular(widget.dayBoxBorderRadius!),
                                                                border: Border.all(
                                                                  width: widget.dayBorderWidth!,
                                                                  color: (widget.dayBorderWidth == null ||
                                                                          widget.dayBorderWidth == 0)
                                                                      ? widget.activeColor!.withValues(alpha: 0)
                                                                      : !isSelected
                                                                          ? widget.activeColor!
                                                                          : widget.activeColor!.withValues(alpha: 0.1),
                                                                )),
                                                        child: LayoutBuilder(
                                                          builder: (context, constraints) {
                                                            // Force the content to respect the available height;
                                                            // this prevents Column (RenderFlex) overflows in tight layouts.
                                                            final maxH = constraints.maxHeight.isFinite
                                                                ? constraints.maxHeight
                                                                : double.infinity;

                                                            // Slightly reduce the default line heights to make the
                                                            // two-line layout more resilient to textScaleFactor.
                                                            final weekdayStyle = widget.textStyle!.copyWith(
                                                              fontSize: 14 * fontIconScale,
                                                              height: 1.0,
                                                              color: !isActive
                                                                  ? widget.activeColor!.withValues(alpha: 0.5)
                                                                  : isSelected
                                                                      ? widget.deActiveColor
                                                                      : widget.activeColor,
                                                            );

                                                            final dayStyle = widget.textStyle!.copyWith(
                                                              fontSize: 20 * fontIconScale,
                                                              height: 1.0,
                                                              fontWeight: FontWeight.bold,
                                                              color: !isActive
                                                                  ? widget.activeColor!.withValues(alpha: 0.5)
                                                                  : isSelected
                                                                      ? widget.deActiveColor
                                                                      : widget.activeColor,
                                                            );

                                                            return ConstrainedBox(
                                                              constraints: BoxConstraints(
                                                                // If we have a finite height, keep the inner Column
                                                                // from asking for more than it can get.
                                                                maxHeight: maxH,
                                                              ),
                                                              child: Center(
                                                                child: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Flexible(
                                                                      child: FittedBox(
                                                                        fit: BoxFit.scaleDown,
                                                                        child: Text(
                                                                          DateFormat('EEE', _localeName).format(date),
                                                                          style: weekdayStyle,
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(height: 2),
                                                                    Flexible(
                                                                      child: FittedBox(
                                                                        fit: BoxFit.scaleDown,
                                                                        child: Text(
                                                                          date.day.toString(),
                                                                          style: dayStyle,
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                          ),
                                  ));
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ),

                      // Next button
                      SizedBox(
                        width: arrowWidth,
                        height: dayRowHeight,
                        child: Center(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: arrowWidth,
                              height: arrowWidth,
                            ),
                            onPressed: () {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                              funcSetNextMonth();
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: widget.activeColor,
                              size: 20 * fontIconScale,
                            ),
                          ),
                        ),
                      ),

                      if (widget.monthYearSelectorPosition == MonthYearSelectorPosition.right) ...[
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _buildMonthYearSelectors(context),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (hasBottomSelectors) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildMonthYearSelectors(context),
                  ),
                ],
              ],
            ));
      },
    );
  }
}
