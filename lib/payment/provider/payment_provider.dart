import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/payment/provider/payment_state.dart';

import 'payment_state_notifier.dart';

final paymentProvider =
    StateNotifierProvider<PaymentStateNotifer, PaymentState>((ref) {
  return GetIt.I<PaymentStateNotifer>();
});
