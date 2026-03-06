import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../features/risk/risk_engine.dart';
import 'add_patient_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalPatients = 0;
  int highRiskPatients = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final patients = await DatabaseHelper.instance.getAllPatients();

    int highRisk = 0;
    for (var p in patients) {
      if (RiskEngine.calculate(p) == "High") {
        highRisk++;
      }
    }

    setState(() {
      totalPatients = patients.length;
      highRiskPatients = highRisk;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Arogya Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Welcome 👋",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(user?.phoneNumber ?? ""),

            const SizedBox(height: 20),

            Row(
              children: [
                _statCard(
                  "Total Patients",
                  totalPatients.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _statCard(
                  "High Risk",
                  highRiskPatients.toString(),
                  Icons.warning,
                  Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 30),

            _menuButton("Add Patient", Icons.person_add, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPatientScreen()),
              ).then((_) => loadStats());
            }),

            _menuButton("Sync Data", Icons.sync, () async {
              await DatabaseHelper.instance.syncPatientsToFirebase();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Sync Completed")));
            }),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
