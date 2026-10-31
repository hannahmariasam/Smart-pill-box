
import 'package:flutter/material.dart';

class AddMedicinePage extends StatefulWidget {
  final Map<String, dynamic>? medicine;

  const AddMedicinePage({
    super.key,
    this.medicine,
  });

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  String foodPreference = 'Before food';

  List<String> selectedDays = [];
  List<TimeOfDay> selectedTimes = [];

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController dosageController =
      TextEditingController();

  final TextEditingController stockController =
      TextEditingController();

  final TextEditingController expiryController =
      TextEditingController();

  bool get isEditing => widget.medicine != null;

  @override
  void initState() {
    super.initState();

    // Fill the form with existing medicine details when editing.
    if (isEditing) {
      final medicine = widget.medicine!;

      nameController.text = medicine['name'] ?? '';
      dosageController.text = medicine['dosage'] ?? '';
      stockController.text = medicine['stock'] ?? '';
      expiryController.text = medicine['expiry'] ?? '';

      foodPreference =
          medicine['foodPreference'] ?? medicine['food'] ?? 'Before food';

      selectedDays = List<String>.from(medicine['days'] ?? []);

      // Convert saved reminder times into TimeOfDay objects.
      final savedTimes = medicine['times'];

      if (savedTimes is List) {
        for (final time in savedTimes) {
          final parsedTime = parseTime(time.toString());

          if (parsedTime != null) {
            selectedTimes.add(parsedTime);
          }
        }
      }
    }
  }

  TimeOfDay? parseTime(String value) {
    try {
      final parts = value.split(' ');
      final timeParts = parts[0].split(':');

      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);

      if (parts.length > 1) {
        final period = parts[1].toUpperCase();

        if (period == 'PM' && hour != 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    stockController.dispose();
    expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage (e.g. 500mg)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: stockController,
              decoration: const InputDecoration(
                labelText: 'Stock Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 15),

            TextField(
              controller: expiryController,
              decoration: const InputDecoration(
                labelText: 'Expiry Date (MM/YYYY)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: foodPreference,
              decoration: const InputDecoration(
                labelText: 'Food Preference',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Before food',
                  child: Text('Before food'),
                ),
                DropdownMenuItem(
                  value: 'After food',
                  child: Text('After food'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    foodPreference = value;
                  });
                }
              },
            ),

            const SizedBox(height: 15),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Days to Take Medicine',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: [
                for (String day in [
                  'Mon', 'Tue', 'Wed', 'Thu',
                  'Fri', 'Sat', 'Sun'
                ])
                  FilterChip(
                    label: Text(day),
                    selected: selectedDays.contains(day),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                        }
                      });
                    },
                  ),
              ],
            ),

            const SizedBox(height: 15),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reminder Times',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  children: selectedTimes.map((time) {
                    return Chip(
                      label: Text(time.format(context)),
                      onDeleted: () {
                        setState(() {
                          selectedTimes.remove(time);
                        });
                      },
                    );
                  }).toList(),
                ),

                TextButton.icon(
                  onPressed: () async {
                    final TimeOfDay? picked =
                        await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (picked != null) {
                      setState(() {
                        if (!selectedTimes.contains(picked)) {
                          selectedTimes.add(picked);

                          selectedTimes.sort((a, b) {
                            final aMinutes =
                                a.hour * 60 + a.minute;

                            final bMinutes =
                                b.hour * 60 + b.minute;

                            return aMinutes.compareTo(bMinutes);
                          });
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Reminder Time'),
                ),
              ],
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    dosageController.text.trim().isEmpty ||
                    stockController.text.trim().isEmpty ||
                    expiryController.text.trim().isEmpty ||
                    selectedDays.isEmpty ||
                    selectedTimes.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                    ),
                  );
                  return;
                }

                final medicine = {
                  'name': nameController.text.trim(),
                  'dosage': dosageController.text.trim(),
                  'stock': stockController.text.trim(),
                  'expiry': expiryController.text.trim(),
                  'foodPreference': foodPreference,
                  'days': selectedDays,
                  'times': selectedTimes
                      .map((time) => time.format(context))
                      .toList(),
                };

                Navigator.pop(context, medicine);
              },

              child: Text(
                isEditing ? 'Update Medicine' : 'Save Medicine',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
