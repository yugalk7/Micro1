import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/patient.dart';
import '../services/ml_api_service.dart';

class AddPatientScreen extends StatefulWidget {
const AddPatientScreen({super.key});

@override
State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
final _formKey = GlobalKey<FormState>();

final _name = TextEditingController();
final _age = TextEditingController();
final _temp = TextEditingController();
final _hr = TextEditingController();
final _spo2 = TextEditingController();
final _house = TextEditingController();

String _gender = "Male";
bool _loading = false;

Widget field(String label, TextEditingController c,
{TextInputType type = TextInputType.number}) {
return Padding(
padding: const EdgeInsets.only(bottom: 14),
child: TextFormField(
controller: c,
keyboardType: type,
decoration: InputDecoration(labelText: label),
validator: (v) {
if (v == null || v.isEmpty) return "Required";
return null;
},
),
);
}

Future<void> save() async {
if (!_formKey.currentState!.validate()) return;


setState(() => _loading = true);

try {
  final result = await MLApiService.predict(
    age: int.parse(_age.text),
    gender: _gender,
    heartRate: double.parse(_hr.text),
    temperature: double.parse(_temp.text),
    spo2: double.parse(_spo2.text),
    householdId: _house.text,
  );

  print("🔥 RESPONSE: $result");

  final patient = Patient(
    name: _name.text,
    age: int.parse(_age.text),
    temperature: double.parse(_temp.text),
    heartRate: double.parse(_hr.text),
    spo2: double.parse(_spo2.text),
    gender: _gender,
    householdId: _house.text,
    confidenceScore: (result["confidence_score"] ?? 0).toDouble(),
    riskStatus: result["risk_status"] ?? "Low",
    hcrs: (result["hcrs"] ?? 0).toDouble(),
    clusterStatus: result["cluster_status"] ?? "Safe",
  );

  await DatabaseHelper.instance.insertPatient(patient);

  if (mounted) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Patient added successfully")),
    );
  }
} catch (e) {
  print("❌ ERROR: $e");

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Error: $e")),
  );
}

setState(() => _loading = false);


}

@override
void dispose() {
_name.dispose();
_age.dispose();
_temp.dispose();
_hr.dispose();
_spo2.dispose();
_house.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("Add Patient")),
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Form(
key: _formKey,
child: Column(
children: [
field("Name", _name, type: TextInputType.text),
field("Age", _age),
field("Temperature (°C)", _temp),

            DropdownButtonFormField<String>(
              value: _gender,
              items: ["Male", "Female"]
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _gender = v!),
              decoration: const InputDecoration(labelText: "Gender"),
            ),

            const SizedBox(height: 14),

            field("Heart Rate", _hr),
            field("SpO2", _spo2),
            field("Household ID", _house,
                type: TextInputType.text),

            const SizedBox(height: 24),

            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: save,
                      child: const Text("Save Patient"),
                    ),
                  ),
          ],
        ),
      ),
    ),
  ),
);


}
}
