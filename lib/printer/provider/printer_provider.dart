import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'printer_state.dart';
import 'printer_state_notifier.dart';

final StateNotifierProvider<PrinterStateNotifier, PrinterState>
    printerProvider = StateNotifierProvider<PrinterStateNotifier, PrinterState>(
        (StateNotifierProviderRef<PrinterStateNotifier, PrinterState> ref) {
  return GetIt.I<PrinterStateNotifier>();
});
