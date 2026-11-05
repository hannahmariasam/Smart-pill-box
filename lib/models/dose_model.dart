
class DoseModel {
  final int id;
  final String medicine;
  final String dosage;
  final DateTime dateTime;
  final String period;
  String status;

  DoseModel({
    required this.id,
    required this.medicine,
    required this.dosage,
    required this.dateTime,
    required this.period,
    this.status = 'Pending',
  });
}
