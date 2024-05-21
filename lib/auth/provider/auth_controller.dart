import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/GlobalConfig.dart';
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
        state = AuthSuccessState();
      } else {
        state = AuthErrorState('Auth failed');
      }
    } catch (_e) {
      state = AuthErrorState(_e.toString());
    }
  }
}
