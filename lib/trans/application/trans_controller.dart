import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/GlobalConfig.dart';
import '../data/trans_model.dart';
import '../data/trans_sales_data_model.dart';
import '../domain/trans_local_repository.dart';
import 'trans_state.dart';

@Injectable()
class TransController extends StateNotifier<TransState> {
  TransController(this.transRepository)
      : super(TransState(workable: Workable.initial));

  final TransLocalRepository transRepository;

  Future<void> fetchTransData(
      String date1, String date2, String time1, String time2) async {
    state = TransState(workable: Workable.loading);

    try {
      List<TransSalesData> transArrayOpen =
          await transRepository.getOpenSalesData(date1, date2, time1, time2);
      List<TransSalesData> transArrayClosed =
          await transRepository.getCloseSalesData(date1, date2, time1, time2);

      state = TransState(
          workable: Workable.ready,
          transData: TransData(
              transArrayOpened: transArrayOpen,
              transArrayClosed: transArrayClosed));
    } catch (_e) {
      state = state.copyWith(
          failiure: Failiure(errMsg: _e.toString()),
          workable: Workable.failure);
    }
  }

  Future<void> kitchenReprint(List<TransSalesData> transArray, int salesNo,
      String salesStatue, TransSalesData transSalesData) async {
    if (transArray.isNotEmpty) {
      bool opReprintPermission = await transRepository.checkOperatorReprint();
      String rcpt = '';
      int splitNo = 0;
      String tableNo = '';
      if (opReprintPermission) {
        if (salesNo == 0) {
          rcpt = transSalesData.rcptNo;
          salesNo = transSalesData.salesNo;
          splitNo = transSalesData.splitNo;
          tableNo = transSalesData.tableNo;
        }

        List<List<String>> dataArray = await transRepository.getDataSales(
            salesNo, splitNo, tableNo, salesStatue);
        if (tableNo == GlobalConfig.tableNo &&
            salesStatue == 'Open Tables' &&
            dataArray.isNotEmpty) {
          state = state.copyWith(
              failiure: Failiure(
                  errMsg:
                      'Reprint kitchen receipt Failed!, Please transfer current sales to a Table or Settle current sales'));
        } else {
          state = state.copyWith(operation: Operation.KITCHEN_REPRINT);
        }
      } else {
        state = state.copyWith(
            failiure: Failiure(
                errMsg:
                    'Reprint kitchen receipt Failed!, Not enough Permission to re-print kitchen receipt'));
      }
    } else {
      state = state.copyWith(
          failiure: Failiure(
              errMsg:
                  'Reprint kitchen receipt Failed!, There is not data to re-print kitchen receipt'));
    }
  }

  Future<void> refund(int salesNo, int splitNo, String rcptNo) async {
    try {
      await transRepository.checkRefundFunction(
          salesNo, splitNo, POSDtls.strSalesAreaID, POSDtls.deviceNo, rcptNo);

      state = state.copyWith(operation: Operation.REFUND);
    } on OperationFailedException catch (e) {
      state = state.copyWith(failiure: Failiure(errMsg: e.errDetailMsg));
    } catch (e) {
      state = state.copyWith(failiure: Failiure(errMsg: e.toString()));
    }
  }
}
