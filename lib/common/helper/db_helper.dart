import 'dart:io';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@singleton
class LocalDBHelper {
  final String dbname = 'pos.db';
  // @factoryMethod
  // LocalDBHelper._instance();
  // static final LocalDBHelper db = LocalDBHelper._instance();

  late Database _database;

  Future<Database> get database async {
    _database = await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    final String dbPath = join(await getDatabasesPath(), dbname);
    if (!File(dbPath).existsSync()) {
      ByteData data = await rootBundle.load('assets/$dbname');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(dbPath).writeAsBytes(bytes);
    }

    final database = await openDatabase(
      dbPath,
    );
    return database;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute('MenuHdr create sql');
  }

  Future<void> _close() async {
    var db = await database;
    db.close();
  }
}

// final databaseProvider = Provider<Future<Database>>(((ref) async {
//   return await LocalDBHelper.db.database;
// }));
