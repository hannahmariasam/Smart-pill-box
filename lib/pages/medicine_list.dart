
import 'package:flutter/material.dart';
import 'add_medicine.dart';
import 'device_status.dart';
class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {


  // Temporary sample medicine records
  final List<Map<String, dynamic>> medicines = [
    {
      'name': 'Metformin',
      'dosage': '1 tablet · 500 mg',
      'time': 'Morning',
      'food': 'After food',
      'stock': '20 tablets',
      'expiry': '12/2027',
    },
    {
      'name': 'Amlodipine',
      'dosage': '1 tablet · 5 mg',
      'time': 'Evening',
      'food': 'Before food',
      'stock': '15 tablets',
      'expiry': '06/2027',
    },
    {
      'name': 'Vitamin D3',
      'dosage': '1 capsule · 1000 IU',
      'time': 'Afternoon',
      'food': 'After food',
      'stock': '10 capsules',
      'expiry': '03/2028',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: const Text('My Medicines'),
  actions: [
    IconButton(
      icon: const Icon(Icons.devices),
      tooltip: 'Device Status',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DeviceStatusPage(),
          ),
        );
      },
    ),
  ],
),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          final medicine = medicines[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          medicine['name']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.medication,
                        color: Colors.teal,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(medicine['dosage']!),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 8),
                     Text(
                    '${(medicine['times'] as List?)?.join(', ') ?? medicine['time'] ?? 'No time selected'} · ${medicine['foodPreference'] ?? medicine['food'] ?? ''}',
                    ),
                    ],
                  ),

                 const SizedBox(height: 10),

// Display selected days
if (medicine['days'] != null &&
    (medicine['days'] as List).isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      'Days: ${(medicine['days'] as List).join(', ')}',
      style: const TextStyle(
        fontSize: 14,
        color: Colors.teal,
      ),
    ),
  ),

const Divider(),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Stock: ${medicine['stock']}'),
                      Text('Expiry: ${medicine['expiry']}'),
                    ],
                  ),

                  const SizedBox(height: 8),

Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    // Edit button
    TextButton.icon(
      onPressed: () async {
        final updatedMedicine =
            await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => AddMedicinePage(
              medicine: medicine,
            ),
          ),
        );

        if (updatedMedicine != null) {
          setState(() {
            medicines[index] = updatedMedicine;
          });
        }
      },
      icon: const Icon(Icons.edit),
      label: const Text('Edit'),
    ),

    // Delete button
    TextButton.icon(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Medicine?'),
            content: Text(
              'Are you sure you want to delete ${medicine['name']}?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          setState(() {
            medicines.removeAt(index);
          });
        }
      },
      icon: const Icon(Icons.delete, color: Colors.red),
      label: const Text(
        'Delete',
        style: TextStyle(color: Colors.red),
      ),
    ),
  ],
),
             ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newMedicine =
              await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicinePage(),
            ),
          );

          if (newMedicine != null) {
            setState(() {
              medicines.add(newMedicine);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}