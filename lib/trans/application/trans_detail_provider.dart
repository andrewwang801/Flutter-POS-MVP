import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'trans_detail_controller.dart';
import 'trans_detail_state.dart';

final StateNotifierProvider<TransDetailController, TransDetailState>
    transDetailProvier =
    StateNotifierProvider<TransDetailController, TransDetailState>((ref) {
  return GetIt.I<TransDetailController>();
});
