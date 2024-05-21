import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'trans_controller.dart';
import 'trans_state.dart';

final StateNotifierProvider<TransController, TransState> transProvider =
    StateNotifierProvider<TransController, TransState>(
        (StateNotifierProviderRef<TransController, TransState> ref) {
  return GetIt.I<TransController>();
});
