import 'package:flutter/material.dart';

import '../data/dose_data.dart';
import '../theme/app_theme.dart';
import 'auth_helpers.dart';

class _Alert {
  final String id;
  final String title;
  final String message;
  final String time;
  final String action;
  final int target; // shell tab opened by the action
  final Tone tone;
  final IconData icon;
  final bool needsAttention;

  const _Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.action,
    required this.target,
    required this.tone,
    required this.icon,
    required this.needsAttention,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  // Kept for the lifetime of the app so "read" survives tab switches.
  static final Set<String> _read = {};

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _filter = 0; // 0 = all updates, 1 = unread

  List<_Alert> _alerts() {
    final alerts = <_Alert>[];

    for (final d in DoseData.todayDoses.where((d) => d.status == 'Missed')) {
      alerts.add(_Alert(
        id: 'missed-${d.id}',
        title: 'Missed dose',
        message:
            '${d.medicine} ${d.dosage} at ${DoseData.formatTime(d.dateTime)} was not recorded.',
        time: 'Today, ${DoseData.formatTime(d.dateTime)}',
        action: 'View history',
        target: 4,
        tone: Tone.danger,
        icon: Icons.error_outline,
        needsAttention: true,
      ));
    }

    for (final m in DoseData.lowStockMedicines) {
      alerts.add(_Alert(
        id: 'low-${m['id']}',
        title: 'Low stock',
        message: '${m['name']} has ${m['stock']} left. Plan a refill soon.',
        time: 'Refill needed',
        action: 'View medicine',
        target: 1,
        tone: Tone.warn,
        icon: Icons.warning_amber_rounded,
        needsAttention: true,
      ));
    }

    for (final m in DoseData.expiringMedicines) {
      alerts.add(_Alert(
        id: 'exp-${m['id']}',
        title: 'Expiry coming up',
        message: '${m['name']} expires on ${m['expiry']}.',
        time: 'Check expiry date',
        action: 'View medicine',
        target: 1,
        tone: Tone.warn,
        icon: Icons.event_busy_outlined,
        needsAttention: true,
      ));
    }

    for (final d in DoseData.todayDoses.where((d) => d.status == 'Taken')) {
      alerts.add(_Alert(
        id: 'taken-${d.id}',
        title: '${d.medicine} dose taken',
        message:
            '${d.medicine} ${d.dosage} was taken at ${DoseData.formatTime(d.dateTime)}.',
        time: 'Today, ${DoseData.formatTime(d.dateTime)}',
        action: 'View history',
        target: 4,
        tone: Tone.success,
        icon: Icons.check_circle_outline,
        needsAttention: false,
      ));
    }

    return alerts;
  }

  bool _isUnread(_Alert a) =>
      a.needsAttention && !NotificationsPage._read.contains(a.id);

  @override
  Widget build(BuildContext context) {
    final all = _alerts();
    final unread = all.where(_isUnread).toList();
    final shown = _filter == 0 ? all : unread;
    final attention = shown.where((a) => a.needsAttention).toList();
    final earlier = shown.where((a) => !a.needsAttention).toList();
    final patient = Fmt.firstName(Session.patientName).toUpperCase();

    return PageScaffold(
      overline: 'PILLCARE  /  $patient',
      title: 'Notifications',
      subtitle: '${unread.length} unread update${unread.length == 1 ? '' : 's'}',
      children: [
        SegmentedTabs(
          labels: ['All updates', 'Unread (${unread.length})'],
          selected: _filter,
          onChanged: (i) => setState(() => _filter = i),
        ),
        if (shown.isEmpty)
          const AppCard(
            child: Text(
              "You're all caught up.",
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ),
        if (attention.isNotEmpty)
          SectionHeading(
            'Needs attention',
            action: unread.isEmpty ? null : 'Mark all as read',
            onAction: () => setState(() {
              NotificationsPage._read.addAll(attention.map((a) => a.id));
            }),
          ),
        for (final a in attention) _card(a),
        if (earlier.isNotEmpty) const SectionHeading('Earlier'),
        for (final a in earlier) _card(a),
      ],
    );
  }

  Widget _card(_Alert a) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: a.icon, tone: a.tone, size: 34, radius: 10),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  a.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (_isUnread(a))
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            a.message,
            style: const TextStyle(
                fontSize: 14, height: 1.4, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  a.time,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => NotificationsPage._read.add(a.id));
                  shellNavigate?.call(a.target);
                },
                child: Text(
                  '${a.action} →',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
