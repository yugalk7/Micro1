import 'package:flutter/material.dart';

class RiskIndicator extends StatelessWidget {
final double percentage;

const RiskIndicator({super.key, required this.percentage});

Color getColor(double value) {
if (value > 70) return Colors.red;
if (value > 40) return Colors.orange;
return Colors.green;
}

@override
Widget build(BuildContext context) {
// 🔥 FIX: convert num → double
final double value = percentage.clamp(0, 100).toDouble();
final double progress = value / 100;


return Center(
  child: SizedBox(
    width: 140,
    height: 140,
    child: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(getColor(value)),
          ),
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${value.toStringAsFixed(1)}%",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: getColor(value),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Risk",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    ),
  ),
);


}
}
