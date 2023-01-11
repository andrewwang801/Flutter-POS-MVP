import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'package:raptorpos/discount/application/discount_controller.dart';
import 'package:raptorpos/discount/application/discount_state.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';

final StateNotifierProvider<DiscountController, DiscountState> discProvider =
    StateNotifierProvider((ref) {
  return GetIt.I<DiscountController>(param1: ref.read(orderProvoder.notifier));
});
