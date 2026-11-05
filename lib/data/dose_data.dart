
import '../models/dose_model.dart';

class DoseData {
  static final DateTime today = DateTime.now();

  static final List<DoseModel> doses = [
    DoseModel(
      id: 1,
      medicine: 'Metformin',
      dosage: '500 mg',
      dateTime: DateTime(
        today.year, today.month, today.day, 8, 0,
      ),
      period: 'Morning',
      status: 'Taken',
    ),

    DoseModel(
      id: 2,
      medicine: 'Vitamin D',
      dosage: '1000 IU',
      dateTime: DateTime(
        today.year, today.month, today.day, 9, 0,
      ),
      period: 'Morning',
      status: 'Pending',
    ),

    DoseModel(
      id: 3,
      medicine: 'Atorvastatin',
      dosage: '10 mg',
      dateTime: DateTime(
        today.year, today.month, today.day, 13, 0,
      ),
      period: 'Afternoon',
      status: 'Pending',
    ),

    DoseModel(
      id: 4,
      medicine: 'Metformin',
      dosage: '500 mg',
      dateTime: DateTime(
        today.year, today.month, today.day, 20, 0,
      ),
      period: 'Evening',
      status: 'Pending',
    ),
  ];
}
