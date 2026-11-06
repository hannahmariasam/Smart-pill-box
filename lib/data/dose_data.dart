import '../models/dose_model.dart';

/// Single in-memory source of truth shared by every page.
///
/// * [medicines] is the list managed on the Medicines page.
/// * [doses] is the schedule generated from those medicines
///   (one dose for every selected day + reminder time).
///
/// Call [addMedicine], [updateMedicine] or [deleteMedicine] to change
/// medicines, so the schedule, tracking, history and dashboard stay in sync.
class DoseData {
  static const int lowStockLimit = 10;
  static const int expiryWarningDays = 15;

  static const List<String> dayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  static int _nextMedicineId = 4;
  static int _nextDoseId = 1;

  // Initial sample medicines (same shape the Add Medicine page returns).
  static final List<Map<String, dynamic>> medicines = [
    {
      'id': 1,
      'name': 'Metformin',
      'dosage': '1 tablet · 500 mg',
      'times': ['8:00 AM'],
      'days': [...dayNames],
      'foodPreference': 'After food',
      'stock': '20 tablets',
      'expiry': '12/2027',
    },
    {
      'id': 2,
      'name': 'Amlodipine',
      'dosage': '1 tablet · 5 mg',
      'times': ['8:00 PM'],
      'days': [...dayNames],
      'foodPreference': 'Before food',
      'stock': '15 tablets',
      'expiry': '06/2027',
    },
    {
      'id': 3,
      'name': 'Vitamin D3',
      'dosage': '1 capsule · 1000 IU',
      'times': ['1:00 PM'],
      'days': [...dayNames],
      'foodPreference': 'After food',
      'stock': '10 capsules',
      'expiry': '03/2028',
    },
  ];

  // Generated schedule for the current week (today onwards) + history.
  static final List<DoseModel> doses = _seed();

  static List<DoseModel> _seed() {
    final list = <DoseModel>[];
    _generate(list);
    _seedPastSample(list);

    // Sample: this morning's Metformin has already been taken.
    for (final d in list) {
      if (d.medicineId == 1 && _sameDay(d.dateTime, DateTime.now())) {
        d.status = 'Taken';
      }
    }
    return list;
  }

  /// SAMPLE DATA: fills the days before today (back to the previous Monday
  /// week) with recorded doses so the weekly compliance chart and the intake
  /// history have something to show. Most doses are Taken, a few Missed.
  /// Delete the call to this method in [_seed] to remove the sample.
  static void _seedPastSample(List<DoseModel> list) {
    final todayDate = today;
    final monday = DateTime(
      todayDate.year,
      todayDate.month,
      todayDate.day - (todayDate.weekday - 1),
    );
    final start = DateTime(monday.year, monday.month, monday.day - 7);

    var n = 0;
    for (var date = start;
        date.isBefore(todayDate);
        date = DateTime(date.year, date.month, date.day + 1)) {
      for (final med in medicines) {
        final days = List<String>.from(med['days'] ?? []);
        if (!days.contains(dayNames[date.weekday - 1])) continue;

        for (final t in (med['times'] as List?) ?? []) {
          final parsed = parseTime(t.toString());
          if (parsed == null) continue;

          final dateTime =
              DateTime(date.year, date.month, date.day, parsed.$1, parsed.$2);
          n++;

          list.add(DoseModel(
            id: _nextDoseId++,
            medicineId: med['id'] as int,
            medicine: med['name'] as String,
            dosage: (med['dosage'] ?? '').toString(),
            dateTime: dateTime,
            period: periodOf(dateTime.hour),
            // Roughly 1 in 6 doses is missed so the chart varies by day.
            status: n % 6 == 0 ? 'Missed' : 'Taken',
          ));
        }
      }
    }
  }

  // ---------------- Schedule generation ----------------

  /// Creates any missing doses for today and the rest of this week.
  /// Existing doses (and their status) are never touched.
  static void sync() => _generate(doses);

  static void _generate(List<DoseModel> target) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final monday = DateTime(
      todayDate.year,
      todayDate.month,
      todayDate.day - (todayDate.weekday - 1),
    );

    final existing = target.map(_key).toSet();

