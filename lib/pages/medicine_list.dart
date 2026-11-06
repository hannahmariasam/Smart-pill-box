import 'package:flutter/material.dart';

import '../data/dose_data.dart';
import '../theme/app_theme.dart';
import 'add_medicine.dart';
import 'auth_helpers.dart';
import 'device_status.dart';

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  int _filter = 0; // 0 = all, 1 = needs attention

  // Medicines are shared with the schedule, tracking and dashboard.
  List<Map<String, dynamic>> get medicines => DoseData.medicines;

  bool _isExpired(Map<String, dynamic> m) {
    final e = DoseData.expiryDate(m);
    return e != null && e.isBefore(DateTime.now());
  }

  bool _needsAttention(Map<String, dynamic> m) =>
      _isExpired(m) || DoseData.isLowStock(m) || DoseData.isExpiringSoon(m);

  Future<void> _edit(Map<String, dynamic> medicine) async {
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

  Future<void> _add() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicinePage()),
    );
    if (result != null && mounted) {
      setState(() => DoseData.addMedicine(result));
    }
  }

  Future<void> _delete(Map<String, dynamic> medicine) async {
    if (await confirmDelete(context, medicine['name'].toString())) {
      setState(() => DoseData.deleteMedicine(medicine['id'] as int));
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filter == 0
        ? medicines
        : medicines.where(_needsAttention).toList();
    final patient = Fmt.firstName(Session.patientName).toUpperCase();

    return PageScaffold(
      overline: 'PILLCARE  /  $patient',
      title: 'Medicine cabinet',
      subtitle:
          '${medicines.length} active medicines · ${medicines.length} compartments',
      trailing: HeadingAction(
        icon: Icons.devices_outlined,
        tooltip: 'Device status',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeviceStatusPage()),
        ),
      ),
      children: [
        AppButton('Add medicine', icon: Icons.add, onPressed: _add),
        SegmentedTabs(
          labels: const ['All medicines', 'Needs attention'],
          selected: _filter,
          onChanged: (i) => setState(() => _filter = i),
        ),
        if (list.isEmpty)
          const AppCard(
            child: Text(
              'No medicines need attention.',
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ),
        for (final m in list) _card(m, medicines.indexOf(m)),
        const Text(
          'Compartment numbers match your PillCare device.',
          style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _card(Map<String, dynamic> m, int index) {
    final name = m['name'].toString();
    final expiry = DoseData.expiryDate(m);

    // Expired medicines get the red card from the design.
    if (_isExpired(m)) {
      return AppCard(
        color: AppColors.dangerBg,
        onTap: () => _edit(m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline,
                size: 22, color: AppColors.danger),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name · ${m['dosage']}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expired ${m['expiry']} · ${m['stock']}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.danger),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: AppColors.danger),
              onPressed: () => _delete(m),
            ),
          ],
        ),
      );
    }

    late final StatusChip chip;
    if (DoseData.isLowStock(m)) {
      chip = const StatusChip('Low stock',
          tone: Tone.warn, icon: Icons.warning_amber_rounded);
    } else if (DoseData.isExpiringSoon(m) && expiry != null) {
      final left = expiry.difference(DateTime.now()).inDays;
      chip = StatusChip('Expires in $left days',
          tone: Tone.warn, icon: Icons.warning_amber_rounded);
    } else {
      chip = const StatusChip('In stock', icon: Icons.schedule);
    }

    final times = (m['times'] as List?)?.join(', ') ?? '';
    final days = (m['days'] as List?) ?? const [];

    return AppCard(
      onTap: () => _edit(m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(text: (index + 1).toString().padLeft(2, '0')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${m['dosage']} · ${m['stock']}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined,
                  size: 19, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            [
              if (times.isNotEmpty) times,
              if ((m['foodPreference'] ?? '').toString().isNotEmpty)
                m['foodPreference'].toString(),
              if (days.isNotEmpty && days.length < 7) days.join(', '),
              if (days.length == 7) 'Every day',
            ].join(' · '),
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Exp. ${m['expiry']}',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              chip,
            ],
          ),
        ],
      ),
    );
  }
}
