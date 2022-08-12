import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../../print/provider/print_controller.dart';
import '../domain/trans_local_repository.dart';
import 'kitchen_state.dart';

@Injectable()
class KitchenReprintController extends StateNotifier<KitchenState> {
  KitchenReprintController(this.transRepository,
      {@factoryParam required this.printController})
      : super(KitchenState(workable: Workable.initial));

  final TransLocalRepository transRepository;
  final PrintController printController;

  Future<void> fetchReprintData(
      int salesNo, int splitNo, String tableNo) async {
    state = KitchenState(workable: Workable.loading);
    try {
      final List<List<String>> reprintArray =
          await transRepository.reprintItem(salesNo, splitNo);

      state = KitchenState(
          workable: Workable.ready,
          kitchenData: KitchenData(reprintArray: reprintArray));
    } on OperationFailedException catch (e) {
      state = state.copyWith(
          workable: Workable.failure,
          failiure: Failiure(errMsg: e.errDetailMsg));
    } catch (_e) {
      state = state.copyWith(
          workable: Workable.failure,
          failiure: Failiure(errMsg: _e.toString()));
    }
  }

  Future<void> doKitchenReprint(int salesNo, int splitNo, String tableNo,
      List<String> sRefArray, List<String> iSeqNoArray) async {
    try {
      List<String> paramList = await transRepository.doReprintKitchenFunction(
          salesNo, splitNo, GlobalConfig.operatorNo, sRefArray, iSeqNoArray);

      if (paramList.isNotEmpty) {
        int cntCopy = paramList[0].toInt();
        int transID = paramList[1].toInt();
        String tblName = paramList[2];
        String kpTbleName = paramList[3];

        // reprintKitchenNotify
        await printController.reprintKitchenNotify(
            cntCopy, transID, tblName, kpTbleName, salesNo, splitNo, tableNo);

        sRefArray.clear();
        iSeqNoArray.clear();
        state = state.copyWith(workable: Workable.ready);
      }
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
