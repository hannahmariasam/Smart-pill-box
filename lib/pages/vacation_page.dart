import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'auth_helpers.dart';

class VacationPage extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const VacationPage({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final patient = Fmt.firstName(Session.patientName).toUpperCase();

    return PageScaffold(
      overline: 'PILLCARE  /  $patient',
      title: 'Vacation mode',
      subtitle: 'Manage medicine reminders while travelling.',
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const IconTile(
                    icon: Icons.luggage_outlined,
                    size: 46,
                    radius: 14,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vacation mode',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          enabled ? 'Currently on' : 'Currently off',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: onChanged,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: AppColors.border,
                    trackOutlineColor:
                        WidgetStateProperty.all(Colors.transparent),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Turn this on when you are travelling or temporarily away '
                'from your regular routine.',
                style: TextStyle(
                    fontSize: 14, height: 1.4, color: AppColors.muted),
              ),
            ],
          ),
        ),
        NoticeBox(
          tone: enabled ? Tone.success : Tone.info,
          icon: enabled ? Icons.check_circle_outline : Icons.info_outline,
          white: !enabled,
          title: enabled
              ? 'Vacation mode is enabled'
              : 'Vacation mode is disabled',
          message: enabled
              ? 'Your reminders are adjusted while you are away.'
              : 'Reminders follow your regular schedule.',
        ),
        const Text(
          'Note: This is a UI prototype. Connect Firebase and ESP32 to '
          'control the actual pillbox and its reminders.',
          style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.muted),
        ),
      ],
    );
  }
}
