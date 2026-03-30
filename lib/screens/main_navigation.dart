import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'patient_list_screen.dart';
import 'map_screen.dart';
import 'analytics_screen.dart';

class MainNavigation extends StatefulWidget {
const MainNavigation({super.key});

@override
State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
int _selectedIndex = 0;

final List<Widget> _screens = [
const HomeScreen(),
const PatientListScreen(),
const MapScreen(),
const AnalyticsScreen(),
];

void _onItemTapped(int index) {
setState(() {
_selectedIndex = index;
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: _screens[_selectedIndex],

  bottomNavigationBar: NavigationBar(
    selectedIndex: _selectedIndex,
    onDestinationSelected: _onItemTapped,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.dashboard),
        label: "Dashboard",
      ),
      NavigationDestination(
        icon: Icon(Icons.people),
        label: "Patients",
      ),
      NavigationDestination(
        icon: Icon(Icons.map),
        label: "Map",
      ),
      NavigationDestination(
        icon: Icon(Icons.analytics),
        label: "Analytics",
      ),
    ],
  ),
);


}
}
