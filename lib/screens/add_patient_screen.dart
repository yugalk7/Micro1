import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/patient.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController tempController = TextEditingController();

  bool loading = false;

  Future<void> savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final patient = Patient(
      name: nameController.text.trim(),
      age: int.parse(ageController.text.trim()),
      weight: double.parse(weightController.text.trim()),
      temperature: double.parse(tempController.text.trim()),
      lastVisit: DateTime.now().toString(),
      synced: 0,
    );

    await DatabaseHelper.instance.insertPatient(patient);

    setState(() => loading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Patient Added Successfully")));

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    tempController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Patient")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _inputField(
                controller: nameController,
                label: "Patient Name",
                validator: (value) =>
                    value!.isEmpty ? "Enter patient name" : null,
              ),

              const SizedBox(height: 16),

              _inputField(
                controller: ageController,
                label: "Age",
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter age" : null,
              ),

              const SizedBox(height: 16),

              _inputField(
                controller: weightController,
                label: "Weight (kg)",
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter weight" : null,
              ),

              const SizedBox(height: 16),

              _inputField(
                controller: tempController,
                label: "Temperature (°F)",
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Enter temperature" : null,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: loading ? null : savePatient,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Patient"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
