class Patient {
  final int? id;
  final String name;
  final int age;
  final double weight;
  final double temperature;
  final String lastVisit;
  final int synced;
  final String createdAt;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.weight,
    required this.temperature,
    required this.lastVisit,
    this.synced = 0,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  /// SQLite → Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'weight': weight,
      'temperature': temperature,
      'lastVisit': lastVisit,
      'synced': synced,
      'createdAt': createdAt,
    };
  }

  /// SQLite → Object
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      weight: map['weight'],
      temperature: map['temperature'],
      lastVisit: map['lastVisit'],
      synced: map['synced'],
      createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  /// Firebase → Map (NO id, NO synced)
  Map<String, dynamic> toFirebaseMap() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
      'temperature': temperature,
      'lastVisit': lastVisit,
      'createdAt': createdAt,
    };
  }
}
