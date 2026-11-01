
import 'package:flutter/material.dart';

const navy = Color(0xFF12345A);
const red = Color(0xFFD65B5B);
const orange = Color(0xFFD99A42);

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(25),
      children: [
        const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Stay updated about your medicines and device.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 25),

        const NotificationCard(
          title: 'Low stock warning',
          message: 'Atorvastatin 10mg is below the minimum stock level.',
          time: 'Today · 09:30 AM',
          status: 'LOW STOCK',
          icon: Icons.warning_amber_rounded,
          color: red,
        ),

        const NotificationCard(
          title: 'Medicine expiry alert',
          message: 'Amoxicillin 500mg will expire in 15 days.',
          time: 'Today · 08:40 AM',
          status: 'EXPIRY',
          icon: Icons.calendar_month,
          color: orange,
        ),

        const NotificationCard(
          title: 'Missed dose',
          message: 'Afternoon dose was not detected by the pillbox.',
          time: 'Today · 02:15 PM',
          status: 'MISSED DOSE',
          icon: Icons.medication_outlined,
          color: red,
        ),

        const NotificationCard(
          title: 'Device offline',
          message: 'Pillbox was disconnected for 5 minutes.',
          time: 'Today · 08:10 AM',
          status: 'DEVICE',
          icon: Icons.wifi_off,
          color: orange,
        ),
      ],
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final String status;
  final IconData icon;
  final Color color;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.status,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
