
import 'package:flutter/material.dart';

import 'screens/medication_schedule.dart';
import 'screens/daily_dose_tracking.dart';
import 'screens/intake_history.dart';

void main() {
  runApp(const PillDispenserApp());
}

class PillDispenserApp extends StatelessWidget {
  const PillDispenserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Pill Dispenser',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const Member3Home(),
    );
  }
}

class Member3Home extends StatefulWidget {
  const Member3Home({super.key});

  @override
  State<Member3Home> createState() => _Member3HomeState();
}

class _Member3HomeState extends State<Member3Home> {

  int selectedIndex = 0;

  final List<Widget> pages = const [
    MedicationSchedulePage(),
    DailyDoseTrackingPage(),
    IntakeHistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),

          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Tracking',
          ),

          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
