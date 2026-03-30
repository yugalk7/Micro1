import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/patient.dart';
import '../widgets/risk_indicator.dart';
import '../widgets/app_drawer.dart';
import '../services/user_service.dart';
import 'add_patient_screen.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
List<Patient> patients = [];
String name = "Health Worker";

@override
void initState() {
super.initState();
load();
}

Future<void> load() async {
final data = await DatabaseHelper.instance.getPatients();
final user = await UserService.getUser();


setState(() {
  patients = data;
  name = user["name"]!;
});


}

Widget statCard(String title, String value, Color color) {
return Expanded(
child: AnimatedContainer(
duration: const Duration(milliseconds: 300),
child: Card(
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
Text(
value,
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: color,
),
),
const SizedBox(height: 6),
Text(title),
],
),
),
),
),
);
}

Color getColor(String status) {
switch (status) {
case "Critical":
return Colors.red;
case "Warning":
return Colors.orange;
default:
return Colors.green;
}
}

@override
Widget build(BuildContext context) {
int total = patients.length;
int critical =
patients.where((p) => p.clusterStatus == "Critical").length;


double avg = patients.isEmpty
    ? 0
    : patients
            .map((p) => p.confidenceScore ?? 0)
            .reduce((a, b) => a + b) /
        total;

return Scaffold(
  drawer: const AppDrawer(),
  appBar: AppBar(title: const Text("Dashboard")),
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
  body: RefreshIndicator(
    onRefresh: load,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 🔥 Gradient Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B8E5A), Color(0xFF43A047)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, $name 👋",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Monitor patient health insights",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Center(child: RiskIndicator(percentage: avg)),

        const SizedBox(height: 20),

        Row(
          children: [
            statCard("Patients", "$total", Colors.blue),
            const SizedBox(width: 10),
            statCard("Critical", "$critical", Colors.red),
          ],
        ),

        const SizedBox(height: 10),

        statCard("Avg Risk", "${avg.toStringAsFixed(1)}%", Colors.orange),
      ],
    ),
  ),
);


}
}
