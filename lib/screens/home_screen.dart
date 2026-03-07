import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/database_helper.dart';
import '../features/risk/risk_engine.dart';
import '../core/theme.dart';
import 'add_patient_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalPatients = 0;
  int highRiskPatients = 0;
  int mediumRiskPatients = 0;
  int lowRiskPatients = 0;
  int unsyncedRecords = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    setState(() => isLoading = true);

    try {
      final patients = await DatabaseHelper.instance.getAllPatients();
      int highRisk = 0;
      int mediumRisk = 0;
      int lowRisk = 0;
      int unsynced = 0;

      for (var p in patients) {
        final risk = RiskEngine.calculate(p);
        if (risk == "High") {
          highRisk++;
        } else if (risk == "Medium") {
          mediumRisk++;
        } else {
          lowRisk++;
        }
        if (p.synced == 0) unsynced++;
      }

      setState(() {
        totalPatients = patients.length;
        highRiskPatients = highRisk;
        mediumRiskPatients = mediumRisk;
        lowRiskPatients = lowRisk;
        unsyncedRecords = unsynced;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading stats: $e"),
            backgroundColor: AppTheme.highRiskRed,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Arogya Dashboard"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadStats,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGreen.withOpacity(0.1),
                            AppTheme.primaryGreen.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back! 👋",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.phoneNumber ?? "Healthcare Worker",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Stats Grid
                    Text(
                      "Statistics",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          "Total Patients",
                          totalPatients.toString(),
                          Icons.people_outline,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          "High Risk",
                          highRiskPatients.toString(),
                          Icons.warning_amber_rounded,
                          AppTheme.highRiskRed,
                        ),
                        _buildStatCard(
                          "Medium Risk",
                          mediumRiskPatients.toString(),
                          Icons.info_outline,
                          AppTheme.mediumRiskOrange,
                        ),
                        _buildStatCard(
                          "Low Risk",
                          lowRiskPatients.toString(),
                          Icons.check_circle_outline,
                          AppTheme.lowRiskGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Sync Status Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: unsyncedRecords > 0
                            ? Colors.orange.withOpacity(0.1)
                            : AppTheme.lowRiskGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: unsyncedRecords > 0
                              ? Colors.orange
                              : AppTheme.lowRiskGreen,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            unsyncedRecords > 0
                                ? Icons.cloud_off
                                : Icons.cloud_done,
                            color: unsyncedRecords > 0
                                ? Colors.orange
                                : AppTheme.lowRiskGreen,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  unsyncedRecords > 0
                                      ? "$unsyncedRecords records pending sync"
                                      : "All data synced",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: unsyncedRecords > 0
                                            ? Colors.orange
                                            : AppTheme.lowRiskGreen,
                                      ),
                                ),
                                Text(
                                  unsyncedRecords > 0
                                      ? "Tap sync button to upload"
                                      : "Data is stored in cloud",
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Action Buttons Section
                    Text(
                      "Quick Actions",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      "Add New Patient",
                      Icons.person_add_outlined,
                      () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddPatientScreen(),
                          ),
                        );
                        loadStats();
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildActionButton(
                      "Sync Data to Cloud",
                      Icons.cloud_sync_outlined,
                      () async {
                        try {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Syncing..."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          await DatabaseHelper.instance
                              .syncPatientsToFirebase();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✓ Data synced successfully"),
                                backgroundColor: AppTheme.lowRiskGreen,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            loadStats();
                          }
                        } on Exception catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Sync error: $e"),
                                backgroundColor: AppTheme.highRiskRed,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildActionButton(
                      "Refresh Statistics",
                      Icons.refresh_outlined,
                      loadStats,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
