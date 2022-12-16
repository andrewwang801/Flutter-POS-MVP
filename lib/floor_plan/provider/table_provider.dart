import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/print/provider/print_provider.dart';

import 'table_controller.dart';
import 'table_state.dart';

final StateNotifierProvider<TableController, TableState> tableProvider =
    StateNotifierProvider(
        (StateNotifierProviderRef<TableController, TableState> ref) {
  return GetIt.I<TableController>(param1: ref.read(printProvider.notifier));
});
