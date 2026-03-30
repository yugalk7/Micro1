import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/patient.dart';

class DatabaseHelper {
static final DatabaseHelper instance = DatabaseHelper._init();
static Database? _database;

DatabaseHelper._init();

Future<Database> get database async {
if (_database != null) return _database!;
_database = await _initDB('patients.db');
return _database!;
}

Future<Database> _initDB(String filePath) async {
final path = join(await getDatabasesPath(), filePath);

return await openDatabase(
  path,
  version: 1,
  onCreate: _createDB,
);


}

Future _createDB(Database db, int version) async {
await db.execute('''
CREATE TABLE patients (
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT,
age INTEGER,
temperature REAL,
heartRate REAL,
spo2 REAL,
gender TEXT,
householdId TEXT,
confidenceScore REAL,
riskStatus TEXT,
hcrs REAL,
clusterStatus TEXT
)
''');
}

Future<int> insertPatient(Patient patient) async {
final db = await instance.database;
return await db.insert('patients', patient.toMap());
}

Future<List<Patient>> getPatients() async {
final db = await instance.database;
final result = await db.query('patients');
return result.map((json) => Patient.fromMap(json)).toList();
}

Future<void> deleteDatabase() async {
final dbPath = await getDatabasesPath();
final path = join(dbPath, 'patients.db');
await databaseFactory.deleteDatabase(path);
}
}
