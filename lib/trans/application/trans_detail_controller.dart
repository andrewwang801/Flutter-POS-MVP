import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../domain/trans_local_repository.dart';
import 'trans_detail_state.dart';

@Injectable()
class TransDetailController extends StateNotifier<TransDetailState> {
  TransDetailController(this.transRepository)
      : super(TransDetailState(workable: Workable.initial));

  final TransLocalRepository transRepository;

  Future<void> fetchData(
      int salesNo, int splitNo, String tableNo, String tableStatus) async {
    try {
      state =
          state.copyWith(workable: Workable.loading, operation: Operation.NONE);
      // work
      final List<List<String>> transDetail = await transRepository.getDataSales(
          salesNo, splitNo, tableNo, tableStatus);
      final List<List<String>> billAdjArr =
          await transRepository.getMediaData();

      state = state.copyWith(
          workable: Workable.ready,
          data: TransDetailData(
              transDetail: transDetail, billAdjArray: billAdjArr));
    } on OperationFailedException catch (e) {
      state = state.copyWith(
          workable: Workable.failure,
          failiure: Failiure(errMsg: e.errDetailMsg));
    } catch (e) {
      state = state.copyWith(
          workable: Workable.failure, failiure: Failiure(errMsg: e.toString()));
    }
  }

  Future<void> doBillAdjust(
      String mediaName,
      int funcId,
      int subFuncId,
      int salesNo,
      int splitNo,
      int salesRef,
      String fMedia,
      String rcptNo,
      double itemAmount) async {
    try {
      state =
          state.copyWith(workable: Workable.loading, operation: Operation.NONE);

      await transRepository.billAdjustFunction(mediaName, funcId, subFuncId,
          salesNo, splitNo, salesRef, fMedia, rcptNo, itemAmount);

      state = state.copyWith(
          workable: Workable.ready, operation: Operation.BILL_ADJUST);
    } on OperationFailedException catch (e) {
      state = state.copyWith(
          workable: Workable.failure,
          failiure: Failiure(errMsg: e.errDetailMsg));
    } catch (e) {
      state = state.copyWith(
          workable: Workable.failure, failiure: Failiure(errMsg: e.toString()));
    }
  }

  Future<void> checkBillAdj() async {
    try {
      state =
          state.copyWith(workable: Workable.loading, operation: Operation.NONE);

      await transRepository.checkBillAdj();

      state = state.copyWith(
          workable: Workable.ready, operation: Operation.CHECK_BILL);
    } on OperationFailedException catch (e) {
      state = state.copyWith(
          workable: Workable.failure,
          failiure: Failiure(errMsg: e.errDetailMsg));
    } catch (e) {
      state = state.copyWith(
          workable: Workable.failure, failiure: Failiure(errMsg: e.toString()));
    }
  }
}
