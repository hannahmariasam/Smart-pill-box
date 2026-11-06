import 'package:flutter/material.dart';

import '../theme/app_theme.dart' show SegmentedTabs;


// ---------------- Side menu (drawer) ----------------
final GlobalKey<ScaffoldState> shellScaffoldKey = GlobalKey<ScaffoldState>();

/// Lets any page switch the main shell to another tab (set by MainShell).
/// Indices: 0 Home, 1 Medicines, 2 Schedule, 3 Daily Tracking,
/// 4 Intake History, 5 Notifications, 6 Vacation Mode, 7 Profile.
void Function(int index)? shellNavigate;

/// Hamburger button that opens the side menu of the main shell.
class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Family members have no side menu.
    if (Session.isFamily) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.menu, size: 26, color: Color(0xFF3478B9)),
      tooltip: 'Menu',
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: () => shellScaffoldKey.currentState?.openDrawer(),
    );
  }
}

// ---------------- Routes ----------------
class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
}

// ---------------- In-memory session ----------------
enum UserRole { caregiver, family }

class Session {
  static UserRole role = UserRole.caregiver;
  static String name = 'Sarah Johnson';
  static String email = 'sarah@example.com';
  static String phone = '+1 555 123 4567';
  static String relation = 'Daughter';
  static String patientName = 'Robert Johnson';
  static String patientAge = '78';
  static String patientCondition = 'Type 2 Diabetes, Hypertension';
  static bool vacationMode = false;

  /// Family members only get the dashboard (read-only overview).
  static bool get isFamily => role == UserRole.family;

  static String get roleLabel =>
      role == UserRole.caregiver ? 'Caregiver' : 'Family Member';

  static void clear() {
    role = UserRole.caregiver;
    vacationMode = false;
  }
}



// ---------------- Validators ----------------
class Validators {
  static String? required(String? v, [String field = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone is required';
    if (v.replaceAll(RegExp(r'\D'), '').length < 7) {
      return 'Enter a valid phone';
    }
    return null;
  }
}

// ---------------- Role selector ----------------
class RoleSelector extends StatelessWidget {
  final UserRole value;
  final ValueChanged<UserRole> onChanged;
  const RoleSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedTabs(
      labels: const ['Caregiver', 'Family member'],
      selected: value == UserRole.caregiver ? 0 : 1,
      onChanged: (i) =>
          onChanged(i == 0 ? UserRole.caregiver : UserRole.family),
    );
  }
}
