import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'package:raptorpos/discount/application/discount_controller.dart';
import 'package:raptorpos/discount/application/discount_state.dart';

final StateNotifierProvider<DiscountController, DiscountState> discProvider =
    StateNotifierProvider((ref) {
  return GetIt.I<DiscountController>();
});
