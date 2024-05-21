import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../common/helper/db_helper.dart';
import '../../common/utils/type_util.dart';
import '../model/printer_model.dart';
import '../model/printer_support_model.dart';
import 'i_printer_repository.dart';

@Injectable(as: IPrinterRepository)
class PrinterLocalRepository extends IPrinterRepository with TypeUtil {
  PrinterLocalRepository(this.dbHelper);

  final LocalDBHelper dbHelper;
  @override
  Future<void> addPrinter(PrinterModel printer) async {
    Database db = await dbHelper.database;
    String query =
        "INSERT INTO PrinterIOSPOS(PrinterType, PrinterDeviceName, Address, Port, InterfaceType) VALUES ('${printer.printerType}', '${printer.printerDeviceName}', '${printer.address}', '${printer.port}', '${printer.interfaceType}')";
    await db.rawQuery(query);
  }

  @override
  Future<int> checkMaxPrinterID() async {
    Database db = await dbHelper.database;
    String query = 'SELECT MAX(PrinterID) FROM PrinterIOSPOS';
    List<Map<String, dynamic>> data = await db.rawQuery(query);
    if (data.isNotEmpty) {
      return dynamicToInt(data[0]);
    }
    return 0;
  }

  @override
  Future<void> deletePrinter(int printerID) async {
    Database db = await dbHelper.database;
    String query = 'DELETE FROM PrinterIOSPOS WHERE PrinterID = $printerID';
    await db.rawQuery(query);

    query = 'SELECT * FROM PrinterIOSPOS WHERE PrinterID > $printerID';
    List<Map<String, dynamic>> data = await db.rawQuery(query);
    for (int i = 0; i < data.length; i++) {
      query =
          'UPDATE PrinterIOSPOS SET PrinterId = " + PrinterID + " WHERE PrinterID > $printerID';
      await db.rawQuery(query);
      printerID++;
    }
    final int maxID = await checkMaxPrinterID();
    query =
        "UPDATE sqlite_sequence SET seq = $maxID WHERE name = 'PrinterIOSPOS'";
    await db.rawQuery(query);
  }

  @override
  Future<PrinterModel?> getPrinterDetails(int printerID) async {
    Database db = await dbHelper.database;
    String query = 'SELECT * FROM PrinterIOSPOS WHERE PrinterID = $printerID';
    List<Map<String, dynamic>> data = await db.rawQuery(query);
    if (data.isNotEmpty) {
      return PrinterModel.fromJson(data[0]);
    }
  }

  @override
  Future<List<List<String>>> getPrinterSet() async {
    Database db = await dbHelper.database;
    String query = 'SELECT * FROM PrinterSet';
    List<Map<String, dynamic>> data = await db.rawQuery(query);
    return mapListToString2D(data);
  }

  @override
  Future<List<PrinterModel>> getPrinters() async {
    Database db = await dbHelper.database;
    String query = 'SELECT * FROM PrinterIOSPOS';
    List<Map<String, dynamic>> data = await db.rawQuery(query);
    return data.map((e) => PrinterModel.fromJson(e)).toList();
  }

  @override
  Future<void> updatePrinter(PrinterModel printer) async {
    String query =
        "UPDATE PrinterIOSPOS SET PrinterType = '${printer.printerType}', PrinterDeviceName = '${printer.printerDeviceName}', Address = '${printer.address}', Port = '${printer.port}', InterfaceType = ${printer.interfaceType} WHERE PrinterID = ${printer.printerID}";
    Database db = await dbHelper.database;
    await db.rawQuery(query);
  }

  @override
  Future<List<PrinterSupportModel>> getSupportPrinters() async {
    Database db = await dbHelper.database;
    String query = 'SELECT * FROM PrinterSupportList';
    List<Map<String, dynamic>> data = await db.rawQuery(query);
    return data.map((e) => PrinterSupportModel.fromJson(e)).toList();
  }
}
