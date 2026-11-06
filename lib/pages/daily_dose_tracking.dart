import 'package:flutter/material.dart';

import '../data/dose_data.dart';
import '../models/dose_model.dart';
import '../theme/app_theme.dart';
import 'auth_helpers.dart';

class DailyDoseTrackingPage extends StatefulWidget {
  const DailyDoseTrackingPage({super.key});

  @override
  State<DailyDoseTrackingPage> createState() => _DailyDoseTrackingPageState();
}

class _DailyDoseTrackingPageState extends State<DailyDoseTrackingPage> {
  int get taken =>
      DoseData.todayDoses.where((d) => d.status == 'Taken').length;

  int get missed =>
      DoseData.todayDoses.where((d) => d.status == 'Missed').length;

  int get pending =>
      DoseData.todayDoses.where((d) => d.status == 'Pending').length;

  void updateStatus(DoseModel dose, String status) {
    setState(() => dose.status = status);
  }

  @override
  Widget build(BuildContext context) {
    final doses = DoseData.todayDoses;
    final patient = Fmt.firstName(Session.patientName).toUpperCase();

    return PageScaffold(
      overline: 'PILLCARE  /  $patient',
      title: 'Daily tracking',
      subtitle:
          "${Fmt.longDate(DateTime.now())} · ${doses.length} doses today",
      children: [
        CountRow(taken: taken, missed: missed, pending: pending),
        const SectionHeading("Today's doses"),
        if (doses.isEmpty)
          const AppCard(
            child: Text(
              'No doses scheduled for today.',
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ),
        for (final dose in doses) _doseCard(dose),
      ],
    );
  }

  Widget _doseCard(DoseModel dose) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dose.medicine,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${DoseData.formatTime(dose.dateTime)} · ${dose.dosage}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              StatusChip(
                dose.status,
                tone: toneForStatus(dose.status),
                icon: iconForStatus(dose.status),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final s in const ['Taken', 'Missed', 'Pending']) ...[
                if (s != 'Taken') const SizedBox(width: 8),
                Expanded(child: _statusButton(dose, s)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(DoseModel dose, String status) {
    final selected = dose.status == status;
    final tone = toneForStatus(status);
    return GestureDetector(
      onTap: () => updateStatus(dose, status),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? tone.fg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? tone.fg : AppColors.border),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
