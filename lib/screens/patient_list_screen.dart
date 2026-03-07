import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/patient.dart';
import '../features/risk/risk_engine.dart';
import '../core/theme.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Patient> patients = [];
  List<Patient> filteredPatients = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  Future<void> loadPatients() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getAllPatients();
    setState(() {
      patients = data;
      filteredPatients = data;
      isLoading = false;
    });
  }

  void searchPatients(String query) {
    final result = patients.where((p) {
      return p.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() => filteredPatients = result);
  }

  Color riskColor(String risk) {
    switch (risk) {
      case "High":
        return AppTheme.highRiskRed;
      case "Medium":
        return AppTheme.mediumRiskOrange;
      default:
        return AppTheme.lowRiskGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient List")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPatientScreen()),
          );
          loadPatients();
        },
        child: const Icon(Icons.person_add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadPatients,
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: searchController,
                      onChanged: searchPatients,
                      decoration: InputDecoration(
                        hintText: "Search by name...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  loadPatients();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  // Patient List
                  Expanded(
                    child: filteredPatients.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No patients found",
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredPatients.length,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemBuilder: (context, index) {
                              return _buildPatientCard(filteredPatients[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    final risk = RiskEngine.calculate(patient);
    final color = riskColor(risk);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDetailScreen(patient: patient),
            ),
          ).then((_) => loadPatients());
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar with Risk Color
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              // Patient Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.cake_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${patient.age}y  •  "),
                        Icon(
                          Icons.scale_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text("${patient.weight}kg  •  "),
                        Icon(
                          Icons.thermostat_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text("${patient.temperature}°C"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      risk,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    patient.synced == 1 ? Icons.cloud_done : Icons.cloud_off,
                    color: patient.synced == 1
                        ? AppTheme.lowRiskGreen
                        : Colors.red,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
