
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:io';
import 'dart:developer' as devtools;

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _butterflyInformationTableName = 'butterfly_species';
  final String _speciesIdColumnName = 'species_id';
  final String _speciesNameColumnName = 'species_name';

  DatabaseService._constructor();

    Future<Database> initDatabase() async {
    // Get the path to the database directory
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'butterfly_species.db');

    // Check if the database already exists
    bool dbExists = await databaseExists(path);

    if (!dbExists) {
      // If the database doesn't exist, copy it from assets
      devtools.log('Copying database from assets...');
      ByteData data =
          await rootBundle.load('assets/databases/butterfly_species.db');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write the copied database to the device
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      devtools.log('Database already exists.');
    }

    // Open the database
    return await openDatabase(path);
  }

   Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

    Future<Map<String, dynamic>?> getButterflyInfo(int speciesId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      _butterflyInformationTableName,
      where: '$_speciesIdColumnName = ?',
      whereArgs: [speciesId],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

//   Future<Database> get database async {
//     if (_db != null) {
//       return _db!;
//     }
//     _db = await getDatabase();
//     return _db!;
//   }

//   Future<Database> getDatabase() async {
//     final databaseDirPath = await getDatabasesPath();
//     final databasePath = join(databaseDirPath, 'butterflies_database.db');

//     final database = await openDatabase(
//       databasePath,
//       //version: 1,
//       onCreate: (db, version) {
//         db.execute('''
// CREATE TABLE $_butterflyInformationTableName(
//   $_speciesIdColumnName INTEGER PRIMARY KEY,
//   $_speciesNameColumnName TEXT NOT NULL,
// )
// ''');
//       },
//     );
//     return database;
//   }
// }


}
