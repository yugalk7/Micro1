import 'package:flutter/material.dart';

class ClusterAlertCard extends StatelessWidget {
  final String status;

  const ClusterAlertCard({super.key, required this.status});

  Color getColor() {
    switch (status) {
      case "Safe":
        return Colors.green;
      case "Warning":
        return Colors.orange;
      case "Critical":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getMessage() {
    switch (status) {
      case "Safe":
        return "No immediate risk detected.";
      case "Warning":
        return "Monitor patient closely.";
      case "Critical":
        return "Immediate medical attention required!";
      default:
        return "Unknown status";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: getColor().withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.warning, color: getColor()),
        title: Text(
          status,
          style: TextStyle(color: getColor(), fontWeight: FontWeight.bold),
        ),
        subtitle: Text(getMessage()),
      ),
    );
  }
}
