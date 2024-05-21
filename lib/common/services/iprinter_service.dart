import 'package:esc_pos_printer/esc_pos_printer.dart';

abstract class IPrinterService {
  Future<PosPrintResult> connect(String ipAddr, int port);

  void disconnect();

  bool checkConnection();

  String getIPAddr();

  Future<void> print(String printData);
}
