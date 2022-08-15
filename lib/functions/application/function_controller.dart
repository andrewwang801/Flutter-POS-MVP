import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:raptorpos/functions/domain/function_local_repository.dart';

import '../model/function_model.dart';
import 'function_state.dart';

@Injectable()
class FunctionController extends StateNotifier<FunctionState> {
  FunctionController(this.repository) : super(FunctionState());

  final FunctionLocalRepository repository;

  Future<void> fetchFunctions() async {
    try {
      state = state.copyWith(workable: Workable.loading);
      // do work
      final List<FunctionModel> functions = await repository.getFunctions();
      state = state.copyWith(
          workable: Workable.ready,
          data: FunctionData(functionList: functions));
    } catch (e) {
      state = state.copyWith(
          workable: Workable.failure, failiure: Failiure(errMsg: e.toString()));
    }
  }
}
