import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/int_extension.dart';
import '../../common/utils/type_util.dart';
import '../model/operator_model.dart';
import '../repository/i_operator_repository.dart';
import 'auth_state.dart';

@Injectable()
class AuthController extends StateNotifier<AuthState> {
  AuthController(this.operatorRepository) : super(AuthInitialState());
  final IOperatorRepository operatorRepository;

  Future<void> pinSingIn(String pin) async {
    try {
      final OperatorModel? operator =
          await operatorRepository.getOperators(pin);
      if (operator != null) {
        GlobalConfig.operator = operator;
        GlobalConfig.operatorName = operator.OperatorName;
        GlobalConfig.MaxVoids = operator.MaxVoids;
        GlobalConfig.AllVoid = operator.AllVoid.toBool();
        GlobalConfig.MaxVoidsPerSale = operator.MaxVoidsPerSale;
        GlobalConfig.BillFOC = operator.FreeOfCharge.toBool();
        GlobalConfig.VoidPromotion = operator.VoidPromotion.toBool();
        GlobalConfig.opPromotion = operator.op_promotion.toBool();
        GlobalConfig.XReport = operator.XReport.toBool();
        GlobalConfig.ZReport = operator.ZReport.toBool();
        GlobalConfig.VoidPayments = operator.VoidPayments.toBool();
        GlobalConfig.ItemFOC = operator.ItemFOC.toBool();
        GlobalConfig.OpPrinterSetting = operator.opPrinterSetting.toBool();

        state = AuthSuccessState();
      } else {
        state = AuthErrorState('Auth failed');
      }
    } catch (_e) {
      state = AuthErrorState(_e.toString());
    }
  }
}
