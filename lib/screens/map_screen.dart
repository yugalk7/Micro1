import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/patient.dart';
import '../features/risk/risk_engine.dart';
import '../core/theme.dart';
import 'patient_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Patient> allPatients = [];
  List<Patient> highRiskPatients = [];
  List<Patient> mediumRiskPatients = [];
  List<Patient> lowRiskPatients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPatientData();
  }

  Future<void> loadPatientData() async {
    setState(() => isLoading = true);

    try {
      final patients = await DatabaseHelper.instance.getAllPatients();

      highRiskPatients = [];
      mediumRiskPatients = [];
      lowRiskPatients = [];

      for (var patient in patients) {
        final risk = RiskEngine.calculate(patient);
        if (risk == "High") {
          highRiskPatients.add(patient);
        } else if (risk == "Medium") {
          mediumRiskPatients.add(patient);
        } else {
          lowRiskPatients.add(patient);
        }
      }

      setState(() {
        allPatients = patients;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Risk Analysis Dashboard"),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadPatientData,
              child: allPatients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No patient data available",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  "Total",
                                  allPatients.length.toString(),
                                  Colors.blue,
                                  Icons.people,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildSummaryCard(
                                  "High Risk",
                                  highRiskPatients.length.toString(),
                                  AppTheme.highRiskRed,
                                  Icons.warning_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  "Medium Risk",
                                  mediumRiskPatients.length.toString(),
                                  AppTheme.mediumRiskOrange,
                                  Icons.info_rounded,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildSummaryCard(
                                  "Low Risk",
                                  lowRiskPatients.length.toString(),
                                  AppTheme.lowRiskGreen,
                                  Icons.check_circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // High Risk Section
                          if (highRiskPatients.isNotEmpty) ...[
                            _buildRiskHeader(
                              "🔴 HIGH RISK - URGENT",
                              highRiskPatients.length,
                              AppTheme.highRiskRed,
                            ),
                            const SizedBox(height: 12),
                            _buildPatientsList(
                              highRiskPatients,
                              AppTheme.highRiskRed,
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Medium Risk Section
                          if (mediumRiskPatients.isNotEmpty) ...[
                            _buildRiskHeader(
                              "🟠 MEDIUM RISK - MONITOR",
                              mediumRiskPatients.length,
                              AppTheme.mediumRiskOrange,
                            ),
                            const SizedBox(height: 12),
                            _buildPatientsList(
                              mediumRiskPatients,
                              AppTheme.mediumRiskOrange,
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Low Risk Section
                          if (lowRiskPatients.isNotEmpty) ...[
                            _buildRiskHeader(
                              "🟢 LOW RISK - ROUTINE",
                              lowRiskPatients.length,
                              AppTheme.lowRiskGreen,
                            ),
                            const SizedBox(height: 12),
                            _buildPatientsList(
                              lowRiskPatients,
                              AppTheme.lowRiskGreen,
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: loadPatientData,
        tooltip: "Refresh",
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String count,
    Color color,
    IconData icon,
  ) {
    return GestureDetector(
      child: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.08),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                count,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskHeader(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsList(List<Patient> patients, Color color) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        final risk = RiskEngine.calculate(patient);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatientDetailScreen(patient: patient),
                ),
              ).then((_) => loadPatientData());
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        patient.name[0].toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${patient.age}y • ${patient.weight}kg • ${patient.temperature}°C",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                        patient.synced == 1
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                        color: patient.synced == 1
                            ? AppTheme.lowRiskGreen
                            : Colors.red,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
