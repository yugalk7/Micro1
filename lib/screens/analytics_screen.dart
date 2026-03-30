import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/database_helper.dart';
import '../data/models/patient.dart';
import '../widgets/app_drawer.dart';
import 'add_patient_screen.dart';

class AnalyticsScreen extends StatefulWidget {
const AnalyticsScreen({super.key});

@override
State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
List<Patient> patients = [];

@override
void initState() {
super.initState();
load();
}

Future<void> load() async {
final data = await DatabaseHelper.instance.getPatients();
setState(() => patients = data);
}

Widget labelItem(Color color, String title, int value, double percent) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 6),
child: Row(
children: [
Container(
width: 10,
height: 10,
decoration: BoxDecoration(color: color, shape: BoxShape.circle),
),
const SizedBox(width: 8),
Expanded(
child: Text(
"$title (${value})",
style: const TextStyle(fontWeight: FontWeight.w500),
),
),
Text("${percent.toStringAsFixed(0)}%"),
],
),
);
}

@override
Widget build(BuildContext context) {
int safe = patients.where((p) => p.clusterStatus == "Safe").length;
int warning = patients.where((p) => p.clusterStatus == "Warning").length;
int critical =
patients.where((p) => p.clusterStatus == "Critical").length;


int total = patients.length == 0 ? 1 : patients.length;

double safeP = (safe / total) * 100;
double warnP = (warning / total) * 100;
double critP = (critical / total) * 100;

return Scaffold(
  drawer: const AppDrawer(),
  appBar: AppBar(title: const Text("Analytics")),
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddPatientScreen()),
      );
      load();
    },
    icon: const Icon(Icons.add),
    label: const Text("Add Patient"),
  ),
  body: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        const Text(
          "Risk Distribution",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔥 DONUT CHART
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 60,
                    sections: [
                      PieChartSectionData(
                        value: safe.toDouble(),
                        color: Colors.green,
                        title: "",
                      ),
                      PieChartSectionData(
                        value: warning.toDouble(),
                        color: Colors.orange,
                        title: "",
                      ),
                      PieChartSectionData(
                        value: critical.toDouble(),
                        color: Colors.red,
                        title: "",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // 🔥 SIDE LABELS
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  labelItem(Colors.green, "Safe", safe, safeP),
                  labelItem(Colors.orange, "Warning", warning, warnP),
                  labelItem(Colors.red, "Critical", critical, critP),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Card(child: ListTile(title: Text("Safe Patients: $safe"))),
        Card(child: ListTile(title: Text("Warning Patients: $warning"))),
        Card(child: ListTile(title: Text("Critical Patients: $critical"))),
      ],
    ),
  ),
);


}
}
