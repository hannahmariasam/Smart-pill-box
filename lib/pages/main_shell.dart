import 'package:flutter/material.dart';

import '../data/dose_data.dart';
import '../theme/app_theme.dart';
import 'auth_helpers.dart';
import 'daily_dose_tracking.dart';
import 'dashboard_page.dart' show DashboardPage;
import 'device_status.dart';
import 'intake_history.dart';
import 'medication_schedule.dart';
import 'medicine_list.dart';
import 'notifications_page.dart' show NotificationsPage;
import 'profile_page.dart';
import 'vacation_page.dart' show VacationPage;

/// Home screen after login: holds the side (hamburger) menu and switches
/// between the main pages.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.medication_outlined, 'Medicines'),
    (Icons.calendar_month_outlined, 'Schedule'),
    (Icons.fact_check_outlined, 'Daily Tracking'),
    (Icons.history, 'Intake History'),
    (Icons.notifications_none, 'Notifications'),
    (Icons.luggage_outlined, 'Vacation Mode'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    // Lets pages jump to another tab (e.g. "View history").
    shellNavigate = (i) {
      // Family members can only see the dashboard.
      if (mounted && !Session.isFamily) setState(() => _index = i);
    };
  }

  @override
  void dispose() {
    shellNavigate = null;
    super.dispose();
  }

  Widget _page() {
    if (Session.isFamily) return const DashboardPage();
    switch (_index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const MedicineListPage();
      case 2:
        return const MedicationSchedulePage();
      case 3:
        return const DailyDoseTrackingPage();
      case 4:
        return const IntakeHistoryPage();
      case 5:
        return const NotificationsPage();
      case 6:
        return StatefulBuilder(
          builder: (context, setState) => VacationPage(
            enabled: Session.vacationMode,
            onChanged: (v) => setState(() => Session.vacationMode = v),
          ),
        );
      default:
        return const ProfilePage();
    }
  }

  Widget _drawerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
    Color? color,
  }) {
    final fg = color ?? (selected ? AppColors.primary : AppColors.ink);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? AppColors.bg : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, size: 22, color: fg),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Make sure today's / this week's doses exist before pages read them.
    DoseData.sync();

    return Scaffold(
      key: shellScaffoldKey,
      backgroundColor: AppColors.bg,
      drawer: Session.isFamily ? null : Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.medication_outlined,
                          size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'PillCare',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          Fmt.initials(Session.name),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Session.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              Session.roleLabel,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (var i = 0; i < _items.length; i++)
                _drawerTile(
                  icon: _items[i].$1,
                  label: _items[i].$2,
                  selected: _index == i,
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    setState(() => _index = i);
                  },
                ),
              _drawerTile(
                icon: Icons.devices_outlined,
                label: 'Device Status',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DeviceStatusPage(),
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Divider(color: AppColors.border, height: 1),
              ),
              _drawerTile(
                icon: Icons.logout,
                label: 'Log out',
                color: AppColors.danger,
                onTap: () {
                  Session.clear();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (_) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // A new key per page rebuilds it so it shows the latest data.
      body: KeyedSubtree(key: ValueKey(_index), child: _page()),
    );
  }
}
