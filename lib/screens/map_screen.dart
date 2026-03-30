import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/database_helper.dart';
import '../data/models/patient.dart';

class MapScreen extends StatefulWidget {
const MapScreen({super.key});

@override
State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
GoogleMapController? _mapController;

Set<Marker> _markers = {};

@override
void initState() {
super.initState();
_loadHotspots();
}

Future<void> _loadHotspots() async {
final patients = await DatabaseHelper.instance.getPatients();


Map<String, List<Patient>> grouped = {};

// 🔥 GROUP BY HOUSEHOLD
for (var p in patients) {
  grouped.putIfAbsent(p.householdId, () => []).add(p);
}

Set<Marker> markers = {};

int index = 0;

grouped.forEach((householdId, members) {
  double avgRisk = 0;

  for (var m in members) {
    avgRisk += m.confidenceScore ?? 0;
  }

  avgRisk /= members.length;

  // 🔥 DETERMINE COLOR
  BitmapDescriptor color;

  if (avgRisk < 30) {
    color = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  } else if (avgRisk < 60) {
    color = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  } else {
    color = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }

  // 🔥 FAKE LOCATION (for demo)
  double lat = 19.0760 + (index * 0.001);
  double lng = 72.8777 + (index * 0.001);

  markers.add(
    Marker(
      markerId: MarkerId(householdId),
      position: LatLng(lat, lng),
      icon: color,
      infoWindow: InfoWindow(
        title: "Household $householdId",
        snippet: "Avg Risk: ${avgRisk.toStringAsFixed(1)}%",
      ),
    ),
  );

  index++;
});

setState(() {
  _markers = markers;
});


}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("Hotspot Map"),
),
body: GoogleMap(
initialCameraPosition: const CameraPosition(
target: LatLng(19.0760, 72.8777), // Mumbai default
zoom: 12,
),
markers: _markers,
onMapCreated: (controller) {
_mapController = controller;
},
),
);
}
}
