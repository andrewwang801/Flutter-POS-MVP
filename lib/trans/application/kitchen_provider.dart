import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../print/provider/print_controller.dart';
import '../../print/provider/print_provider.dart';
import 'kitchen_reprint_controller.dart';
import 'kitchen_state.dart';

final StateNotifierProvider<KitchenReprintController, KitchenState>
    kitchenProvider =
    StateNotifierProvider<KitchenReprintController, KitchenState>(
        (StateNotifierProviderRef<KitchenReprintController, KitchenState> ref) {
  return GetIt.I<KitchenReprintController>(param1: GetIt.I<PrintController>());
});
