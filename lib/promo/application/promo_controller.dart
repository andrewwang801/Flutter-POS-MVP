import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import '../../common/GlobalConfig.dart';
import '../../common/extension/workable.dart';
import '../domain/promotion_local_repository.dart';

import '../model/promotion_model.dart';
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

  Future<void> fetchPromotions() async {
    try {
      state = PromoState(workable: Workable.loading);

      final List<PromotionModel> promos =
          await promotionRepository.getPromotionData();
      state = state.copyWith(workable: Workable.ready, data: PromoData(promos));
    } catch (e) {
      state = state.copyWith(
          workable: Workable.failure, failiure: Failiure(errMsg: e.toString()));
    }
  }

  Future<void> applyPromo(int promoID, String promo, int operatorNo) async {
    try {
      if (operatorNo == 0) {
        operatorNo = GlobalConfig.operatorNo;
      }

      if (GlobalConfig.checkItemOrder == 0) {
        state = state.copyWith(
            failiure: Failiure(
                errMsg:
                    'Promotion - $promo Failed!\n No Item can be found to give promotion'));
      } else {
        await promotionRepository.applyPromotion(
            promoID, GlobalConfig.salesNo, GlobalConfig.splitNo, operatorNo);
      }
    } catch (e) {
      state = state.copyWith(failiure: Failiure(errMsg: e.toString()));
    }
  }
}
