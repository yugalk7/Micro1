import '../../data/models/patient.dart';

class RiskEngine {
  static String calculate(Patient p) {
    if (p.temperature > 102 || p.weight < 40) {
      return "High";
    }
    return "Normal";
  }
}
