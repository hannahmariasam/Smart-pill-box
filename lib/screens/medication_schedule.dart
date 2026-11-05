
import 'package:flutter/material.dart';
import '../data/dose_data.dart';
import '../models/dose_model.dart';

class MedicationSchedulePage extends StatefulWidget {
  const MedicationSchedulePage({super.key});

  @override
  State<MedicationSchedulePage> createState() =>
      _MedicationSchedulePageState();
}

class _MedicationSchedulePageState
    extends State<MedicationSchedulePage> {

  final List<String> periods = [
    'Morning',
    'Afternoon',
    'Evening',
  ];

  String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void markTaken(DoseModel dose) {
    setState(() {
      dose.status = 'Taken';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Schedule'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "Today's Medication",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ...periods.map((period) {

            final medicines = DoseData.doses
                .where((dose) => dose.period == period)
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  period,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 10),

                if (medicines.isEmpty)
                  const Text('No medicines scheduled'),

                ...medicines.map((dose) {

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.medication,
                          color: Colors.white,
                        ),
                      ),

                      title: Text(
                        dose.medicine,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Text(
                        '${dose.dosage} • ${formatTime(dose.dateTime)}',
                      ),

                      trailing: dose.status == 'Taken'
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.blue,
                              ),
                              onPressed: () => markTaken(dose),
                            ),
                    ),
                  );
                }),

                const SizedBox(height: 15),
              ],
            );
          }),
        ],
      ),
    );
  }
}
