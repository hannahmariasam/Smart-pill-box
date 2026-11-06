
import 'package:flutter/material.dart';

import '../data/dose_data.dart';
import '../theme/app_theme.dart';

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
    final parsed = DoseData.parseTime(value);
    if (parsed == null) return null;
    return TimeOfDay(hour: parsed.$1, minute: parsed.$2);
  }

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    stockController.dispose();
    expiryController.dispose();
    super.dispose();
  }

  void _save() {
    if (nameController.text.trim().isEmpty ||
        dosageController.text.trim().isEmpty ||
        stockController.text.trim().isEmpty ||
        expiryController.text.trim().isEmpty ||
        selectedDays.isEmpty ||
        selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
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
      'times': selectedTimes.map((time) => time.format(context)).toList(),
    };

    Navigator.pop(context, medicine);
  }

  Future<void> _delete() async {
    final name = nameController.text.trim().isEmpty
        ? 'this medicine'
        : nameController.text.trim();
    if (await confirmDelete(context, name)) {
      DoseData.deleteMedicine(widget.medicine!['id'] as int);
      if (mounted) Navigator.pop(context, {'__deleted': true});
    }
  }

  Future<void> _addTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (!selectedTimes.contains(picked)) {
          selectedTimes.add(picked);
          selectedTimes.sort((a, b) =>
              (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      showBack: true,
      overline: 'PILLCARE  /  MEDICINES',
      title: isEditing ? 'Edit medicine' : 'Add medicine',
      subtitle: isEditing
          ? 'Update the details for this medicine.'
          : 'Add a medicine and set when it should be taken.',
      children: [
        LabeledField(
          label: 'Medicine name',
          controller: nameController,
          hint: 'e.g. Metformin',
        ),
        LabeledField(
          label: 'Dosage',
          controller: dosageController,
          hint: 'e.g. 1 tablet · 500 mg',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabeledField(
                label: 'Stock quantity',
                controller: stockController,
                hint: 'e.g. 20',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('Food'),
                  DropdownButtonFormField<String>(
                    initialValue: foodPreference,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.muted),
                    style:
                        const TextStyle(fontSize: 16, color: AppColors.ink),
                    decoration: const InputDecoration(),
                    items: const [
                      DropdownMenuItem(
                          value: 'Before food', child: Text('Before food')),
                      DropdownMenuItem(
                          value: 'After food', child: Text('After food')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => foodPreference = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        LabeledField(
          label: 'Expiry date',
          controller: expiryController,
          hint: 'MM/YYYY',
          icon: Icons.calendar_today_outlined,
          helper: 'Use month and year, for example 06/2027.',
        ),
        const SectionHeading('Days to take medicine'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final day in DoseData.dayNames)
              _Pill(
                label: day,
                selected: selectedDays.contains(day),
                onTap: () => setState(() {
                  if (selectedDays.contains(day)) {
                    selectedDays.remove(day);
                  } else {
                    selectedDays.add(day);
                  }
                }),
              ),
          ],
        ),
        const SectionHeading('Reminder times'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final time in selectedTimes)
              _Pill(
                label: time.format(context),
                selected: true,
                trailingIcon: Icons.close,
                onTap: () => setState(() => selectedTimes.remove(time)),
              ),
            _Pill(
              label: 'Add time',
              selected: false,
              leadingIcon: Icons.add,
              onTap: _addTime,
            ),
          ],
        ),
        AppButton(isEditing ? 'Update medicine' : 'Save medicine',
            onPressed: _save),
        if (isEditing)
          AppButton('Delete medicine',
              icon: Icons.delete_outline,
              style: AppButtonStyle.danger,
              onPressed: _delete),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 6),
              Icon(trailingIcon, size: 14, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}
