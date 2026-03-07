import 'package:flutter/material.dart';
import '../data/models/patient.dart';
import '../data/database_helper.dart';
import '../features/risk/risk_engine.dart';
import '../core/theme.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Patient patient;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    patient = widget.patient;
  }

  Future<void> _deletePatient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Patient?"),
        content: Text(
          "Are you sure you want to delete ${patient.name}? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && patient.id != null) {
      setState(() => isLoading = true);
      try {
        await DatabaseHelper.instance.deletePatient(patient.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✓ Patient deleted"),
              backgroundColor: AppTheme.lowRiskGreen,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
              backgroundColor: AppTheme.highRiskRed,
            ),
          );
        }
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final risk = RiskEngine.calculate(patient);
    final riskColor = risk == "High"
        ? AppTheme.highRiskRed
        : risk == "Medium"
        ? AppTheme.mediumRiskOrange
        : AppTheme.lowRiskGreen;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: isLoading ? null : _deletePatient,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: riskColor),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: riskColor,
                          radius: 40,
                          child: Text(
                            patient.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.name,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: riskColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Risk: $risk",
                                  style: TextStyle(
                                    color: riskColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Vital Signs Section
                  Text(
                    "Vital Signs",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    "Age",
                    "${patient.age} years",
                    Icons.cake_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    "Weight",
                    "${patient.weight} kg",
                    Icons.scale_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    "Temperature",
                    "${patient.temperature}°C",
                    Icons.thermostat_outlined,
                  ),
                  const SizedBox(height: 28),

                  // Visit Information
                  Text(
                    "Visit Information",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    "Last Visit",
                    patient.lastVisit,
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    "Created",
                    patient.createdAt,
                    Icons.schedule,
                  ),
                  const SizedBox(height: 28),

                  // Sync Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: patient.synced == 1
                          ? AppTheme.lowRiskGreen.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: patient.synced == 1
                            ? AppTheme.lowRiskGreen
                            : Colors.orange,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          patient.synced == 1
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          color: patient.synced == 1
                              ? AppTheme.lowRiskGreen
                              : Colors.orange,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.synced == 1 ? "Synced" : "Not Synced",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: patient.synced == 1
                                          ? AppTheme.lowRiskGreen
                                          : Colors.orange,
                                    ),
                              ),
                              Text(
                                patient.synced == 1
                                    ? "Data is synced to cloud"
                                    : "Data is stored locally only",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Recommendation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: riskColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recommendation",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          RiskEngine.getRecommendation(risk),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
