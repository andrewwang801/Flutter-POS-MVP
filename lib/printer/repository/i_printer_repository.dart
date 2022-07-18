import '../model/printer_model.dart';
import '../model/printer_support_model.dart';

abstract class IPrinterRepository {
  Future<List<List<String>>> getPrinterSet();
  Future<List<PrinterModel>> getPrinters();
  Future<int> checkMaxPrinterID();
  Future<PrinterModel?> getPrinterDetails(int printerID);
  Future<void> addPrinter(PrinterModel printer);
  Future<void> updatePrinter(PrinterModel printer);
  Future<void> deletePrinter(int printerID);
  Future<List<PrinterSupportModel>> getSupportPrinters();
}
