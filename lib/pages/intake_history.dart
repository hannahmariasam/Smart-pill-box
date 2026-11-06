import 'package:flutter/material.dart';

import '../data/dose_data.dart';
import '../theme/app_theme.dart';
import 'auth_helpers.dart';

class IntakeHistoryPage extends StatefulWidget {
  const IntakeHistoryPage({super.key});

  @override
  State<IntakeHistoryPage> createState() => _IntakeHistoryPageState();
}

class _IntakeHistoryPageState extends State<IntakeHistoryPage> {
  static const _filters = ['All', 'Taken', 'Missed', 'Pending'];
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final history = [...DoseData.history]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    int count(String s) => history.where((d) => d.status == s).length;

    final visible = _filter == 0
        ? history
        : history.where((d) => d.status == _filters[_filter]).toList();
    final patient = Fmt.firstName(Session.patientName).toUpperCase();

    return PageScaffold(
      overline: 'PILLCARE  /  $patient',
      title: 'Intake history',
      subtitle: '${history.length} medication records',
      children: [
        CountRow(
          taken: count('Taken'),
          missed: count('Missed'),
          pending: count('Pending'),
        ),
        SegmentedTabs(
          labels: _filters,
          selected: _filter,
          onChanged: (i) => setState(() => _filter = i),
        ),
        const SectionHeading('Medication records'),
        if (visible.isEmpty)
          const AppCard(
            child: Text(
              'No records to show.',
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ),
        for (final dose in visible)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${dose.medicine} · ${dose.dosage}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      dose.status,
                      tone: toneForStatus(dose.status),
                      icon: iconForStatus(dose.status),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Fmt.longDate(dose.dateTime),
                  style:
                      const TextStyle(fontSize: 14, color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scheduled ${DoseData.formatTime(dose.dateTime)}',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
