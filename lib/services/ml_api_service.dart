import 'dart:convert';
import 'package:http/http.dart' as http;

class MLApiService {
// 🔥 YOUR RENDER URL
static const String baseUrl = "https://arogya-backend-q2rg.onrender.com";

static Future<Map<String, dynamic>> predict({
required int age,
required String gender,
required double heartRate,
required double temperature,
required double spo2,
required String householdId,  
}) async {
try {
final response = await http
.post(
Uri.parse("$baseUrl/predict"),
headers: {
"Content-Type": "application/json",
},
body: jsonEncode({
"Age": age,
"Gender": gender,
"HeartRate": heartRate,
"Temperature": temperature,
"SpO2": spo2,
"Household_ID": householdId,
}),
)
.timeout(const Duration(seconds: 10));

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Server error: ${response.body}");
  }
} catch (e) {
  print("API ERROR: $e");
  throw Exception("Failed to connect to backend");
}


}
}
