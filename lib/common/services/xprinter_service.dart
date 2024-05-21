import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:injectable/injectable.dart';
import '../../common/utils/strings_util.dart';
import '../../common/utils/type_util.dart';
import '../../payment/repository/i_payment_repository.dart';
import 'iprinter_service.dart';
// import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

@injectable
class XPrinterService extends IPrinterService with StringUtil, TypeUtil {
  XPrinterService({required this.paymentRepository});
  final IPaymentRepository paymentRepository;

  late NetworkPrinter printer;
  late PosPrintResult res;

  @override
  Future<PosPrintResult> connect(String ipAddr, int port) async {
    const PaperSize paper = PaperSize.mm80;
    final CapabilityProfile profile = await CapabilityProfile.load();
    printer = NetworkPrinter(paper, profile);

    res = await printer.connect(ipAddr, port: port);

    if (res == PosPrintResult.success) {
      return res;
      // print('connection success');
    } else {
      throw Exception(res.msg);
      // print('Print result: ${res.msg}');
    }
  }

  @override
  void disconnect() {
    printer.disconnect(delayMs: 100);
  }

  @override
  bool checkConnection() {
    return res == PosPrintResult.success;
  }

  @override
  String getIPAddr() {
    return printer.host ?? '';
  }

  void printerAddtoList(
      String modelName, String logicName, int type, String address, int port) {}

  @override
  Future<void> print(String printData) async {
    printer.text(printData);
    printer.feed(2);
    printer.cut();
  }
}
