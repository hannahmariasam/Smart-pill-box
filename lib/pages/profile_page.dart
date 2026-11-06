import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'auth_helpers.dart';
import 'device_status.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = Fmt.firstName(Session.patientName).toUpperCase();

    return PageScaffold(
      overline: 'PILLCARE  /  $patient',
      title: 'Profile',
      subtitle: 'Your account and care details.',
      children: [
        AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      Fmt.initials(Session.name),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Session.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          Session.roleLabel,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DetailRow('Email', Session.email),
              const SizedBox(height: 12),
              DetailRow('Phone', Session.phone),
              if (Session.role == UserRole.family) ...[
                const SizedBox(height: 12),
                DetailRow('Relationship', Session.relation),
              ],
            ],
          ),
        ),
        const SectionHeading('Patient'),
        AppCard(
          child: Column(
            children: [
              DetailRow('Name', Session.patientName),
              const SizedBox(height: 12),
              DetailRow('Age', Session.patientAge),
              if (Session.patientCondition.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                DetailRow('Condition', Session.patientCondition),
              ],
            ],
          ),
        ),
        const SectionHeading('Settings'),
        AppCard(
          child: Column(
            children: [
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceStatusPage()),
                ),
                child: const DetailRow('Device', 'Connected  ›',
                    icon: Icons.wifi),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () => shellNavigate?.call(6),
                child: DetailRow(
                  'Vacation mode',
                  '${Session.vacationMode ? 'On' : 'Off'}  ›',
                  icon: Icons.luggage_outlined,
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () => shellNavigate?.call(5),
                child: const DetailRow('Notifications', 'View  ›',
                    icon: Icons.notifications_none),
              ),
            ],
          ),
        ),
        AppButton(
          'Log out',
          icon: Icons.logout,
          style: AppButtonStyle.danger,
          onPressed: () {
            Session.clear();
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (_) => false);
          },
        ),
      ],
    );
  }
}
