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

  /// Label for the quick action "Jump to today" button.
  /// If null, defaults to "Today".
  ///
  /// Note: This package doesn't ship its own l10n strings; to localize this
  /// label, pass the translated string from your app.
  final String? todayButtonText;

  /// Whether the "Today" quick action button is shown.
  final bool? jumpToTodayButton;

  /// Width for day box
  final double? dayBoxWidth;

  /// Height for day box
  final double? dayBoxHeight;

  /// When true, hides the separate month pill and merges month + year into a
  /// single pill that opens one date-picker dialog (month & year together).
  final bool compactMonthYearPicker;

  const SelectedDateRangeWidget({
    super.key,
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
    this.dayBoxWidth,
    this.dayBoxHeight,
    this.locale,
    this.monthYearSelectorPosition,
    this.fontIconScale,
    this.weekStartDay,
    this.controller,
    this.todayButtonText,
    this.jumpToTodayButton = true,
    this.compactMonthYearPicker = false,
  });

  @override
  State<SelectedDateRangeWidget> createState() => _SelectedDateRangeWidgetState();
}

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

  late PageController pageController;
  String? selectMonth;
  late String currentMonth;
  int slotLengthLocal = 0;

  CalendarDaySlotNavigatorController? _attachedController;

  void _updateLocaleFromContext() {
    final String resolvedLocale =
        (Localizations.maybeLocaleOf(context) ?? WidgetsBinding.instance.platformDispatcher.locale).toString();
    if (resolvedLocale != _localeName) {
      _localeName = resolvedLocale;
    }
  }

  void _attachControllerIfNeeded() {
    final newController = widget.controller;
    if (identical(_attachedController, newController)) return;
    _attachedController?.detach(this);
    _attachedController = newController;
    _attachedController?.attach(this);
    if (_attachedController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _attachedController?.updateSelectedDateFromWidget(selectedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _localeName = (widget.locale ?? WidgetsBinding.instance.platformDispatcher.locale).toString();
    fontIconScale = widget.fontIconScale!;
    slotLengthLocal = widget.slotLength!;
    pageController = PageController(viewportFraction: 1, keepPage: true);
    dateSelected = DateTime.now().day;
    currentMonth = DateFormat('MMMM', _localeName).format(DateTime.now());
    getDatesInMonth(DateTime.now(), MonthType.selected);
    pageController.addListener(() {
      final pos = pageController.position;
      isPreviousArrow = pos.pixels == pos.minScrollExtent;
      isNextArrow = pos.pixels == pos.maxScrollExtent;
      setState(() {});
    });
    _attachControllerIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachControllerIfNeeded();
    final old = _localeName;
    _updateLocaleFromContext();
    if (old != _localeName && listDate.isNotEmpty) {
      getDatesInMonth(selectedDate, MonthType.selected);
    }
  }

  @override
  void didUpdateWidget(covariant SelectedDateRangeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) _attachControllerIfNeeded();
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
  void dispose() {
    _attachedController?.detach(this);
    pageController.dispose();
    super.dispose();
  }

  void getDatesInMonth(DateTime date, MonthType type) {
    listDate.clear();
    dates.clear();
    weekDays.clear();

    final first = DateTime(date.year, date.month, 1);
    final last = DateTime(date.year, date.month + 1, 0);

    if (date.month == DateTime.now().month && date.year == DateTime.now().year) {
      dateSelected = DateTime.now().day;
    }
    selectMonth = DateFormat('MMMM', _localeName).format(date);
    year = date.year;
    monthSelected = date;
    yearSelected = date;

    if (slotLengthLocal == 7) {
      final int leading =
          widget.weekStartDay == WeekStartDay.monday ? first.weekday - DateTime.monday : first.weekday % 7;
      for (int i = 0; i < leading; i++) {
        dates.add(nullDateTime);
        weekDays.add('');
      }
    }

    final diff = last.difference(first);
    for (int i = 0; i <= diff.inDays; i++) {
      final d = first.add(Duration(days: i));
      dates.add(d);
      weekDays.add(DateFormat('EEE', _localeName).format(d));
    }

    final pageLen = (dates.length / slotLengthLocal).ceil();
    for (int i = 0; i < pageLen; i++) {
      final end = ((i + 1) * slotLengthLocal).clamp(0, dates.length);
      final chunk = dates.sublist(i * slotLengthLocal, end);
      while (chunk.length < slotLengthLocal) {
        chunk.add(DateTime(0001, 1, 1));
      }
      listDate.add(chunk);
    }
    setPage(date, type);
  }

  void setPage(DateTime date, MonthType type) {
    days = date.day;
    dailyDate = DateFormat('d/M/yyyy', _localeName).format(date);
    switch (type) {
      case MonthType.selected:
        int idx = -1;
        for (int i = 0; i < listDate.length; i++) {
          if (listDate[i].contains(DateTime(date.year, date.month, date.day))) {
            idx = i;
            break;
          }
        }
        pageIndex = idx;
        break;
      case MonthType.previous:
        pageIndex = listDate.length - 1;
        break;
      case MonthType.next:
        pageIndex = 0;
        break;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) pageController.jumpToPage(pageIndex);
    });
    setState(() {});
  }

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
        return widget.rangeDates!.any((e) => DateFunctions.isSameDates(e, date));
      case DateSelectionType.deActiveRangeDates:
        return !widget.rangeDates!.any((e) => DateFunctions.isSameDates(e, date));
      default:
        return true;
    }
  }

  void funcSetPreviousMonth() {
    if (pageController.page == 0.0 && listDate.isNotEmpty) {
      final valid = listDate.expand((w) => w).where((d) => d != nullDateTime).toList();
      if (valid.isEmpty) return;
      getDatesInMonth(valid.first.subtract(const Duration(days: 1)), MonthType.previous);
    }
  }

  void funcSetNextMonth() {
    if (pageController.page == listDate.length - 1 && listDate.isNotEmpty) {
      final valid = listDate.expand((w) => w).where((d) => d != nullDateTime).toList();
      if (valid.isEmpty) return;
      getDatesInMonth(valid.last.add(const Duration(days: 1)), MonthType.next);
    }
  }

  void _jumpToToday() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    setState(() => _setSelectedDateInternal(today, notify: true));
    monthSelected = today;
    yearSelected = today;
    month = today.month;
    year = today.year;
    selectMonth = DateFormat('MMMM', _localeName).format(today);
  }

  void _setSelectedDateInternal(DateTime date, {required bool notify}) {
    selectedDate = date;
    dateSelected = date.day;
    dailyDate = DateFormat('d/M/yyyy', _localeName).format(date);
    getDatesInMonth(date, MonthType.selected);
    if (notify) {
      widget.onDateSelect?.call(date);
      _attachedController?.updateSelectedDateFromWidget(date);
    }
  }

  @override
  void jumpToDate(DateTime date, {required bool notify}) {
    if (!mounted) return;
    setState(() => _setSelectedDateInternal(date, notify: notify));
  }

  @override
  Future<void> animateToDate(DateTime date,
      {required Duration duration, required Curve curve, required bool notify}) async {
    if (!mounted) return;
    setState(() {
      selectedDate = date;
      dateSelected = date.day;
      dailyDate = DateFormat('d/M/yyyy', _localeName).format(date);
      getDatesInMonth(date, MonthType.selected);
    });
    await Future<void>.delayed(Duration.zero);
    if (pageController.hasClients) {
      await pageController.animateToPage(pageIndex, duration: duration, curve: curve);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients) pageController.jumpToPage(pageIndex);
      });
    }
    if (notify) {
      widget.onDateSelect?.call(date);
      _attachedController?.updateSelectedDateFromWidget(date);
    }
  }

  double _clamp(double v, double mn, double mx) => v < mn ? mn : (v > mx ? mx : v);

  // ── Day cell decoration ──────────────────────────────────────────────────

  BoxDecoration _dayDecoration(bool isSelected) {
    final bool noBorder = widget.dayBorderWidth == null || widget.dayBorderWidth == 0;
    final Color bc = isSelected ? widget.activeColor!.withValues(alpha: 0.1) : widget.activeColor!;
    if (!widget.isGradientColor!) {
      return BoxDecoration(
        color: isSelected ? widget.activeColor : widget.deActiveColor,
        borderRadius: BorderRadius.circular(widget.dayBoxBorderRadius!),
        border: noBorder ? null : Border.all(width: widget.dayBorderWidth!, color: bc),
      );
    }
    return BoxDecoration(
      gradient: isSelected ? widget.activeGradientColor : widget.deActiveGradientColor,
      borderRadius: BorderRadius.circular(widget.dayBoxBorderRadius!),
      border: noBorder ? null : Border.all(width: widget.dayBorderWidth!, color: bc),
    );
  }

  Color _labelColor(bool isActive, bool isSelected) {
    if (!isActive) return widget.activeColor!.withValues(alpha: 0.5);
    return isSelected ? widget.deActiveColor! : widget.activeColor!;
  }

  // ── Layout 1: weekday outside the box ────────────────────────────────────

  Widget _outsideBox(DateTime date, bool isActive, bool isSelected) {
    return Column(
      children: [
        Text(
          DateFormat('EEE', _localeName).format(date),
          style: widget.textStyle!.copyWith(
            fontSize: 16 * fontIconScale,
            color: isActive ? widget.activeColor : widget.activeColor!.withValues(alpha: 0.5),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Expanded(
          child: Container(
            decoration: _dayDecoration(isSelected),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(date.day.toString(),
                    style: widget.textStyle!.copyWith(
                      fontSize: 16 * fontIconScale,
                      color: _labelColor(isActive, isSelected),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
            ),
          ),
        ),
        const SizedBox(height: 1),
      ],
    );
  }

  // ── Layout 2: weekday inside the box ─────────────────────────────────────

  Widget _insideBox(DateTime date, bool isActive, bool isSelected) {
    final wStyle =
        widget.textStyle!.copyWith(fontSize: 14 * fontIconScale, height: 1.0, color: _labelColor(isActive, isSelected));
    final dStyle = widget.textStyle!.copyWith(
        fontSize: 20 * fontIconScale,
        height: 1.0,
        fontWeight: FontWeight.bold,
        color: _labelColor(isActive, isSelected));

    return Container(
      decoration: _dayDecoration(isSelected),
      child: LayoutBuilder(builder: (_, cons) {
        final double maxH = cons.maxHeight.isFinite ? cons.maxHeight : double.infinity;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(DateFormat('EEE', _localeName).format(date),
                        style: wStyle, overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(date.day.toString(), style: dStyle, overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Month/year selector row ───────────────────────────────────────────────

  Widget _buildMonthYearSelectors(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.compactMonthYearPicker)
          // ── Compact: single "Month Year" pill ─────────────────────────────
          InkWell(
            onTap: () async {
              final sel = await showDatePicker(
                builder: (ctx, child) => _applyTheme(ctx, child, labelColor: widget.activeColor!),
                context: context,
                locale: Locale.fromSubtags(languageCode: _localeName),
                firstDate: DateTime(1900),
                lastDate: DateTime(2050, 12, 31),
                initialDate: monthSelected ?? DateTime.now(),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (sel != null) {
                setState(() {
                  yearSelected = sel;
                  monthSelected = sel;
                  month = sel.month;
                  year = sel.year;
                  selectMonth = DateFormat('MMMM', _localeName).format(sel);
                  getDatesInMonth(sel, MonthType.selected);
                  selectedDate = sel;
                  widget.onDateSelect?.call(selectedDate);
                });
                _attachedController?.updateSelectedDateFromWidget(selectedDate);
              }
            },
            child: _pill(Row(children: [
              Text(
                '${selectMonth ?? currentMonth} $year',
                style: widget.textStyle!.copyWith(color: widget.deActiveColor!, fontSize: 16 * fontIconScale),
              ),
              const SizedBox(width: 5),
              Icon(Icons.keyboard_arrow_down_rounded, color: widget.deActiveColor!, size: 20 * fontIconScale),
            ])),
          )
        else ...[
          // ── Normal: separate Month pill ───────────────────────────────────
          InkWell(
            onTap: () async {
              final sel = await showMonthPicker(
                builder: (ctx, child) => _applyTheme(ctx, child, labelColor: Colors.white),
                context: context,
                locale: Locale.fromSubtags(languageCode: _localeName),
                firstDate: DateTime(1900),
                lastDate: DateTime(2050, 12, 31),
                initialDate: monthSelected ?? DateTime.now(),
              );
              if (sel != null) {
                dates.clear();
                setState(() {
                  monthSelected = sel;
                  yearSelected = sel;
                  month = sel.month;
                  year = sel.year;
                  selectMonth = DateFormat('MMMM', _localeName).format(sel);
                  getDatesInMonth(sel, MonthType.selected);
                });
                _attachedController?.updateSelectedDateFromWidget(selectedDate);
              }
            },
            child: _pill(Row(children: [
              Text(selectMonth ?? currentMonth,
                  style: widget.textStyle!.copyWith(color: widget.deActiveColor!, fontSize: 16 * fontIconScale)),
              const SizedBox(width: 5),
              Icon(Icons.keyboard_arrow_down_rounded, color: widget.deActiveColor!, size: 20 * fontIconScale),
            ])),
          ),
          // ── Normal: separate Year pill ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
              onTap: () async {
                final sel = await showDatePicker(
                  builder: (ctx, child) => _applyTheme(ctx, child, labelColor: widget.activeColor!),
                  context: context,
                  locale: Locale.fromSubtags(languageCode: _localeName),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2050, 12, 31),
                  initialDate: yearSelected ?? DateTime.now(),
                  initialDatePickerMode: DatePickerMode.year,
                );
                if (sel != null) {
                  setState(() {
                    yearSelected = sel;
                    year = sel.year;
                    getDatesInMonth(sel, MonthType.selected);
                    monthSelected = sel;
                    selectMonth = DateFormat('MMMM', _localeName).format(sel);
                    selectedDate = sel;
                    widget.onDateSelect!(selectedDate);
                  });
                  _attachedController?.updateSelectedDateFromWidget(selectedDate);
                }
              },
              child: _pill(Row(children: [
                Text(year.toString(),
                    style: widget.textStyle!.copyWith(color: widget.deActiveColor!, fontSize: 16 * fontIconScale)),
                const SizedBox(width: 5),
                Icon(Icons.keyboard_arrow_down_rounded, color: widget.deActiveColor!, size: 20 * fontIconScale),
              ])),
            ),
          ),
        ],

        // ── Today button (always shown when enabled) ─────────────────────────
        if (widget.jumpToTodayButton ?? true)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: _jumpToToday,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: widget.deActiveColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: widget.activeColor ?? Theme.of(context).colorScheme.primary, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.today_outlined, size: 18 * fontIconScale, color: widget.activeColor),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.todayButtonText ?? 'Today',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (widget.textStyle ?? const TextStyle()).copyWith(
                          fontSize: 14 * fontIconScale,
                          fontWeight: FontWeight.w600,
                          color: widget.activeColor,
                        ),
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

  Widget _pill(Widget child) => Container(
        decoration: BoxDecoration(
          color: widget.activeColor,
          borderRadius: BorderRadius.circular(widget.monthYearTabBorderRadius!),
        ),
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: child,
      );

  Widget _applyTheme(BuildContext ctx, Widget? child, {required Color labelColor}) {
    final s = widget.textStyle;
    return Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: ColorScheme.light(
          primary: widget.activeColor!,
          onPrimary: widget.deActiveColor!,
          onSurface: widget.activeColor!,
          surface: widget.deActiveColor!,
          secondary: widget.deActiveColor!,
        ),
        dialogTheme: DialogThemeData(backgroundColor: widget.activeColor!),
        textTheme: TextTheme(
          headlineSmall: s,
          titleLarge: s,
          labelSmall: s,
          bodyLarge: s,
          titleMedium: s,
          titleSmall: s,
          bodySmall: s,
          labelLarge: s?.copyWith(color: labelColor),
          bodyMedium: s,
          displayLarge: s,
          displayMedium: s,
          displaySmall: s,
          headlineMedium: s,
          headlineLarge: s,
          labelMedium: s,
        ),
        textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: widget.activeColor!)),
      ),
      child: child!,
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _attachControllerIfNeeded();

    const double arrowWidth = 36.0;
    final int slotCount = slotLengthLocal;
    final double? explicitCellWidth = widget.dayBoxWidth;
    final bool selectorsInline = widget.monthYearSelectorPosition == MonthYearSelectorPosition.left ||
        widget.monthYearSelectorPosition == MonthYearSelectorPosition.right;

    // PageView REQUIRES a finite bounded width.
    // Use MediaQuery for the fallback (avoids LayoutBuilder).
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double totalWidth = (explicitCellWidth != null && !selectorsInline)
        ? (arrowWidth * 2) + (slotCount * explicitCellWidth)
        : screenWidth;

    final double pageViewWidth = explicitCellWidth != null
        ? (slotCount * explicitCellWidth).clamp(1.0, double.infinity)
        : (totalWidth - arrowWidth * 2).clamp(1.0, double.infinity);

    // Row height — explicit value or stable default.
    final double rowHeight = widget.dayBoxHeight != null ? _clamp(widget.dayBoxHeight!, 24.0, 200.0) : 56.0;

    // Cell sizing
    const double pad = 5.0;
    final double cellOuter;
    final double cellPad;
    if (explicitCellWidth != null) {
      cellOuter = explicitCellWidth;
      cellPad = pad;
    } else {
      final double maxPad = slotCount > 0 ? (pageViewWidth / slotCount / 4).clamp(0.0, pad) : 0.0;
      cellPad = maxPad;
      cellOuter = slotCount > 0 ? (pageViewWidth / slotCount) : pageViewWidth;
    }
    final double cellInner = (cellOuter - cellPad * 2).clamp(0.0, cellOuter);

    final bool hasBottom = widget.monthYearSelectorPosition == MonthYearSelectorPosition.bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        if (widget.headerText != null || widget.monthYearSelectorPosition == MonthYearSelectorPosition.top)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.headerText != null)
                  Expanded(
                    child: Text(widget.headerText!,
                        style: widget.textStyle!.copyWith(
                            fontSize: 22 * fontIconScale, color: widget.activeColor, fontWeight: FontWeight.w500)),
                  ),
                if (widget.monthYearSelectorPosition == MonthYearSelectorPosition.top) ...[
                  Flexible(
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _buildMonthYearSelectors(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ],
            ),
          ),

        // Navigation row
        Padding(
          padding: EdgeInsets.only(top: widget.headerText == null ? 0 : 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.monthYearSelectorPosition == MonthYearSelectorPosition.left)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildMonthYearSelectors(context),
                  ),

                // ← button
                SizedBox(
                  width: arrowWidth,
                  height: rowHeight,
                  child: Center(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                      onPressed: () {
                        pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
                        funcSetPreviousMonth();
                      },
                      icon: Icon(Icons.arrow_back_ios_outlined, color: widget.activeColor, size: 20 * fontIconScale),
                    ),
                  ),
                ),

                // PageView — always gets a finite width via SizedBox
                SizedBox(
                  width: pageViewWidth,
                  height: rowHeight,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: listDate.length,
                    itemBuilder: (_, index) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: listDate[index].map((date) {
                          // Blank placeholder
                          if (date == nullDateTime) {
                            return SizedBox(width: cellOuter);
                          }
                          final bool isActive = isDateActive(date);
                          bool isSelected = date.day == selectedDate.day &&
                              date.month == selectedDate.month &&
                              date.year == selectedDate.year;
                          if (!isActive) isSelected = false;

                          return SizedBox(
                            width: cellOuter,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: cellPad),
                              child: SizedBox(
                                width: cellInner,
                                child: GestureDetector(
                                  onTap: !isActive
                                      ? null
                                      : () => setState(() {
                                            selectedDate = date;
                                            dateSelected = date.day;
                                            dailyDate = DateFormat('d/M/yyyy', _localeName).format(date);
                                            widget.onDateSelect?.call(date);
                                            _attachedController?.updateSelectedDateFromWidget(date);
                                          }),
                                  child: widget.dayDisplayMode == DayDisplayMode.outsideDateBox
                                      ? _outsideBox(date, isActive, isSelected)
                                      : _insideBox(date, isActive, isSelected),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),

                // → button
                SizedBox(
                  width: arrowWidth,
                  height: rowHeight,
                  child: Center(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                      onPressed: () {
                        pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
                        funcSetNextMonth();
                      },
                      icon: Icon(Icons.arrow_forward_ios_outlined, color: widget.activeColor, size: 20 * fontIconScale),
                    ),
                  ),
                ),

                if (widget.monthYearSelectorPosition == MonthYearSelectorPosition.right)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildMonthYearSelectors(context),
                  ),
              ],
            ),
          ), // SingleChildScrollView
        ),

        if (hasBottom) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMonthYearSelectors(context),
            ],
          ),
        ],
      ],
    );
  }
}
