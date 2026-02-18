import 'package:calendar_day_slot_navigator/calendar_day_slot_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      locale: const Locale('de'),
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('es'),
        Locale('de'),
        Locale('it')
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calendar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime varSelectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffffffff),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: CalendarDaySlotNavigator(
          slotLength: 6,
          // How many days do you want to show at a time
          dayBoxHeightAspectRatio: 5,
          // Set dynamic height of a day box
          dayDisplayMode: DayDisplayMode.outsideDateBox,
          // There are 2 types of design variants DayDisplayMode.outsideDateBox, DayDisplayMode.inDateBox
          activeColor: const Color(0xffb644ae),
          // Sets a background color for selected date.
          deActiveColor: const Color(0xffffffff),
          // Sets a background color for unselected date.
          monthYearTabBorderRadius: 15,
          // Adjusts the border radius for month and year tabs.
          dayBoxBorderRadius: 10,
          // Set border radius of day box
          headerText: "Select Date",
          // You can give custom header text to this widget
          // Get a selected date tapped by user
          onDateSelect: (selectedDate) {},
          dateSelectionType: DateSelectionType.deActiveRangeDates,

          /// here you can set DateSelectionType scenarios for enable & disable dates which are add in below rangeDates property
          rangeDates: [
            // Add your range of dates for dateSelectionType scenarios
            DateTime(2024, 6, 9), DateTime(2024, 6, 6), DateTime(2024, 6, 8),
          ],
          fontFamilyName: "Lato",
          // Set custom fonts or google fonts name
          isGoogleFont: true,
          // Set true for google fonts
          dayBorderWidth: 0.5,
          // Set day box border width
        ));
  }
}
