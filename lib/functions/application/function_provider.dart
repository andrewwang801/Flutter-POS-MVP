import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/functions/application/function_controller.dart';

import 'function_state.dart';

final StateNotifierProvider<FunctionController, FunctionState>
    functionProvider = StateNotifierProvider((ref) {
  return GetIt.I<FunctionController>();
});
