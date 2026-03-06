import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/patient.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'arogya.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        weight REAL,
        temperature REAL,
        lastVisit TEXT,
        synced INTEGER
      )
    ''');
  }

  // INSERT patient (offline)
  Future<int> insertPatient(Patient patient) async {
    final db = await database;
    return await db.insert('patients', patient.toMap());
  }

  // FETCH all patients
  Future<List<Patient>> getAllPatients() async {
    final db = await database;
    final result = await db.query('patients');

    return result.map((e) => Patient.fromMap(e)).toList();
  }

  // SYNC unsynced patients to Firebase
  Future<void> syncPatientsToFirebase() async {
    final db = await database;

    final unsyncedRows = await db.query(
      'patients',
      where: 'synced = ?',
      whereArgs: [0],
    );

    final firestore = FirebaseFirestore.instance;

    for (final row in unsyncedRows) {
      final patient = Patient.fromMap(row);

      await firestore.collection('patients').add(patient.toFirebaseMap());

      await db.update(
        'patients',
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }
}
