import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/printer/provider/printer_state_notifier.dart';

import 'printer_state.dart';

final StateNotifierProvider<PrinterStateNotifier, PrinterState>
    printerProvider = StateNotifierProvider(
        (StateNotifierProviderRef<PrinterStateNotifier, PrinterState> ref) {
  return GetIt.I<PrinterStateNotifier>();
});
