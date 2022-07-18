import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'print_state.dart';
import 'print_controller.dart';

final StateNotifierProvider<PrintController, PrintState> printProvider =
    StateNotifierProvider<PrintController, PrintState>(
        (StateNotifierProviderRef<PrintController, PrintState> ref) {
  return GetIt.instance<PrintController>();
});