    for (final med in medicines) {
      final days = List<String>.from(med['days'] ?? []);
      final times = (med['times'] as List?) ?? [];

      for (var i = 0; i < 7; i++) {
        final date = DateTime(monday.year, monday.month, monday.day + i);
        if (date.isBefore(todayDate)) continue;
        if (!days.contains(dayNames[date.weekday - 1])) continue;

        for (final t in times) {
          final parsed = parseTime(t.toString());
          if (parsed == null) continue;

          final dateTime = DateTime(
            date.year, date.month, date.day, parsed.$1, parsed.$2,
          );

          final dose = DoseModel(
            id: _nextDoseId,
            medicineId: med['id'] as int,
            medicine: med['name'] as String,
            dosage: (med['dosage'] ?? '').toString(),
            dateTime: dateTime,
            period: periodOf(dateTime.hour),
          );

          if (existing.add(_key(dose))) {
            _nextDoseId++;
            target.add(dose);
          }
        }
      }
    }

    target.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  static String _key(DoseModel d) =>
      '${d.medicineId}|${d.dateTime.millisecondsSinceEpoch}';

  // ---------------- Medicine changes ----------------

  static void addMedicine(Map<String, dynamic> medicine) {
    final med = Map<String, dynamic>.from(medicine);
    med['id'] = _nextMedicineId++;
    _sortDays(med);
    medicines.add(med);
    sync();
  }

  static void updateMedicine(int id, Map<String, dynamic> medicine) {
    final index = medicines.indexWhere((m) => m['id'] == id);
    if (index == -1) return;

    final med = Map<String, dynamic>.from(medicine);
    med['id'] = id;
    _sortDays(med);
    medicines[index] = med;

    // Rebuild the not-yet-recorded doses; Taken / Missed stay in history.
    doses.removeWhere((d) => d.medicineId == id && d.status == 'Pending');
    sync();
  }

  static void deleteMedicine(int id) {
    medicines.removeWhere((m) => m['id'] == id);
    doses.removeWhere((d) => d.medicineId == id && d.status == 'Pending');
  }

  static void _sortDays(Map<String, dynamic> med) {
    final days = List<String>.from(med['days'] ?? []);
    days.sort((a, b) => dayNames.indexOf(a).compareTo(dayNames.indexOf(b)));
    med['days'] = days;
  }

  // ---------------- Queries ----------------

  static DateTime get today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static List<DoseModel> dosesOn(DateTime date) =>
      doses.where((d) => _sameDay(d.dateTime, date)).toList();

  static List<DoseModel> get todayDoses => dosesOn(DateTime.now());

  /// Doses whose time has come, or which have already been recorded.
  static List<DoseModel> get history {
    final now = DateTime.now();
    return doses
        .where((d) => d.status != 'Pending' || !d.dateTime.isAfter(now))
        .toList();
  }

  static int stockOf(Map<String, dynamic> med) {
    final m = RegExp(r'\d+').firstMatch((med['stock'] ?? '').toString());
    return m == null ? 0 : int.parse(m.group(0)!);
  }

  static bool isLowStock(Map<String, dynamic> med) =>
      stockOf(med) <= lowStockLimit;

  static List<Map<String, dynamic>> get lowStockMedicines =>
      medicines.where(isLowStock).toList();

  /// Expiry is stored as MM/YYYY; the medicine is valid until month end.
  static DateTime? expiryDate(Map<String, dynamic> med) {
    final m = RegExp(r'^\s*(\d{1,2})\s*/\s*(\d{4})\s*$')
        .firstMatch((med['expiry'] ?? '').toString());
    if (m == null) return null;
    final month = int.parse(m.group(1)!);
    final year = int.parse(m.group(2)!);
    if (month < 1 || month > 12) return null;
    return DateTime(year, month + 1, 0);
  }

  static bool isExpiringSoon(Map<String, dynamic> med) {
    final e = expiryDate(med);
    if (e == null) return false;
    return e.difference(DateTime.now()).inDays <= expiryWarningDays;
  }

  static List<Map<String, dynamic>> get expiringMedicines =>
      medicines.where(isExpiringSoon).toList();

  // ---------------- Helpers ----------------

  static String periodOf(int hour) {
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  static String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Parses "8:00 AM", "08:00" or "8:00 pm" into (hour, minute).
  static (int, int)? parseTime(String value) {
    final m = RegExp(r'(\d{1,2}):(\d{2})\s*([AaPp][Mm])?').firstMatch(value);
    if (m == null) return null;

    var hour = int.parse(m.group(1)!);
    final minute = int.parse(m.group(2)!);
    final period = m.group(3)?.toUpperCase();

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    if (hour > 23 || minute > 59) return null;

    return (hour, minute);
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
