import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../../common/utils/datetime_util.dart';
import '../../common/utils/type_util.dart';
import '../../home/repository/order/i_order_repository.dart';
import '../model/table_data_model.dart';
import '../repository/i_tablemangement_repository.dart';
import 'table_state.dart';

@Injectable()
class TableController extends StateNotifier<TableState>
    with DateTimeUtil, TypeUtil {
  TableController(this.tableRepository, this.orderRepository)
      : super(TableInitialState());

  final ITableMangementRepository tableRepository;
  final IOrderRepository orderRepository;

  Future<void> fetchData() async {
    try {
      List<TableDataModel> tableList =
          await tableRepository.getTableLayoutData(1);
      state = TableSuccessState(
          tableList: tableList, notify_type: NOTIFY_TYPE.NONE);
    } catch (_e) {
      state = TableErrorState(_e.toString());
    }
  }

  Future<void> selectTable(String tableNo) async {
    try {
      GlobalConfig.tableNo = tableNo;
      List<List<String>> tableList =
          await orderRepository.getIndexOrder(tableNo);
      int checkTableOpen = tableList.length;
      if (checkTableOpen == 0) {
        if (POSDtls.forceCover) {
          GlobalConfig.CoverView = 1;
          if (state is TableSuccessState) {
            TableSuccessState prevState = state as TableSuccessState;
            state = prevState.copyWith(notify_type: NOTIFY_TYPE.SHOW_COVER);
          }
        } else {
          GlobalConfig.cover = 1;
          await openTable(POSDtls.deviceNo, GlobalConfig.operatorNo,
              GlobalConfig.tableNo, GlobalConfig.cover);
          if (state is TableSuccessState) {
            TableSuccessState prevState = state as TableSuccessState;
            state = prevState.copyWith(notify_type: NOTIFY_TYPE.GOTO_MAIN);
          }
        }
      } else {
        if (state is TableSuccessState) {
          TableSuccessState prevState = state as TableSuccessState;
          state = prevState.copyWith(notify_type: NOTIFY_TYPE.GOTO_MAIN);
        }
      }
    } catch (_e) {
      if (state is TableSuccessState) {
        TableSuccessState prevState = state as TableSuccessState;
        state = prevState.copyWith(notify_type: NOTIFY_TYPE.COVER_SELECT_ERROR);
      } else {
        state = TableErrorState(_e.toString());
      }
    }
  }

  Future<void> selectCover(int cover) async {
    try {
      GlobalConfig.cover = cover;
      await openTable(POSDtls.deviceNo, GlobalConfig.operatorNo,
          GlobalConfig.tableNo, GlobalConfig.cover);
      if (state is TableSuccessState) {
        TableSuccessState prevState = state as TableSuccessState;
        state = prevState.copyWith(notify_type: NOTIFY_TYPE.GOTO_MAIN);
      }
    } catch (_e) {
      if (state is TableSuccessState) {
        TableSuccessState prevState = state as TableSuccessState;
        state = prevState.copyWith(notify_type: NOTIFY_TYPE.COVER_SELECT_ERROR);
      } else {
        state = TableErrorState(_e.toString());
      }
    }
  }

  Future<List<String>> getReceiptNumber(
      int salesOnTmpServer, String deviceNo) async {
    String year = currentDateTime('yy');
    String dateTIme = currentDateTime('yyyy-MM-dd HH:mm:ss.0');

    String nxtRcptNo = '000000000000';
    String msgBox = '';
    int maxRcptNo = 0;
    String rcptCtrlDate = '';
    String rcptHdr = '';
    String tempRcptNo = '';
    int flag = 0;

    if (salesOnTmpServer == 0) {
      List<List<String>> rcptNoList = await tableRepository.getRcptNo();
      if (rcptNoList.isNotEmpty) {
        nxtRcptNo = rcptNoList[0][0];
        rcptCtrlDate = rcptNoList[0][1];
        String headerRcpt = rcptHdr.substring(1);

        if (year == headerRcpt) {
          maxRcptNo = nxtRcptNo.substring(3).toInt();
          tempRcptNo = nxtRcptNo.substring(0, 3);
        } else {
          maxRcptNo = 0;
          tempRcptNo = nxtRcptNo.substring(0, 1) + year;
          await tableRepository.updateRcptNoCtrl(tempRcptNo, '', 1);
        }
      } else {
        tempRcptNo = 'A$year';
        maxRcptNo = 0;
        await tableRepository.updateRcptNoCtrl(tempRcptNo, dateTIme, 2);
      }
      if (maxRcptNo == 999999998) {
        msgBox =
            'Please change the receipt header to next alphabet before you settle next bill';
      } else if (maxRcptNo == 999999999) {
        msgBox = 'Please change the receipt header to next alphabet';
      } else {
        maxRcptNo = 1000000001 + maxRcptNo;
        String rcptNo = maxRcptNo.toString();
        String srcptNo = rcptNo.substring(1);

        nxtRcptNo = tempRcptNo + srcptNo;
        await tableRepository.updateRcptNoCtrl(nxtRcptNo, '', 3);
      }
    } else {
      tempRcptNo = deviceNo.substring(4) +
          dateTIme.substring(0, 2) +
          dateTIme.substring(2, 4) +
          year;
      flag = 0;
      List<List<String>> rcptNoList = await tableRepository.getRcptNo();
      if (rcptNoList.isNotEmpty) {
        nxtRcptNo = rcptNoList[0][0];
        rcptCtrlDate = rcptNoList[0][1];
        rcptHdr = rcptNoList[0][2];

        if (tempRcptNo == nxtRcptNo.substring(0, 8)) {
          String rcptr = nxtRcptNo.substring(8);
          maxRcptNo = rcptr.toInt();
        } else {
          maxRcptNo = 0;
        }
      } else {
        flag = 1;
        maxRcptNo = 0;
      }

      if (maxRcptNo == 9998) {
        msgBox = 'Please download sales to server before you settle next bill';
      } else if (maxRcptNo == 9999) {
        msgBox = 'Please download sales to server';
      } else {
        maxRcptNo = 10001 + maxRcptNo;
        String rcptNo = maxRcptNo.toString();
        String srcptNo = rcptNo.substring(1);
        nxtRcptNo = tempRcptNo + srcptNo;

        if (flag == 1) {
          await tableRepository.updateRcptNoCtrl(nxtRcptNo, '', 4);
        } else {
          await tableRepository.updateRcptNoCtrl(nxtRcptNo, '', 3);
        }
      }
    }
    final List<String> rcptList = <String>[nxtRcptNo, msgBox];
    return rcptList;
  }

  Future<int> getSalesNumber() async {
    int salesNo = await tableRepository.getSNoCtrl();
    int nextSNo = salesNo + 1;

    await tableRepository.updateSalesNo(nextSNo);
    salesNo = await tableRepository.getSNoCtrl();
    return salesNo;
  }

  Future<int> nextSalesNumber() async {
    int nextSNo = 0;
    for (int i = 0; i < 5; i++) {
      int sNo = await getSalesNumber();
      if (sNo > 0) {
        nextSNo = sNo;
        break;
      }
    }
    return nextSNo;
  }

  Future<String> nextReceiptNumber() async {
    String nxtRcptNo = '';
    List<String> rcptNoData = <String>[];
    for (int i = 0; i < 5; i++) {
      rcptNoData = await getReceiptNumber(0, POSDtls.deviceNo);
      if (rcptNoData.isNotEmpty) {
        if (rcptNoData[1].isEmpty) {
          nxtRcptNo = rcptNoData[0];
        } else {
          state = TableErrorState('Receipt Header Full');
        }
      }
      break;
    }
    return nxtRcptNo;
  }

  Future<void> openTable(
      String posID, int operatorNo, String tableNo, int cover) async {
    final int maxCount = await tableRepository.getCountTableNo(tableNo);
    if (maxCount > 0) {
      String errorMsg =
          'Table $tableNo Already open. \n There is transaction in table $tableNo, Close transactation';
      state = TableErrorState(errorMsg);
    } else {
      String sDate = currentDateTime('yyyy-MM-dd');
      String sTime = currentDateTime('HH:mm:ss.0');

      GlobalConfig.salesNo = await nextSalesNumber();
      if (GlobalConfig.salesNo == 0) {
        GlobalConfig.rcptNo = await nextReceiptNumber();

        if (GlobalConfig.rcptNo == '') {
          state = TableErrorState('Open Table Failed \nReceipt Header Full');
        }
      } else {
        await tableRepository.insertHeldTable(
            posID,
            GlobalConfig.salesNo,
            GlobalConfig.salesNo,
            operatorNo,
            tableNo,
            cover,
            sDate,
            sTime,
            GlobalConfig.rcptNo,
            POSDtls.strSalesAreaID);
        await tableRepository.insertRcptDlts(GlobalConfig.rcptNo,
            GlobalConfig.salesNo, GlobalConfig.splitNo, tableNo, operatorNo);
        await tableRepository.updateTableStatus(tableNo);
      }
    }
  }
}
