import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/GlobalConfig.dart';
import '../../print/provider/print_controller.dart';
import '../domain/trans_local_repository.dart';
import 'refund_state.dart';

@Injectable()
class RefundController extends StateNotifier<RefundState> {
  RefundController(this.transRepository,
      {@factoryParam required this.printController})
      : super(RefundState(workable: Workable.initial));

  final TransLocalRepository transRepository;
  final PrintController printController;

  Future<void> fetchRefundList() async {
    try {
      state = state.copyWith(workable: Workable.loading);

      List<List<String>> refundArray = await transRepository.getRefundTypes();

      state = state.copyWith(
          workable: Workable.ready, data: RefundData(refundArray: refundArray));
    } on OperationFailedException catch (e) {
      state = state.copyWith(
          workable: Workable.failure,
          failiure: Failiure(errMsg: e.errDetailMsg));
    } catch (e) {
      state = state.copyWith(
          workable: Workable.failure, failiure: Failiure(errMsg: e.toString()));
    }
  }

  Future<void> doRefund(
    int salesNo,
    int splitNo,
    String rcptNo,
    int refundID,
  ) async {
    try {
      await transRepository.doRefundFunction(
          salesNo, splitNo, GlobalConfig.operatorNo, refundID, rcptNo);
      await printController.reprintBillNotify(salesNo, 'Refund');

      state = state.copyWith(workable: Workable.ready);
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
