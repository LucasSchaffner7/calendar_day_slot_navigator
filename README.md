# 📅 Calendar_Day_Slot_Navigator

[![pub package](https://img.shields.io/pub/v/calendar_day_slot_navigator.svg)](https://pub.dev/packages/calendar_day_slot_navigator)

A powerful and highly customizable Flutter calendar widget that makes date selection beautiful and
intuitive. Whether you're building a booking app, scheduling system, or any application that needs
elegant date picking, CalendarSlot provides the flexibility and features you need.

<img src="https://raw.githubusercontent.com/DevCodeSpace/calendar_day_slot_navigator/main/assets/banner1.png" />

## ✨ Features

- 🌗 **Theming Support**
    - Seamless integration with both light and dark modes
    - Full control over colors and gradients
    - Customizable active and inactive states

- 🎨 **Advanced Customization**
    - Flexible border radius for all elements
    - Custom header text and styling (or hide header)
    - Adjustable day box dimensions and borders
    - Support for custom fonts including Google Fonts
    - Configurable font/icon scaling

- 📆 **Powerful Selection Options**
    - Single date selection
    - Date range selection
    - Customizable active/inactive date ranges
    - Multiple calendar layout options

- 🎯 **Flexible Display Modes**
    - Inside box day display
    - Outside box day display
    - Adjustable slot length for different view sizes
    - Week start day customization (e.g. Monday/Sunday)
    - Configurable month/year selector position (top/left/right/bottom)

- 🌍 **Localization**
    - Locale-aware weekday and month labels

## 🚀 Getting Started

### Installation

Add calendar_day_slot_navigator to your project by including it in your `pubspec.yaml`:

```yaml
dependencies:
  calendar_day_slot_navigator: ^0.0.2
```

Run pub get to install the package:

```bash
flutter pub get
```

### Import

Import the package in your Dart file:

```dart
import 'package:calendar_day_slot_navigator/calendar_day_slot_navigator.dart';
```

## 💻 Usage Examples

### Basic Implementation

Here's a simple example to get you started:

```dart
CalendarDaySlotNavigator
(
slotLength: 5,
dayDisplayMode: DayDisplayMode.outsideDateBox,
headerText: "Select Date",
onDateSelect: (selectedDate) {
print("Selected date: $selectedDate");
},
)
```

### Custom Styling

Add beautiful gradients and custom styling:

```dart
CalendarDaySlotNavigator
(
slotLength: 7,
dayBoxHeightAspectRatio: 8,
dayDisplayMode: DayDisplayMode.insideDateBox,
isGradientColor: true,
activeGradientColor: LinearGradient(
colors: [
Color(0xffb644ae),
Color(0xff873999),
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
monthYearTabBorderRadius: 15,
dayBoxBorderRadius: 10,
headerText: "Select Your Preferred Date",
fontFamilyName: "Roboto",
isGoogleFont: true,
dayBorderWidth: 0.5,
onDateSelect: (selectedDate) {
print("Selected date: $selectedDate");
},
)
```

### Month/Year Selector Position

```dart
CalendarDaySlotNavigator
(
monthYearSelectorPosition
:
MonthYearSelectorPosition
.
left
, // top, left, right, bottom
)
```

### Hide the Header

```dart
CalendarDaySlotNavigator
(
headerText
:
null
,
)
```

### Week Start Day

```dart
CalendarDaySlotNavigator
(
weekStartDay
:
WeekStartDay
.
monday
, // or WeekStartDay.sunday
)
```

### Font and Icon Scaling

```dart
CalendarDaySlotNavigator
(
fontScale
:
1.2
, // Increase all text size by 20%
iconScale
:
0.9
, // Decrease icon size by 10%
)
```

### Localization (Locale-aware labels)

```dart
MaterialApp
(
locale: const Locale('fr'),
supportedLocales: const [Locale('en'), Locale('fr')],
localizationsDelegates: [
GlobalMaterialLocalizations.delegate,
GlobalWidgetsLocalizations.delegate,
GlobalCupertinoLocalizations.delegate,
],
home: CalendarDaySlotNavigator(),
)
```

### Date Range Selection

Implement date range selection with specific active dates:

```dart
CalendarDaySlotNavigator
(
dateSelectionType: DateSelectionType.activeRangeDates,
rangeDates: [
DateTime(2024, 6, 1),
DateTime(2024, 6, 2),
DateTime(2024, 6, 3),
DateTime(2024, 6, 4),
DateTime(2024, 6, 5),
],
onDateSelect: (selectedDate) {
print("Selected date within range: $selectedDate");
},
)
```

## 🛠️ Properties Guide

### Essential Properties

| Property                | Type             | Default        | Description                                                                                                      |
|-------------------------|------------------|----------------|------------------------------------------------------------------------------------------------------------------|
| slotLength              | `int?`           | 7              | 📏 Determines how many days are displayed in each row. Useful for different screen sizes and layouts.            |
| dayBoxHeightAspectRatio | `double?`        | 6.0            | 📐 Controls the height of day boxes relative to their width. Higher values make boxes shorter.                   |
| dayDisplayMode          | `DayDisplayMode` | outsideDateBox | 🎯 Determines where day names appear relative to date boxes. Choose between `outsideDateBox` or `insideDateBox`. |
| weekStartDay            | `WeekStartDay`   | sunday         | 📅 Controls first weekday shown when `slotLength: 7`.                                                            |

### Styling Properties

| Property                 | Type              | Default       | Description                                    |
|--------------------------|-------------------|---------------|------------------------------------------------|
| activeColor              | `Color?`          | Theme primary | 🎨 Background color for selected dates         |
| deActiveColor            | `Color?`          | White         | ⚪️ Background color for unselected dates       |
| isGradientColor          | `bool?`           | false         | 🌈 Enable gradient backgrounds for dates       |
| activeGradientColor      | `LinearGradient?` | null          | 🎨 Custom gradient for selected dates          |
| deActiveGradientColor    | `LinearGradient?` | null          | ⚪️ Custom gradient for unselected dates        |
| monthYearTabBorderRadius | `double?`         | 10.0          | 📏 Border radius for month/year selection tabs |
| dayBoxBorderRadius       | `double?`         | 8.0           | 📏 Border radius for individual day boxes      |
| dayBorderWidth           | `double?`         | 1.0           | ✏️ Width of borders around day boxes           |
| fontScale                | `double?`         | 1.0           | 🔠 Scales text size inside the widget          |
| iconScale                | `double?`         | 1.0           | 🔎 Scales icon size inside the widget          |

### Font Properties

| Property       | Type      | Default | Description                            |
|----------------|-----------|---------|----------------------------------------|
| fontFamilyName | `String?` | System  | 🔤 Name of the font family to use      |
| isGoogleFont   | `bool?`   | false   | 📱 Set to true when using Google Fonts |

### Layout & Localization Properties

| Property                  | Type                        | Default       | Description                                                       |
|---------------------------|-----------------------------|---------------|-------------------------------------------------------------------|
| monthYearSelectorPosition | `MonthYearSelectorPosition` | top           | 📌 Position of the month/year selector (top, left, right, bottom) |
| headerText                | `String?`                   | 'Select Date' | 🏷️ Header text (set to null to hide)                             |

### Selection Properties

| Property          | Type                  | Description                                      |
|-------------------|-----------------------|--------------------------------------------------|
| dateSelectionType | `DateSelectionType`   | 🎯 Controls which dates can be selected          |
| rangeDates        | `List<DateTime>?`     | 📅 List of dates for range-based selection types |
| onDateSelect      | `Function(DateTime)?` | 🖱️ Callback function when a date is selected    |

### Date Selection Types Explained

1. **activeAllDates**
    - All dates in the calendar are selectable
    - Useful for unrestricted date picking

2. **activePastDates**
    - Only dates before today are selectable
    - Perfect for selecting historical dates

3. **activeFutureDates**
    - Only dates after today are selectable
    - Ideal for booking systems and scheduling

4. **activeTodayAndPastDates**
    - Today and all past dates are selectable
    - Good for recording past events including today

5. **activeTodayAndFutureDates**
    - Today and all future dates are selectable
    - Great for appointment scheduling

6. **activeRangeDates**
    - Only specified dates in `rangeDates` are selectable
    - Useful for custom date ranges

7. **deActiveRangeDates**
    - Specified dates in `rangeDates` are not selectable
    - Perfect for blocking out unavailable dates

## 📱 Display Modes

### Outside Date Box Mode

```dart
dayDisplayMode: DayDisplayMode.outsideDateBox
```

- Day names appear above the date boxes
- Provides a clean, separated look
- More space for date numbers

### Inside Date Box Mode

```dart
dayDisplayMode: DayDisplayMode.insideDateBox
```

- Day names appear inside the date boxes
- More compact layout
- Ideal for space-conscious designs

## 🎨 Styling Tips

1. **Color Combinations**
   ```dart
   activeColor: Color(0xffb644ae),    // Purple for selected
   deActiveColor: Color(0xffF5F5F5),  // Light grey for unselected
   ```

2. **Gradient Effects**
   ```dart
   isGradientColor: true,
   activeGradientColor: LinearGradient(
     colors: [Color(0xffb644ae), Color(0xff873999)],
     begin: Alignment.topLeft,
     end: Alignment.bottomRight,
   ),
   ```

3. **Border Styling**
   ```dart
   dayBoxBorderRadius: 12,
   dayBorderWidth: 0.5,
   ```

## 💡 Best Practices

1. **Responsive Design**
    - Adjust `slotLength` based on screen width
    - Use appropriate `dayBoxHeightAspectRatio` for different screen sizes

2. **Selection Types**
    - Choose appropriate `dateSelectionType` for your use case
    - Always handle `onDateSelect` callback for user interactions

3. **Accessibility**
    - Use sufficient color contrast
    - Provide clear header text
    - Consider font size and readability

## 🤝 Contributing

[![](https://raw.githubusercontent.com/DevCodeSpace/calendar_day_slot_navigator/refs/heads/main/assets/contributors.png)](https://github.com/DevCodeSpace/calendar_day_slot_navigator/graphs/contributors)

---
> Made with ❤️ by the DevCodeSpace