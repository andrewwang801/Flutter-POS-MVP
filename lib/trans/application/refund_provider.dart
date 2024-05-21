import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../print/provider/print_controller.dart';
import '../../print/provider/print_provider.dart';
import 'refund_controller.dart';
import 'refund_state.dart';

final StateNotifierProvider<RefundController, RefundState> refundProvider =
    StateNotifierProvider<RefundController, RefundState>(
        (StateNotifierProviderRef<RefundController, RefundState> ref) {
  return GetIt.I<RefundController>(param1: GetIt.I<PrintController>());
});
