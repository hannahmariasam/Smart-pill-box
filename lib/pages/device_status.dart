import 'package:flutter/material.dart';

import '../data/dose_data.dart';
import '../theme/app_theme.dart';
import 'auth_helpers.dart';

class DeviceStatusPage extends StatelessWidget {
  const DeviceStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = Fmt.firstName(Session.patientName).toUpperCase();
    final meds = DoseData.medicines;

    return PageScaffold(
      showBack: true,
      overline: 'PILLCARE  /  $patient',
      title: 'Device status',
      subtitle: 'Your connected pillbox at a glance.',
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const IconTile(
                    icon: Icons.sensors,
                    size: 56,
                    radius: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Smart Pillbox',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'PillCare device',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const StatusChip('Connected',
                  tone: Tone.success, icon: Icons.check_circle_outline),
              const SizedBox(height: 12),
              const DetailRow('Last synchronisation', 'Today, 10:30 AM'),
            ],
          ),
        ),
        const SectionHeading('Connection'),
        const AppCard(
          child: Column(
            children: [
              DetailRow('Connection status', 'Connected', icon: Icons.wifi),
              SizedBox(height: 14),
              DetailRow('Battery level', '85%',
                  icon: Icons.battery_full),
              SizedBox(height: 14),
              DetailRow('Device name', 'Smart Pillbox',
                  icon: Icons.devices_outlined),
            ],
          ),
        ),
        const SectionHeading('Compartments'),
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < meds.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      (i + 1).toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        meds[i]['name'].toString(),
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.ink),
                      ),
                    ),
                    Text(
                      meds[i]['stock'].toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DoseData.isLowStock(meds[i])
                            ? AppColors.warn
                            : AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
              if (meds.isEmpty)
                const Text('No medicines loaded.',
                    style: TextStyle(fontSize: 14, color: AppColors.muted)),
            ],
          ),
        ),
        AppButton(
          'Refresh status',
          icon: Icons.refresh,
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device is up to date')),
          ),
        ),
      ],
    );
  }
}
