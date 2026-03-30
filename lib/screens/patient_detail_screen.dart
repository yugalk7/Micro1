import 'package:flutter/material.dart';
import '../data/models/patient.dart';
import '../widgets/risk_indicator.dart';
import '../widgets/cluster_alert_card.dart';

class PatientDetailScreen extends StatelessWidget {
final Patient patient;

const PatientDetailScreen({super.key, required this.patient});

Color getStatusColor(String? status) {
switch (status) {
case "Safe":
return Colors.green;
case "Warning":
return Colors.orange;
case "Critical":
return Colors.red;
default:
return Colors.grey;
}
}

String getRiskReason(Patient p) {
if (p.spo2 < 92) return "Low Oxygen Level";
if (p.temperature > 38.5) return "High Fever";
if (p.heartRate > 110) return "Elevated Heart Rate";
return "Vitals Normal";
}

Widget buildRow(String label, String value) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 6),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(label),
Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
],
),
);
}

@override
Widget build(BuildContext context) {
final risk = patient.confidenceScore ?? 0;
final status = patient.clusterStatus ?? "N/A";


return Scaffold(
  appBar: AppBar(title: Text(patient.name)),
  body: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        RiskIndicator(percentage: risk),

        const SizedBox(height: 20),

        Text(
          "Status: $status",
          style: TextStyle(
            color: getStatusColor(status),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text("Reason: ${getRiskReason(patient)}"),

        const SizedBox(height: 20),

        ClusterAlertCard(status: status),

        const SizedBox(height: 20),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                buildRow("Age", "${patient.age}"),
                buildRow("Gender", patient.gender),
                buildRow("Temp", "${patient.temperature}°C"),
                buildRow("HR", "${patient.heartRate} bpm"),
                buildRow("SpO2", "${patient.spo2}%"),
                buildRow("Household", patient.householdId),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
);


}
}
