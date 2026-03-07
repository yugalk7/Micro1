import '../../data/models/patient.dart';

class RiskEngine {
  /// Calculate health risk level (0-100 score)
  static String calculate(Patient p) {
    int riskScore = 0;

    // Temperature Analysis (0-40 points)
    // Celsius scale
    if (p.temperature > 39.5) {
      riskScore += 40; // Critical fever
    } else if (p.temperature > 38.5) {
      riskScore += 25; // High fever
    } else if (p.temperature > 37.5) {
      riskScore += 10; // Mild fever
    } else if (p.temperature < 36.0) {
      riskScore += 15; // Hypothermia risk
    }

    // Age Analysis (0-25 points)
    if (p.age < 5) {
      riskScore += 25; // Children - highly vulnerable
    } else if (p.age < 12) {
      riskScore += 15; // Young children
    } else if (p.age > 65) {
      riskScore += 20; // Elderly - higher risk
    } else if (p.age > 75) {
      riskScore += 25; // Very elderly
    }

    // Weight Analysis (0-20 points)
    final bmi = _calculateBMI(p.weight, p.age);
    if (bmi < 18.5) {
      riskScore += 15; // Underweight
    } else if (bmi > 30) {
      riskScore += 10; // Overweight
    }

    // Recent visit frequency (0-15 points)
    final daysSinceVisit = _daysSinceLastVisit(p.lastVisit);
    if (daysSinceVisit > 30) {
      riskScore += 15; // Long gap since last visit
    } else if (daysSinceVisit > 14) {
      riskScore += 8;
    }

    // Determine risk level
    if (riskScore >= 60) {
      return "High";
    } else if (riskScore >= 30) {
      return "Medium";
    } else {
      return "Low";
    }
  }

  /// Calculate BMI
  static double _calculateBMI(double weight, int age) {
    // Estimate height based on age
    double height = 1.65; // Default for adults

    if (age < 5) {
      height = 1.0;
    } else if (age < 10) {
      height = 1.2;
    } else if (age < 15) {
      height = 1.5;
    }

    return weight / (height * height);
  }

  /// Calculate days since last visit
  static int _daysSinceLastVisit(String lastVisitDate) {
    try {
      final last = DateTime.parse(lastVisitDate);
      final difference = DateTime.now().difference(last);
      return difference.inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Get risk icon
  static String getRiskIcon(String risk) {
    switch (risk) {
      case "High":
        return "🔴";
      case "Medium":
        return "🟠";
      default:
        return "🟢";
    }
  }

  /// Get health recommendation
  static String getRecommendation(String risk) {
    switch (risk) {
      case "High":
        return "⚠️ Urgent: Schedule immediate medical follow-up";
      case "Medium":
        return "📋 Monitor closely: Follow-up within 48 hours";
      default:
        return "✓ Routine: Next check-up in 7 days";
    }
  }

  /// Get risk severity (0-100)
  static int getRiskScore(Patient p) {
    int riskScore = 0;

    if (p.temperature > 39.5) {
      riskScore += 40;
    } else if (p.temperature > 38.5)
      riskScore += 25;
    else if (p.temperature > 37.5)
      riskScore += 10;
    else if (p.temperature < 36.0)
      riskScore += 15;

    if (p.age < 5) {
      riskScore += 25;
    } else if (p.age < 12)
      riskScore += 15;
    else if (p.age > 65)
      riskScore += 20;
    else if (p.age > 75)
      riskScore += 25;

    final bmi = _calculateBMI(p.weight, p.age);
    if (bmi < 18.5) {
      riskScore += 15;
    } else if (bmi > 30)
      riskScore += 10;

    final daysSinceVisit = _daysSinceLastVisit(p.lastVisit);
    if (daysSinceVisit > 30) {
      riskScore += 15;
    } else if (daysSinceVisit > 14)
      riskScore += 8;

    return riskScore;
  }
}
