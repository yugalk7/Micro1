import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'patient_list_screen.dart';
import 'map_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final pages = const [HomeScreen(), PatientListScreen(), MapScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          NavigationDestination(icon: Icon(Icons.people), label: "Patients"),
          NavigationDestination(icon: Icon(Icons.map), label: "Map"),
        ],
      ),
    );
  }
}
