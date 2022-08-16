import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import '../../common/GlobalConfig.dart';
import '../domain/promotion_local_repository.dart';

import 'promo_state.dart';

@Injectable()
class PromotController extends StateNotifier<PromoState> {
  PromotController(this.promotionRepository) : super(PromoState());

  final PromotionLocalRepository promotionRepository;

  Future<void> voidPromotion() async {
    try {
      if (GlobalConfig.VoidPromotion) {
        await promotionRepository.voidPromotion(GlobalConfig.salesNo,
            GlobalConfig.splitNo, GlobalConfig.operatorNo);
        // temp plu name... etc
      } else {
        state = state.copyWith(
            failiure:
                Failiure(errMsg: 'Not enough permission to void promotion'));
      }
    } catch (e) {
      state = state.copyWith(failiure: Failiure(errMsg: e.toString()));
    }
  }
}
