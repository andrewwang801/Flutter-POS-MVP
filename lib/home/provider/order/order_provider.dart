import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/home/provider/order/order_state_notifier.dart';

final orderProvoder = StateNotifierProvider<OrderStateNotifier, OrderState>(
    (ref) => GetIt.I<OrderStateNotifier>());
