import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/patient.dart';
import '../widgets/app_drawer.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
const PatientListScreen({super.key});

@override
State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
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

Color getColor(String? status) {
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

@override
Widget build(BuildContext context) {
return Scaffold(
drawer: const AppDrawer(),
appBar: AppBar(title: const Text("Patients")),
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
body: ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: patients.length,
itemBuilder: (context, index) {
final p = patients[index];


      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text(p.name),
          subtitle: Text("Age: ${p.age}"),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${p.confidenceScore?.toStringAsFixed(1) ?? 0}%",
                style: TextStyle(
                  color: getColor(p.clusterStatus),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                p.clusterStatus ?? "",
                style: TextStyle(color: getColor(p.clusterStatus)),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDetailScreen(patient: p),
              ),
            );
          },
        ),
      );
    },
  ),
);


}
}
