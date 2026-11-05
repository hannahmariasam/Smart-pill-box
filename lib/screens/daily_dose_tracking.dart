
import 'package:flutter/material.dart';
import '../data/dose_data.dart';
import '../models/dose_model.dart';

class DailyDoseTrackingPage extends StatefulWidget {
  const DailyDoseTrackingPage({super.key});

  @override
  State<DailyDoseTrackingPage> createState() =>
      _DailyDoseTrackingPageState();
}

class _DailyDoseTrackingPageState
    extends State<DailyDoseTrackingPage> {

  int get taken =>
      DoseData.doses.where((d) => d.status == 'Taken').length;

  int get missed =>
      DoseData.doses.where((d) => d.status == 'Missed').length;

  int get pending =>
      DoseData.doses.where((d) => d.status == 'Pending').length;

  String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void updateStatus(DoseModel dose, String status) {
    setState(() {
      dose.status = status;
    });
  }

  Widget summaryCard(
      String title, int count, Color color, IconData icon) {

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Dose Tracking'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "Today's Overview",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              summaryCard(
                'Taken', taken, Colors.green, Icons.check_circle,
              ),
              summaryCard(
                'Missed', missed, Colors.red, Icons.cancel,
              ),
              summaryCard(
                'Pending', pending, Colors.orange, Icons.schedule,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'Total Doses: ${DoseData.doses.length}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...DoseData.doses.map((dose) {

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
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      dose.medicine,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${dose.dosage} • ${formatTime(dose.dateTime)}',
                    ),

                    const SizedBox(height: 8),

                    Text(
                      dose.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      children: [

                        TextButton(
                          onPressed: () =>
                              updateStatus(dose, 'Taken'),
                          child: const Text('Taken'),
                        ),

                        TextButton(
                          onPressed: () =>
                              updateStatus(dose, 'Missed'),
                          child: const Text('Missed'),
                        ),

                        TextButton(
                          onPressed: () =>
                              updateStatus(dose, 'Pending'),
                          child: const Text('Pending'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
