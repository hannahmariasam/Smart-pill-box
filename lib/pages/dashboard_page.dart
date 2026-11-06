import 'package:flutter/material.dart';

import '../data/dose_data.dart';
import '../theme/app_theme.dart';
import 'auth_helpers.dart';
import 'device_status.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todayDoses = DoseData.todayDoses;
    final taken = todayDoses.where((d) => d.status == 'Taken').length;
    final now = DateTime.now();
    final pendingDoses =
        todayDoses.where((d) => d.status == 'Pending').toList();
    final upcoming = pendingDoses.where((d) => !d.dateTime.isBefore(now));
    final next = upcoming.isNotEmpty
        ? upcoming.first
        : (pendingDoses.isNotEmpty ? pendingDoses.first : null);

    final patient = Fmt.firstName(Session.patientName).toUpperCase();

    return PageScaffold(
      overline: 'PILLCARE  /  $patient',
      title: 'Welcome back, ${Fmt.firstName(Session.name)}!',
      subtitle: 'Here is your medicine overview for today.',
      trailing: Session.isFamily
          ? HeadingAction(
              icon: Icons.logout,
              tooltip: 'Log out',
              onPressed: () {
                Session.clear();
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (_) => false);
              },
            )
          : HeadingAction(
              icon: Icons.notifications_none,
              tooltip: 'Notifications',
              onPressed: () => shellNavigate?.call(5),
            ),
      children: [
        if (Session.vacationMode)
          NoticeBox(
            tone: Tone.warn,
            icon: Icons.luggage_outlined,
            title: 'Vacation mode is ON',
            message: 'Reminders are adjusted while you are away.',
            onTap: Session.isFamily ? null : () => shellNavigate?.call(6),
          ),

        // Summary cards (2 x 2)
        Column(
          children: [
            IntrinsicHeight(
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Doses Taken',
                    value: '$taken / ${todayDoses.length}',
                    subtitle: 'Today',
                    icon: Icons.medication_outlined,
                    tone: Tone.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Next Dose',
                    value: next == null
                        ? '--'
                        : DoseData.formatTime(next.dateTime),
                    subtitle: next == null ? 'All done' : next.medicine,
                    icon: Icons.access_time,
                    tone: Tone.info,
                  ),
                ),
              ],
            ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Low Stock',
                    value: '${DoseData.lowStockMedicines.length} medicines',
                    subtitle: 'Needs refill',
                    icon: Icons.inventory_2_outlined,
                    tone: Tone.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Expiring Soon',
                    value: '${DoseData.expiringMedicines.length} medicines',
                    subtitle: 'Within ${DoseData.expiryWarningDays} days',
                    icon: Icons.calendar_month_outlined,
                    tone: Tone.warn,
                  ),
                ),
              ],
            ),
            ),
          ],
        ),

        const ComplianceSection(),
        const DeviceSection(),
        const InventorySection(),
        const ActivitySection(),
      ],
    );
  }
}

// ---------------- Summary card ----------------
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Tone tone;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: tone.fg, size: 20),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: tone.fg,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

// ---------------- Reusable white section ----------------
class WhiteSection extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onTap;

  const WhiteSection({
    super.key,
    required this.title,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ---------------- Weekly compliance ----------------
class ComplianceSection extends StatelessWidget {
  const ComplianceSection({super.key});

  // Percentage of doses taken for each day of the current week.
  List<List<Object>> weekCompliance() {
    final t = DoseData.today;

    return List.generate(7, (i) {
      final date = DateTime(t.year, t.month, t.day - (t.weekday - 1) + i);
      final doses = DoseData.dosesOn(date);
      final taken = doses.where((d) => d.status == 'Taken').length;
      final percent = doses.isEmpty ? 0 : (taken * 100 / doses.length).round();
      return [DoseData.dayNames[i], percent];
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = weekCompliance();

    return WhiteSection(
      title: 'Weekly Compliance',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) {
          final percent = day[1] as int;
          return Column(
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 4,
                  backgroundColor: AppColors.bg,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percent >= 85 ? AppColors.success : AppColors.warn,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Text(
                day[0] as String,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ---------------- Device status ----------------
class DeviceSection extends StatelessWidget {
  const DeviceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return WhiteSection(
      title: 'Pillbox Device Status',
      onTap: Session.isFamily
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeviceStatusPage()),
              ),
      child: const Column(
        children: [
          DeviceRow('Connection', 'Online', AppColors.success),
          DeviceRow('Battery', '92%', AppColors.success),
          DeviceRow('Wi-Fi', 'Connected', AppColors.success),
          DeviceRow('Last Sync', '08:25 AM', AppColors.ink),
        ],
      ),
    );
  }
}

class DeviceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const DeviceRow(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: AppColors.muted)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Medicine inventory ----------------
class InventorySection extends StatelessWidget {
  const InventorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (final med in DoseData.medicines) {
      rows.add(const Divider(color: AppColors.border, height: 1));
      rows.add(
        InventoryRow(
          med['name'].toString(),
          med['stock'].toString(),
          DoseData.isLowStock(med) ? 'Low' : 'Good',
        ),
      );
    }

    return WhiteSection(
      title: 'Medicine Inventory Summary',
      child: Column(
        children: [
          const InventoryRow('Medicine', 'Stock', 'Status', header: true),
          ...rows,
        ],
      ),
    );
  }
}

class InventoryRow extends StatelessWidget {
  final String medicine;
  final String stock;
  final String status;
  final bool header;

  const InventoryRow(
    this.medicine,
    this.stock,
    this.status, {
    super.key,
    this.header = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = status == 'Low' ? AppColors.danger : AppColors.success;
    final base = header ? AppColors.muted : AppColors.ink;
    final weight = header ? FontWeight.w600 : FontWeight.w400;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(medicine,
                style: TextStyle(
                    fontSize: 13, color: base, fontWeight: weight)),
          ),
          Expanded(
            flex: 2,
            child: Text(stock,
                style: TextStyle(
                    fontSize: 13, color: base, fontWeight: weight)),
          ),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                fontSize: 13,
                color: header ? AppColors.muted : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Recent activity ----------------
class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final recorded = DoseData.todayDoses
        .where((d) => d.status != 'Pending')
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final rows = <Widget>[
      for (final d in recorded)
        ActivityRow(
          '${d.medicine} dose ${d.status == 'Taken' ? 'taken' : 'missed'}',
          'Today · ${DoseData.formatTime(d.dateTime)}',
          d.status == 'Taken' ? AppColors.success : AppColors.danger,
        ),
      for (final m in DoseData.lowStockMedicines)
        ActivityRow(
          'Low stock: ${m['name']}',
          'Stock: ${m['stock']}',
          AppColors.warn,
        ),
    ];

    return WhiteSection(
      title: 'Recent Activity',
      child: Column(
        children: rows.isEmpty
            ? const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('No activity yet today',
                      style:
                          TextStyle(fontSize: 14, color: AppColors.muted)),
                ),
              ]
            : rows,
      ),
    );
  }
}

class ActivityRow extends StatelessWidget {
  final String title;
  final String time;
  final Color color;

  const ActivityRow(this.title, this.time, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 9, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
