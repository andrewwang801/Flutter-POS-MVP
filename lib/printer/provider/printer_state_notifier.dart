import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import '../../common/services/iprinter_service.dart';

import '../../common/services/printer_manager.dart';
import '../model/printer_model.dart';
import '../model/printer_support_model.dart';
import '../repository/i_printer_repository.dart';
import 'printer_state.dart';

@Injectable()
class PrinterStateNotifier extends StateNotifier<PrinterState> {
  PrinterStateNotifier(this.printerRepository, this.printerManager)
      : super(PrinterInitialState());

  final IPrinterRepository printerRepository;
  final PrinterManager printerManager;

  Future<void> fetchPrinters() async {
    state = PrinterLoadingState();
    try {
      final List<PrinterModel> printers = await printerRepository.getPrinters();
      final List<PrinterSupportModel> supportPrinters =
          await printerRepository.getSupportPrinters();

      state = PrinterSuccessState(
          printers: printers,
          printerSupportList: supportPrinters,
          operation: OPERATION.FETCH);
    } catch (e) {
      state = PrinterErrorState(e.toString());
    }
  }

  Future<void> addPrinter(PrinterModel printer) async {
    try {
      if (state is PrinterSuccessState) {
        PrinterSuccessState prevState = state as PrinterSuccessState;
        state = prevState.copyWith(
            printers: <PrinterModel>[...prevState.printers, printer],
            operation: OPERATION.ADD);
        await printerRepository.addPrinter(printer);
        state = prevState.copyWith(
            printers: <PrinterModel>[...prevState.printers, printer],
            operation: OPERATION.ADD);
      }
    } catch (e) {
      state = PrinterErrorState(e.toString());
    }
  }

  Future<void> updatePrinter(PrinterModel printer) async {
    try {
      if (state is PrinterSuccessState) {
        final PrinterSuccessState prevState = state as PrinterSuccessState;
        final int targetPrinterID = prevState.printers.indexWhere(
            (PrinterModel element) => element.printerID == printer.printerID);
        prevState.printers.removeAt(targetPrinterID);
        prevState.printers.insert(targetPrinterID, printer);
        state = prevState.copyWith(
            printers: prevState.printers, operation: OPERATION.UPDATE);
        await printerRepository.updatePrinter(printer);
      }
    } catch (e) {
      state = PrinterErrorState(e.toString());
    }
  }

  Future<void> deletePrinter(int printerID) async {
    try {
      if (state is PrinterSuccessState) {
        final PrinterSuccessState prevState = state as PrinterSuccessState;
        List<PrinterModel> newPrinters = prevState.printers
            .where((element) => element.printerID != printerID)
            .toList();
        state = prevState.copyWith(
            printers: newPrinters, operation: OPERATION.UPDATE);
        await printerRepository.deletePrinter(printerID);
      }
    } catch (e) {
      state = PrinterErrorState(e.toString());
    }
  }

  Future<void> connectPrinter(PrinterModel printer) async {
    final IPrinterService printerService = printerManager.createPrinter(0);
    try {
      final PosPrintResult res =
          await printerService.connect(printer.address, printer.port);
      if (res == PosPrintResult.success) {
        printerManager.add(printerService);
        if (state is PrinterSuccessState) {
          final PrinterSuccessState prevState = state as PrinterSuccessState;
          state = prevState.copyWith(operation: OPERATION.CONNECT_SUCCESS);
        }
      } else {
        if (state is PrinterSuccessState) {
          final PrinterSuccessState prevState = state as PrinterSuccessState;
          state = prevState.copyWith(operation: OPERATION.CONNECT_FAIL);
        }
      }
    } catch (e) {
      state = PrinterErrorState(e.toString());
    }
  }

  Future<void> disconnectPrinter(PrinterModel printer) async {
    final IPrinterService? printerService =
        printerManager.getPrinterByIP(printer.address);
    try {
      printerService?.disconnect();
      printerManager.removeByIP(printer.address);
      if (state is PrinterSuccessState) {
        final PrinterSuccessState prevState = state as PrinterSuccessState;
        state = prevState.copyWith(operation: OPERATION.DISCONNECT_SUCCESS);
      }
    } catch (e) {
      state = PrinterErrorState(e.toString());
    }
  }
}
