import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'promo_controller.dart';
import 'promo_state.dart';

final StateNotifierProvider<PromotController, PromoState> promoProvider =
    StateNotifierProvider((ref) {
  return GetIt.I<PromotController>();
});
