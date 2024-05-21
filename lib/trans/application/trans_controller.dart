import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../../home/repository/order/i_order_repository.dart';
import '../../payment/repository/i_payment_repository.dart';
import '../../print/provider/print_controller.dart';
import '../data/trans_sales_data_model.dart';
import '../domain/trans_local_repository.dart';
import 'trans_state.dart';

@Injectable()
class TransController extends StateNotifier<TransState> {
  TransController(
      this.transRepository, this.orderRepository, this.paymentRepository,
      {@factoryParam required this.printController})
      : super(TransState(workable: Workable.initial));

  final TransLocalRepository transRepository;
  final PrintController printController;
  final IOrderRepository orderRepository;
  final IPaymentRepository paymentRepository;

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
          rcpt = transSalesData.rcptNo ?? '';
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

  Future<void> openTrans(int tempSNo, int tempSplit, int tempCover,
      String tempTableNo, String tempRcptNo) async {
    // bool showBFOC = false,
    //     showDisc = false,
    //     showFunc = false,
    //     showPromo = false;
    double gTotal = 0.0;
    double sTotal = 0.0;
    List<String> printArr = <String>[];
    try {
      if (GlobalConfig.checkItemOrder > 0) {
        List<double> paymentData = await paymentRepository.getAmountOrder(
            GlobalConfig.salesNo,
            GlobalConfig.splitNo,
            GlobalConfig.tableNo.toInt(),
            POSDefault.taxInclusive);
        if (paymentData.length > 2) {
          gTotal = paymentData[0];
          sTotal = paymentData[2];
        }
        if (POSDefault.printKPWhenHoldTable) {
          List<List<String>> scArray = await printController.printRepository
              .getKPSalesCategory(GlobalConfig.salesNo, GlobalConfig.splitNo,
                  'HeldItems', 'KPStatus', 0);
          if (scArray.isNotEmpty) {
            await printController.kpPrinting(
                GlobalConfig.salesNo,
                GlobalConfig.splitNo,
                GlobalConfig.tableNo,
                'HeldItems',
                'KpStatus',
                0,
                0);
            if (POSDtls.blnKPPrintMaster) {
              await printController.masterKPPrint(
                  GlobalConfig.salesNo,
                  GlobalConfig.splitNo,
                  GlobalConfig.tableNo,
                  'HeldItems',
                  'KpStatus',
                  0,
                  0);
            }
            for (String printData in printArr) {
              await printController.doPrint(2, 0, printData);
            }
            printArr.clear();
            await printController.printRepository
                .updateKPPrintItem(GlobalConfig.salesNo, GlobalConfig.splitNo);
          }
        }
        // update hold item
        await orderRepository.updateHoldItem(GlobalConfig.salesNo,
            GlobalConfig.salesNo, GlobalConfig.tableNo, sTotal, gTotal, 0);
      } else {
        // update hold item
        await orderRepository.updateHoldItem(GlobalConfig.salesNo,
            GlobalConfig.salesNo, GlobalConfig.tableNo, sTotal, 0, 0);
      }

      GlobalConfig.tableNo = tempTableNo;
      GlobalConfig.rcptNo = tempRcptNo;
      GlobalConfig.salesNo = tempSNo;
      GlobalConfig.cover = tempCover;
      POSDtls.categoryID = POSDtls.defCtgryID;

      await orderRepository.updateOpenHoldTrans(
          GlobalConfig.salesNo, GlobalConfig.splitNo, GlobalConfig.tableNo);

      state =
          state.copyWith(workable: Workable.loading, operation: Operation.OPEN);
    } on OperationFailedException catch (e) {
      state = state.copyWith(failiure: Failiure(errMsg: e.errDetailMsg));
    } catch (e) {
      state = state.copyWith(failiure: Failiure(errMsg: e.toString()));
    }
  }

  Future<void> reprintBill(
      String transMode, int salesNo, String tableStatus) async {
    try {
      if (transMode == 'RFND') {
        await printController.reprintBillNotify(salesNo, 'Refund');
      } else if (transMode == 'V') {
        await printController.reprintBillNotify(salesNo, 'Void Tables');
      } else {
        await printController.reprintBillNotify(salesNo, tableStatus);
      }
    } on OperationFailedException catch (e) {
      state = state.copyWith(failiure: Failiure(errMsg: e.errDetailMsg));
    } catch (e) {
      state = state.copyWith(failiure: Failiure(errMsg: e.toString()));
    }
  }
}
