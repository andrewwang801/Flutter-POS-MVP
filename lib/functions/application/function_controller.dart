import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/extension/workable.dart';
import '../../home/provider/order/order_state_notifier.dart';
import '../domain/function_local_repository.dart';
import '../model/function_model.dart';
import 'function_state.dart';

@Injectable()
class FunctionController extends StateNotifier<FunctionState> {
  FunctionController(this.repository,
      {@factoryParam required this.orderController})
      : super(FunctionState());

  final FunctionLocalRepository repository;
  final OrderStateNotifier orderController;

  Future<void> fetchFunctions() async {
    try {
      state = FunctionState(workable: Workable.loading);
      // do work
      final List<FunctionModel> functions = await repository.getFunctions();
      state = state.copyWith(
        workable: Workable.ready,
        data: FunctionData(functionList: functions),
      );
    } catch (e) {
      state = state.copyWith(
          workable: Workable.failure, failiure: Failiure(errMsg: e.toString()));
    }
  }

  Future<void> voidAllOrder() async {
    try {
      await orderController.voidAllOrder();
    } catch (e) {
      state = state.copyWith(failiure: Failiure(errMsg: e.toString()));
    }
  }
}
