class DoseModel {
  final int id;
  final int medicineId;
  final String medicine;
  final String dosage;
  final DateTime dateTime;
  final String period;
  String status;

  DoseModel({
    required this.id,
    this.medicineId = 0,
    required this.medicine,
    required this.dosage,
    required this.dateTime,
    required this.period,
    this.status = 'Pending',
  });
}
