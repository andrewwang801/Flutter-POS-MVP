import 'package:get/get_utils/get_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:raptorpos/common/services/xprinter_service.dart';

import 'iprinter_service.dart';

@singleton
class PrinterManager {
  List<IPrinterService> _printers = <IPrinterService>[];

  IPrinterService createPrinter(int type) {
    IPrinterService printerService;
    switch (type) {
      case 0:
        XPrinterService xPrinterService = GetIt.I<XPrinterService>();
        printerService = xPrinterService;
        break;
      default:
        XPrinterService xPrinterService = GetIt.I<XPrinterService>();
        printerService = xPrinterService;
        break;
    }
    return printerService;
  }

  List<IPrinterService> getPrinters() {
    return _printers;
  }

  IPrinterService? get(int index) {
    if (_printers.length > index) {
      return _printers[index];
    }
  }

  void add(IPrinterService printer) {
    _printers.add(printer);
  }

  IPrinterService? getPrinterByIP(String addr) {
    final IPrinterService? printerService = getPrinters()
        .firstWhereOrNull((element) => element.getIPAddr() == addr);
    return printerService;
  }

  void remove(int index) {
    _printers.removeAt(index);
  }

  void removeByIP(String addr) {
    getPrinters().removeWhere((element) => element.getIPAddr() == addr);
  }

  bool isConnected(String addr) {
    int index =
        getPrinters().indexWhere((element) => element.getIPAddr() == addr);
    return index != -1;
  }

  void clear() {
    _printers.clear();
  }

  Future<void> print(String printString) async {
    for (IPrinterService printer in _printers) {
      await printer.print(printString);
    }
  }
}
