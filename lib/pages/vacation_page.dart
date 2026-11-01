
import 'package:flutter/material.dart';

const navy = Color(0xFF12345A);
const green = Color(0xFF299B70);

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
    return ListView(
      padding: const EdgeInsets.all(25),
      children: [
        const Text(
          'Vacation Mode',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Manage your medicine reminders while travelling.',
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 25),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.beach_access,
                color: navy,
                size: 35,
              ),

              const SizedBox(height: 18),

              const Text(
                'Vacation Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Enable vacation mode when you are travelling '
                'or temporarily away from your regular routine.',
                style: TextStyle(
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const Divider(height: 30),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Enable Vacation Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  enabled ? 'Currently ON' : 'Currently OFF',
                ),
                value: enabled,
                activeThumbColor: green,
                onChanged: onChanged,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: enabled
                ? green.withOpacity(0.08)
                : navy.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                enabled ? Icons.check_circle : Icons.info_outline,
                color: enabled ? green : navy,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  enabled
                      ? 'Vacation mode is enabled.'
                      : 'Vacation mode is currently disabled.',
                  style: TextStyle(
                    color: enabled ? green : navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Note: This is a UI prototype. Connect Firebase '
          'and ESP32 to control the actual pillbox and its reminders.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
