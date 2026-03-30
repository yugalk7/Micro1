class Patient {
  int? id;
  String name;
  int age;
  double temperature;
  double heartRate;
  double spo2;
  String gender;
  String householdId;

  double confidenceScore;
  String riskStatus;
  double hcrs;
  String clusterStatus;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.temperature,
    required this.heartRate,
    required this.spo2,
    required this.gender,
    required this.householdId,
    required this.confidenceScore,
    required this.riskStatus,
    required this.hcrs,
    required this.clusterStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'temperature': temperature,
      'heartRate': heartRate,
      'spo2': spo2,
      'gender': gender,
      'householdId': householdId,
      'confidenceScore': confidenceScore,
      'riskStatus': riskStatus,
      'hcrs': hcrs,
      'clusterStatus': clusterStatus,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      temperature: map['temperature'],
      heartRate: map['heartRate'],
      spo2: map['spo2'],
      gender: map['gender'],
      householdId: map['householdId'],
      confidenceScore: map['confidenceScore'],
      riskStatus: map['riskStatus'],
      hcrs: map['hcrs'],
      clusterStatus: map['clusterStatus'],
    );
  }
}
