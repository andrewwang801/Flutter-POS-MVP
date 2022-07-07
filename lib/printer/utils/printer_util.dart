import 'dart:io';

class PrinterUtil {
  PrinterUtil() {
    init();
  }

  void init() {}

  void printerAddtoList(
      String modelName, String logicName, int type, String address, int port) {}

  void connect(String printerName) {}

  bool checkConnection() {
    return false;
  }

  void print(int status, int printSNo, String printData) {
    if (status == 1) {
      testPrint(printData);
    } else if (status == 2) {
      if (Platform.isAndroid) {
      } else if (Platform.isIOS) {}
    } else if (status == 3) {
      printBill(printSNo, printData);
    } else if (status == 4) {
      if (Platform.isAndroid) {
      } else if (Platform.isIOS) {}
    } else if (status == 5) {
      printOpenBill(printSNo);
    }
  }

  void testPrint(String textPrint) {}

  void printBill(int printSNo, String printStatus) {}

  void printOpenBill(int printSNo) {}
}
