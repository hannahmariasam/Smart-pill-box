
import 'package:flutter/material.dart';
import '../data/dose_data.dart';

class IntakeHistoryPage extends StatelessWidget {
  const IntakeHistoryPage({super.key});

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {

    final history = [...DoseData.doses]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intake History'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            'Medication Records',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...history.map((dose) {

            Color statusColor;

            if (dose.status == 'Taken') {
              statusColor = Colors.green;
            } else if (dose.status == 'Missed') {
              statusColor = Colors.red;
            } else {
              statusColor = Colors.orange;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(

                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.15),
                  child: Icon(
                    Icons.medication,
                    color: statusColor,
                  ),
                ),

                title: Text(
                  dose.medicine,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${dose.dosage}\n'
                    '${formatDate(dose.dateTime)}\n'
                    '${formatTime(dose.dateTime)}',
                  ),
                ),

                isThreeLine: true,

                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dose.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
