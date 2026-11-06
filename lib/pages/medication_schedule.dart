import 'package:flutter/material.dart';

import '../data/dose_data.dart';
import '../models/dose_model.dart';
import '../theme/app_theme.dart';
import 'add_medicine.dart';
import 'auth_helpers.dart';

class MedicationSchedulePage extends StatefulWidget {
  const MedicationSchedulePage({super.key});

  @override
  State<MedicationSchedulePage> createState() =>
      _MedicationSchedulePageState();
}

class _MedicationSchedulePageState extends State<MedicationSchedulePage> {
  final List<String> periods = ['Morning', 'Afternoon', 'Evening'];

  // Days of the current week (Mon-Sun); defaults to today.
  late final List<DateTime> weekDays = _weekDays();
  late DateTime selectedDate = DoseData.today;

  List<DateTime> _weekDays() {
    final t = DoseData.today;
    return List.generate(
      7,
      (i) => DateTime(t.year, t.month, t.day - (t.weekday - 1) + i),
    );
  }

  bool get isToday => selectedDate == DoseData.today;

  void markTaken(DoseModel dose) {
    setState(() => dose.status = 'Taken');
  }

  Map<String, dynamic>? _medicineOf(DoseModel dose) {
    for (final m in DoseData.medicines) {
      if (m['id'] == dose.medicineId) return m;
    }
    return null;
  }

  String _frequency(Map<String, dynamic>? m) {
    final days = (m?['days'] as List?) ?? const [];
    if (days.length == 7) return 'Every day';
    if (days.isEmpty) return '';
    return days.join(', ');
  }

  // Times and days are part of the medicine, so editing a dose opens it.
  Future<void> _edit(DoseModel dose) async {
    final medicine = _medicineOf(dose);
    if (medicine == null) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => AddMedicinePage(medicine: medicine)),
    );
    if (!mounted) return;
    setState(() {
      if (result != null && result['__deleted'] != true) {
        DoseData.updateMedicine(medicine['id'] as int, result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayDoses = DoseData.dosesOn(selectedDate);
    final patient = Fmt.firstName(Session.patientName).toUpperCase();
    final count = dayDoses.length;

    return PageScaffold(
      overline: 'PILLCARE  /  $patient',
      title: 'Medication schedule',
      subtitle:
          '${Fmt.longDate(selectedDate)} · $count dose${count == 1 ? '' : 's'}'
          '${isToday ? ' today' : ''}',
      trailing: HeadingAction(
        icon: Icons.history,
        tooltip: 'Intake history',
        onPressed: () => shellNavigate?.call(4),
      ),
      children: [
        _weekStrip(),
        if (dayDoses.isEmpty)
          const AppCard(
            child: Text(
              'No medicines scheduled for this day.',
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ),
        for (final period in periods)
          ..._periodSection(
            period,
            dayDoses.where((d) => d.period == period).toList(),
          ),
      ],
    );
  }

  Widget _weekStrip() {
    return Row(
      children: [
        for (var i = 0; i < weekDays.length; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedDate = weekDays[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: weekDays[i] == selectedDate
                      ? AppColors.primary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      DoseData.dayNames[weekDays[i].weekday - 1][0],
                      style: TextStyle(
                        fontSize: 11,
                        color: weekDays[i] == selectedDate
                            ? Colors.white
                            : AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${weekDays[i].day}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: weekDays[i] == selectedDate
                            ? Colors.white
                            : AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _periodSection(String period, List<DoseModel> doses) {
    if (doses.isEmpty) return const [];
    return [
      SectionHeading(period),
      for (final dose in doses) _doseCard(dose),
    ];
  }

  Widget _doseCard(DoseModel dose) {
    final medicine = _medicineOf(dose);
    final canMark = dose.status == 'Pending' && isToday;

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
                      [
                        DoseData.formatTime(dose.dateTime),
                        dose.dosage,
                        if ((medicine?['foodPreference'] ?? '')
                            .toString()
                            .isNotEmpty)
                          medicine!['foodPreference'].toString(),
                      ].join(' · '),
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _edit(dose),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  _frequency(medicine),
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              if (canMark)
                GestureDetector(
                  onTap: () => markTaken(dose),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Mark as taken',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                StatusChip(
                  dose.status == 'Taken'
                      ? 'Taken · ${DoseData.formatTime(dose.dateTime)}'
                      : dose.status,
                  tone: toneForStatus(dose.status),
                  icon: iconForStatus(dose.status),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
