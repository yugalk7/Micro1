import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
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
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'arogya.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        weight REAL NOT NULL,
        temperature REAL NOT NULL,
        lastVisit TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  /// Delete old database (for schema updates)
  Future<void> deleteDatabase() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, 'arogya.db');
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        print("Old database deleted");
      }
      _database = null;
    } catch (e) {
      print("Delete database error: $e");
    }
  }

  /// INSERT patient (offline)
  Future<int> insertPatient(Patient patient) async {
    try {
      final db = await database;
      return await db.insert('patients', patient.toMap());
    } catch (e) {
      print("Insert error: $e");
      rethrow;
    }
  }

  /// FETCH all patients
  Future<List<Patient>> getAllPatients() async {
    try {
      final db = await database;
      final result = await db.query('patients', orderBy: 'createdAt DESC');
      return result.map((e) => Patient.fromMap(e)).toList();
    } catch (e) {
      print("Fetch error: $e");
      return [];
    }
  }

  /// FETCH patient by ID
  Future<Patient?> getPatientById(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        'patients',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return Patient.fromMap(result.first);
    } catch (e) {
      print("Fetch by ID error: $e");
      return null;
    }
  }

  /// UPDATE patient
  Future<int> updatePatient(Patient patient) async {
    try {
      final db = await database;
      return await db.update(
        'patients',
        patient.toMap(),
        where: 'id = ?',
        whereArgs: [patient.id],
      );
    } catch (e) {
      print("Update error: $e");
      rethrow;
    }
  }

  /// DELETE patient
  Future<int> deletePatient(int id) async {
    try {
      final db = await database;
      return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print("Delete error: $e");
      rethrow;
    }
  }

  /// GET unsynced patients count
  Future<int> getUnsyncedCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM patients WHERE synced = 0',
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      print("Count error: $e");
      return 0;
    }
  }

  /// GET unsynced patients list
  Future<List<Patient>> getUnsyncedPatients() async {
    try {
      final db = await database;
      final result = await db.query(
        'patients',
        where: 'synced = ?',
        whereArgs: [0],
      );
      return result.map((e) => Patient.fromMap(e)).toList();
    } catch (e) {
      print("Fetch unsynced error: $e");
      return [];
    }
  }

  /// SYNC unsynced patients to Firebase
  Future<void> syncPatientsToFirebase() async {
    try {
      final db = await database;

      final unsyncedRows = await db.query(
        'patients',
        where: 'synced = ?',
        whereArgs: [0],
      );

      if (unsyncedRows.isEmpty) {
        print("No unsynced records");
        return;
      }

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

      print("Sync completed: ${unsyncedRows.length} records synced");
    } catch (e) {
      print("Sync error: $e");
      rethrow;
    }
  }

  /// CLOSE database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
