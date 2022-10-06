import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../../common/utils/datetime_util.dart';
import '../../common/utils/type_util.dart';
import '../../home/repository/order/i_order_repository.dart';
import '../model/table_data_model.dart';
import '../repository/i_tablemangement_repository.dart';
import '../repository/local_tablemanagement_repository.dart';
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

  Future<void> resetGlobalConfig(String tableNo) async {
    GlobalConfig.tableNo = tableNo;
    final List<List<String>> tableList =
        await orderRepository.getIndexOrder(tableNo);
    GlobalConfig.checkTableOpen = tableList.length;
    if (tableList.isNotEmpty) {
      GlobalConfig.salesNo = tableList[0][0].toInt();
      GlobalConfig.splitNo = tableList[0][1].toInt();
      GlobalConfig.tableNo = tableList[0][2];
      GlobalConfig.cover = tableList[0][3].toInt();
      GlobalConfig.rcptNo = tableList[0][4];
    }
  }

  Future<void> tableNoNotify(String tableNo) async {
    try {
      GlobalConfig.tableNo = tableNo;
      if (GlobalConfig.tableNo != '0' && GlobalConfig.tableNo != '') {
        int tableOpened =
            await tableRepository.getCountTableNo(GlobalConfig.tableNo);
        if (tableOpened > 0) {
          List<List<String>> tblArray =
              await orderRepository.getIndexOrder(GlobalConfig.tableNo);
          GlobalConfig.checkTableOpen = tblArray.length;

          GlobalConfig.salesNo = dynamicToInt(tblArray[0][0]);
          GlobalConfig.splitNo = dynamicToInt(tblArray[0][1]);
          GlobalConfig.cover = dynamicToInt(tblArray[0][3]);
          GlobalConfig.rcptNo = tblArray[0][4];
          // TODO(Smith): Refresh Header Status
        } else {
          if (POSDtls.forceCover) {
            if (state is TableSuccessState) {
              TableSuccessState prevState = state as TableSuccessState;
              state = prevState.copyWith(notify_type: NOTIFY_TYPE.SHOW_COVER);
            }
          } else {
            GlobalConfig.cover = 1;
            await openTable(POSDtls.deviceNo, GlobalConfig.operatorNo,
                GlobalConfig.tableNo, GlobalConfig.cover);

            List<List<String>> tableData = await orderRepository
                .getIndexOrder(GlobalConfig.TableNoInt.toString());
            GlobalConfig.checkTableOpen = tableData.length;

            List<String> tempData = tableData[0];
            GlobalConfig.salesNo = dynamicToInt(tempData[0]);
            GlobalConfig.splitNo = dynamicToInt(tempData[1]);
            GlobalConfig.tableNo = GlobalConfig.TableNoInt.toString();
            GlobalConfig.cover = dynamicToInt(tempData[3]);
            GlobalConfig.rcptNo = tempData[4];

            await orderRepository.updateTableStatus(GlobalConfig.tableNo, 'O');
            // TODO(Smith): RefreshHeaderStatus
          }
        }
      }
    } catch (e) {
      state = TableErrorState(e.toString());
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
          await resetGlobalConfig(tableNo);
          if (state is TableSuccessState) {
            TableSuccessState prevState = state as TableSuccessState;
            state = prevState.copyWith(notify_type: NOTIFY_TYPE.GOTO_MAIN);
          }
        }
      } else {
        GlobalConfig.salesNo = tableList[0][0].toInt();
        GlobalConfig.splitNo = tableList[0][1].toInt();
        GlobalConfig.tableNo = tableList[0][2];
        GlobalConfig.cover = tableList[0][3].toInt();
        GlobalConfig.rcptNo = tableList[0][4];

        if (state is TableSuccessState) {
          TableSuccessState prevState = state as TableSuccessState;
          state = prevState.copyWith(notify_type: NOTIFY_TYPE.GOTO_MAIN);
        }
      }
    } catch (_e) {
      if (state is TableSuccessState) {
        TableSuccessState prevState = state as TableSuccessState;
        state = prevState.copyWith(
            notify_type: NOTIFY_TYPE.COVER_SELECT_ERROR, errMsg: _e.toString());
      } else {
        state = TableErrorState(_e.toString());
      }
    }
  }

  Future<void> selectCover(int cover) async {
    try {
      if (cover > 0 && cover < 250) {
        if (GlobalConfig.CoverView == 1) {
          GlobalConfig.cover = cover;
          await openTable(POSDtls.deviceNo, GlobalConfig.operatorNo,
              GlobalConfig.tableNo, GlobalConfig.cover);
          await resetGlobalConfig(GlobalConfig.tableNo);
          if (state is TableSuccessState) {
            TableSuccessState prevState = state as TableSuccessState;
            state = prevState.copyWith(notify_type: NOTIFY_TYPE.GOTO_MAIN);
          }
        } else {
          selectCoverQuickService(cover);
        }
      } else {
        state = TableErrorState('Please input cover between 0 and 250');
      }
    } catch (e) {
      if (state is TableSuccessState) {
        TableSuccessState prevState = state as TableSuccessState;
        state = prevState.copyWith(
            notify_type: NOTIFY_TYPE.COVER_SELECT_ERROR, errMsg: e.toString());
      } else {
        state = TableErrorState(e.toString());
      }
    }
  }

  Future<void> selectCoverQuickService(int cover) async {
    try {
      if (POSDtls.TBLManagement) {
        GlobalConfig.cover = cover;
        await orderRepository.updateCovers(GlobalConfig.salesNo,
            GlobalConfig.splitNo, GlobalConfig.tableNo, cover);
      } else {
        int tableOpened =
            await tableRepository.getCountTableNo(GlobalConfig.tableNo);
        GlobalConfig.cover = cover;
        if (tableOpened == 0) {
          await openTable(POSDtls.deviceNo, GlobalConfig.operatorNo,
              GlobalConfig.tableNo, GlobalConfig.cover);
          await resetGlobalConfig(GlobalConfig.tableNo);
          List<List<String>> tableList =
              await orderRepository.getIndexOrder(GlobalConfig.tableNo);
          GlobalConfig.checkTableOpen = tableList.length;
          if (tableList.isNotEmpty) {
            GlobalConfig.salesNo = tableList[0][0].toInt();
            GlobalConfig.splitNo = tableList[0][1].toInt();
            GlobalConfig.tableNo = GlobalConfig.TableNoInt.toString();
            GlobalConfig.cover = tableList[0][3].toInt();
            GlobalConfig.rcptNo = tableList[0][4];
            await tableRepository.updateTableStatus(GlobalConfig.tableNo, 'O');

            if (GlobalConfig.TableNoInt == POSDtls.AutoTblEnd) {
              GlobalConfig.TableNoInt = POSDtls.AutoTblStart;
            } else {
              GlobalConfig.TableNoInt++;
            }

            if (GlobalConfig.PLUNumber.isNotEmpty &&
                GlobalConfig.PLUName.isNotEmpty) {}
          }
        } else {
          GlobalConfig.cover = cover;
          await orderRepository.updateCovers(GlobalConfig.salesNo,
              GlobalConfig.splitNo, GlobalConfig.tableNo, cover);
        }
      }
      if (state is TableSuccessState) {
        TableSuccessState prevState = state as TableSuccessState;
        state = prevState.copyWith(notify_type: NOTIFY_TYPE.GOTO_MAIN);
      }
    } catch (_e) {
      if (state is TableSuccessState) {
        TableSuccessState prevState = state as TableSuccessState;
        state = prevState.copyWith(
            notify_type: NOTIFY_TYPE.COVER_SELECT_ERROR, errMsg: _e.toString());
      } else {
        state = TableErrorState(_e.toString());
      }
    }
  }

  Future<void> openTable(
      String posID, int operatorNo, String tableNo, int cover) async {
    try {
      final int maxCount = await tableRepository.getCountTableNo(tableNo);
      if (maxCount > 0) {
        String errorMsg =
            'Table $tableNo Already open. \n There is transaction in table $tableNo, Close transactation';
        state = TableErrorState(errorMsg);
      } else {
        String sDate = currentDateTime('yyyy-MM-dd');
        String sTime = currentDateTime('HH:mm:ss.0');

        GlobalConfig.salesNo = await tableRepository.nextSalesNumber();
        if (GlobalConfig.salesNo == 0) {
          state = TableErrorState(
              'Open Table Failed \nGenerate Sales Number Failed. Please try again');
        } else {
          GlobalConfig.rcptNo = await tableRepository.nextReceiptNumber();
          if (GlobalConfig.rcptNo == '') {
            state = TableErrorState('Open Table Failed \nReceipt Header Full');
          }
          await tableRepository.insertHeldTable(
              posID,
              GlobalConfig.salesNo,
              GlobalConfig.splitNo,
              operatorNo,
              tableNo,
              cover,
              sDate,
              sTime,
              GlobalConfig.rcptNo,
              POSDtls.strSalesAreaID);
          await tableRepository.insertRcptDlts(GlobalConfig.rcptNo,
              GlobalConfig.salesNo, GlobalConfig.splitNo, tableNo, operatorNo);
          await tableRepository.updateTableStatusToO(tableNo);
        }
      }
    } on ReceiptGenFailException catch (e) {
      state = TableErrorState(e.errMsg);
    }
  }
}
