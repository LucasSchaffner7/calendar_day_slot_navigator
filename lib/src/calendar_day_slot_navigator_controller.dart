import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';

/// Controller for [CalendarDaySlotNavigator] to drive selection/navigation from
/// outside and to stay in sync with other widgets.
///
/// The widget attaches itself to the controller. If a method is called before
/// attachment, the last requested selection is queued and applied on attach.
class CalendarDaySlotNavigatorController extends ChangeNotifier {
  DateTime? _selectedDate;
  DateTime? _pendingDate;

  /// Currently selected date as reported by the widget.
  DateTime? get selectedDate => _selectedDate;

  /// True if a widget is currently attached.
  bool get isAttached => _handle != null;

  CalendarDaySlotNavigatorHandle? _handle;

  /// Internal: used by the widget to attach itself to this controller.
  void attach(CalendarDaySlotNavigatorHandle handle) {
    _handle = handle;

    // Apply a queued selection if one was set before the widget mounted.
    final pending = _pendingDate;
    _pendingDate = null;
    if (pending != null) {
      // Don’t await; controller API is fire-and-forget.
      handle.jumpToDate(pending, notify: true);
    }
  }

  /// Internal: used by the widget to detach itself from this controller.
  void detach(CalendarDaySlotNavigatorHandle handle) {
    if (identical(_handle, handle)) {
      _handle = null;
    }
  }

  /// Internal: used by the widget to report a new selected date.
  void updateSelectedDateFromWidget(DateTime date) {
    if (_selectedDate == date) return;
    _selectedDate = date;
    notifyListeners();
  }

  /// Jump immediately to [date] and select it.
  void jumpToDate(DateTime date) {
    final handle = _handle;
    if (handle == null) {
      _pendingDate = date;
      return;
    }

    handle.jumpToDate(date, notify: true);
  }

  /// Animate to [date] and select it.
  Future<void> animateToDate(
    DateTime date, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    final handle = _handle;
    if (handle == null) {
      _pendingDate = date;
      return;
    }

    await handle.animateToDate(date,
        duration: duration, curve: curve, notify: true);
  }
}

/// Internal widget<->controller bridge.
///
/// This is intentionally not exported publicly; consumers interact only through
/// [CalendarDaySlotNavigatorController].
abstract class CalendarDaySlotNavigatorHandle {
  void jumpToDate(DateTime date, {required bool notify});

  Future<void> animateToDate(
    DateTime date, {
    required Duration duration,
    required Curve curve,
    required bool notify,
  });
}
