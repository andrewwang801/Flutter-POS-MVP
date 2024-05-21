import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import 'package:raptorpos/common/extension/string_extension.dart';
import 'package:raptorpos/common/extension/workable.dart';
import 'package:raptorpos/common/utils/datetime_util.dart';
import 'package:raptorpos/common/utils/type_util.dart';
import 'package:raptorpos/discount/application/discount_state.dart';
import 'package:raptorpos/discount/domain/discount_repository.dart';
import 'package:raptorpos/discount/model/discount_model.dart';
import 'package:raptorpos/home/provider/order/order_state_notifier.dart';

@Injectable()
class DiscountController extends StateNotifier<DiscountState>
    with DateTimeUtil, TypeUtil {
  DiscountController(this.repository,
      {@factoryParam required this.orderController})
      : super(DiscountState());

  final DiscountRepository repository;
  final OrderStateNotifier orderController;

  Future<void> fetchDiscs() async {
    try {
      state = DiscountState(workable: Workable.loading);

      final List<DiscountModel> discs = await repository.getDiscs();

      state =
          state.copyWith(workable: Workable.ready, data: DiscountData(discs));
    } catch (e) {
      state = state.copyWith(
          workable: Workable.failure, failiure: Failiure(errMsg: e.toString()));
    }
  }

  /// SP_HDS_DiscItem
  Future<void> discItem(
      int fnID,
      int sFnID,
      String discType,
      double fnParm,
      String fnTitle,
      String posID,
      int operatorNo,
      String tableNo,
      int salesNo,
      int splitNo,
      int salesRef,
      String PLUNo,
      double itemAmnt,
      String discRemarks) async {
    // Declare variables
    String strSQL;
    String errMsg;
    String resultMsg;
    String fnTitleCh;
    DateTime sDate;
    DateTime sTime;
    int PLUSalesRef;
    double discAmnt = 0.0;
    double discPercent = 0.0;
    int itemSeqNo;
    int sItemSeqNo;
    double avgCost;
    int rcpID;
    double qty;
    int pShift;
    bool blnForceSalesCategory;
    bool blnForceSalesCategoryShellband;
    int ctgryID;
    int memId;
    String loyaltyCardNo;

    // try {

    fnTitleCh = await repository.getChineseTitle(fnTitle, fnID, sFnID);

    // TODO(Smith: check later)
    sDate = DateTime.parse(currentDateTime('yyyy-MM-dd'));
    sTime = parse(currentDateTime('HH:mm:ss.0'));
    // sDate = currentDateTime('yyyy-MM-dd');
    // sTime = currentDateTime('HH:mm:ss');
    PLUSalesRef = salesRef;
    avgCost = 0;
    rcpID = 0;
    qty = 1;

    if (discType == 'DAmount') {
      discAmnt = fnParm;
      discPercent = 0;
    } else if (discType == 'DPercent') {
      discPercent = fnParm;
      discAmnt = (fnParm / 100) * itemAmnt;
    }

    itemSeqNo = await repository.getItemSeqNo(salesNo);
    switch (itemSeqNo) {
      case 100:
        itemSeqNo = 103;
        break;
      default:
        itemSeqNo += 1;
        break;
    }

    sItemSeqNo = await repository.getSItemSeqNo(
        salesNo: salesNo, splitNo: splitNo, salesRef: salesRef);

    List<String> data = await repository.getHeldTableData(salesNo, splitNo);
    memId = data[0].toInt();
    loyaltyCardNo = data[1];

    data = await repository.getPosDtlsDataItem(posID);
    ctgryID = data[0].toInt();
    pShift = data[1].toInt();
    blnForceSalesCategory = data[2].toBool();
    blnForceSalesCategoryShellband = data[3].toBool();

    // Get PShift, Start
    // Declare Vars
    bool hpyHr1;
    bool hpyHr2;
    bool hpyHr3;

    String hpyStart1;
    String hpyStart2;
    String hpyStart3;

    String hpyEnd1;
    String hpyEnd2;
    String hpyEnd3;

    String hpyShiftDay;
    String hpyShift1;
    String hpyShift2;
    String hpyShift3;

    int hpyPShift1;
    int hpyPShift2;
    int hpyPShift3;

    hpyShiftDay = DateFormat('EEEE').format(DateTime.now()).substring(0, 3);
    hpyShift1 = hpyShiftDay + '1';
    hpyShift2 = hpyShiftDay + '2';
    hpyShift3 = hpyShiftDay + '3';

    await repository.insertHDSHappyHourShift(
        posID: posID,
        salesNo: salesNo,
        splitNo: splitNo,
        hpyShift1: hpyShift1,
        hpyShift2: hpyShift2,
        hpyShift3: hpyShift3);

    data = await repository.getHDSHappyHourShift(
        posID: posID, salesNo: salesNo, splitNo: splitNo);

    hpyHr1 = data[0].toBool();
    hpyHr2 = data[1].toBool();
    hpyHr3 = data[2].toBool();
    hpyStart1 = data[3];
    hpyStart2 = data[4];
    hpyStart3 = data[5];
    hpyEnd1 = data[6];
    hpyEnd2 = data[7];
    hpyEnd3 = data[8];
    hpyPShift1 = data[9].toInt();
    hpyPShift2 = data[10].toInt();
    hpyPShift3 = data[11].toInt();

    if (sTime.compareTo(parse(hpyStart1)) >= 0 &&
        sTime.compareTo(parse(hpyEnd1)) <= 0 &&
        hpyHr1 == 1 &&
        hpyPShift1 != 0) {
      pShift = hpyPShift1;
    }

    if (sTime.compareTo(parse(hpyStart2)) >= 0 &&
        sTime.compareTo(parse(hpyEnd2)) <= 0 &&
        hpyHr2 == 1 &&
        hpyPShift2 != 0) {
      pShift = hpyPShift2;
    }

    if (sTime.compareTo(parse(hpyStart3)) >= 0 &&
        sTime.compareTo(parse(hpyEnd3)) <= 0 &&
        hpyHr3 == 1 &&
        hpyPShift3 != 0) {
      pShift = hpyPShift3;
    }

    if (blnForceSalesCategory && blnForceSalesCategoryShellband) {
      final shift = await repository.getSellPriceShift(ctgryID);
      if (shift != null) {
        pShift = shift;
      }
    }

    await repository.deleteHappyHourShift(
        posID: posID, salesNo: salesNo, splitNo: splitNo);
    // Get pShift, End

    await repository.updateHeldItemsDiscItem(
        discPercent: discPercent,
        discAmnt: discAmnt,
        fnTitle: fnTitle,
        discRemarks: discRemarks,
        salesNo: salesNo,
        splitNo: splitNo,
        sItemSeqNo: sItemSeqNo);

    await repository.addDiscItem(
        PLUSalesRef: PLUSalesRef,
        salesNo: salesNo,
        posID: posID,
        sDate: DateFormat('yyyy-MM-dd').format(sDate),
        sTime: DateFormat('HH:mm:ss.0').format(sTime),
        fnTitle: fnTitle,
        fnTitleCh: fnTitleCh,
        tableNo: tableNo,
        splitNo: splitNo,
        operatorNo: operatorNo,
        qty: qty,
        discAmnt: discAmnt,
        avgCost: avgCost,
        rcpID: rcpID,
        pShift: pShift,
        PLUNo: PLUNo,
        fnID: fnID,
        sFnID: sFnID,
        discPercent: discPercent,
        itemSeqNo: itemSeqNo,
        ctgryID: ctgryID,
        memId: memId,
        loyaltyCardNo: loyaltyCardNo,
        discRemarks: discRemarks);

    await repository.updateHeldTables(salesNo, splitNo);
    // } catch (e) {
    //   // send error msg "DiscItem Failed."
    //   state = state.copyWith(
    //       failiure: Failiure(errMsg: 'DiscItem Failed.'),
    //       workable: Workable.failure);
    // }
  }

  /// SP_HDS_DiscBill
  Future<void> discBill(
      int fnID,
      int sFnID,
      String discType,
      double fnParm,
      String fnTitle,
      bool coverBased,
      int intCoverBased,
      String posID,
      int operatorNo,
      String tableNo,
      int salesNo,
      int splitNo,
      double total,
      double disc,
      double surcharge,
      String discRemarks) async {
    // try {

    String strSQL;
    String errMsg;
    String resultMsg;
    String fnTitleCh;
    DateTime sDate;
    DateTime sTime;
    double discAmnt = 0.0;
    double discPercent = 0.0;
    int itemSeqNo;
    double avgCost;
    int rcpID;
    double qty;
    int pShift;
    bool blnForceSalesCategory;
    bool blnForceSalesCategorySellband;
    int ctgryID;
    int memId;
    String loyaltyCardNo;
    int nCover;
    bool PLU_BillDiscount;

    fnTitleCh = await repository.getChineseTitle(fnTitle, fnID, sFnID);

    sDate = DateTime.parse(currentDateTime('yyyy-MM-dd'));
    sTime = parse(currentDateTime('HH:mm:ss.0'));

    avgCost = 0;
    rcpID = 0;
    qty = 1;

    List<String> data = await repository.getHeldTableData(salesNo, splitNo);
    memId = data[0].toInt();
    loyaltyCardNo = data[1];
    nCover = data[2].toInt();

    itemSeqNo = await repository.getItemSeqNo(salesNo);
    switch (itemSeqNo) {
      case 100:
        itemSeqNo = 103;
        break;
      default:
        itemSeqNo += 1;
        break;
    }

    data = await repository.getPosDtlsDataBill(posID);
    ctgryID = data[0].toInt();
    PLU_BillDiscount = data[1].toBool();
    pShift = data[2].toInt();
    blnForceSalesCategory = data[3].toBool();
    blnForceSalesCategorySellband = data[4].toBool();

    if (discType == 'DAmount') {
      discAmnt = fnParm;
      discPercent = 0;
    } else if (discType == 'DPercent') {
      discPercent = fnParm;

      if (PLU_BillDiscount) {
        data = await repository.getBillAmount(salesNo, splitNo);

        total = data[0].toDouble();
        disc = data[1].toDouble();
        surcharge = data[2].toDouble();
      }

      if (coverBased) {
        discAmnt = (intCoverBased / nCover) *
            (fnParm / 100) *
            (total + surcharge - disc);
      } else {
        discAmnt = (fnParm / 100) * (total + surcharge - disc);
      }
    }
    // Get PShift, Start
    // Declare Vars
    bool hpyHr1;
    bool hpyHr2;
    bool hpyHr3;

    String hpyStart1;
    String hpyStart2;
    String hpyStart3;

    String hpyEnd1;
    String hpyEnd2;
    String hpyEnd3;

    String hpyShiftDay;
    String hpyShift1;
    String hpyShift2;
    String hpyShift3;

    int hpyPShift1;
    int hpyPShift2;
    int hpyPShift3;

    hpyShiftDay = DateFormat('EEEE').format(DateTime.now()).substring(0, 3);
    hpyShift1 = hpyShiftDay + '1';
    hpyShift2 = hpyShiftDay + '2';
    hpyShift3 = hpyShiftDay + '3';

    await repository.insertHDSHappyHourShift(
        posID: posID,
        salesNo: salesNo,
        splitNo: splitNo,
        hpyShift1: hpyShift1,
        hpyShift2: hpyShift2,
        hpyShift3: hpyShift3);

    data = await repository.getHDSHappyHourShift(
        posID: posID, salesNo: salesNo, splitNo: splitNo);

    hpyHr1 = data[0].toBool();
    hpyHr2 = data[1].toBool();
    hpyHr3 = data[2].toBool();
    hpyStart1 = data[3].toString();
    hpyStart2 = data[4].toString();
    hpyStart3 = data[5].toString();
    hpyEnd1 = data[6].toString();
    hpyEnd2 = data[7].toString();
    hpyEnd3 = data[8].toString();
    hpyPShift1 = data[9].toInt();
    hpyPShift2 = data[10].toInt();
    hpyPShift3 = data[11].toInt();

    if (sTime.compareTo(parse(hpyStart1)) >= 0 &&
        sTime.compareTo(parse(hpyEnd1)) <= 0 &&
        hpyHr1 == 1 &&
        hpyPShift1 != 0) {
      pShift = hpyPShift1;
    }

    if (sTime.compareTo(parse(hpyStart2)) >= 0 &&
        sTime.compareTo(parse(hpyEnd2)) <= 0 &&
        hpyHr2 == 1 &&
        hpyPShift2 != 0) {
      pShift = hpyPShift2;
    }

    if (sTime.compareTo(parse(hpyStart3)) >= 0 &&
        sTime.compareTo(parse(hpyEnd3)) <= 0 &&
        hpyHr3 == 1 &&
        hpyPShift3 != 0) {
      pShift = hpyPShift3;
    }

    if (blnForceSalesCategory && blnForceSalesCategorySellband) {
      final shift = await repository.getSellPriceShift(ctgryID);
      pShift = shift;
    }

    await repository.deleteHappyHourShift(
        posID: posID, salesNo: salesNo, splitNo: splitNo);

    // Get pShift, End

    await repository.addDiscBill(
        salesNo: salesNo,
        posID: posID,
        sDate: DateFormat('yyyy-MM-dd').format(sDate),
        sTime: DateFormat('HH:mm:ss.0').format(sTime),
        fnTitle: fnTitle,
        fnTitleCh: fnTitleCh,
        tableNo: tableNo,
        splitNo: splitNo,
        operatorNo: operatorNo,
        qty: qty,
        discAmnt: discAmnt,
        avgCost: avgCost,
        rcpID: rcpID,
        pShift: pShift,
        fnID: fnID,
        sFnID: sFnID,
        discPercent: discPercent,
        itemSeqNo: itemSeqNo,
        ctgryID: ctgryID,
        memId: memId,
        loyaltyCardNo: loyaltyCardNo,
        nCover: nCover,
        discRemarks: discRemarks);

    await repository.updateHeldItemsDiscBill(
        tableNo: tableNo,
        salesNo: salesNo,
        splitNo: splitNo,
        itemSeqNo: itemSeqNo);

    await repository.updateHeldTables(salesNo, splitNo);

    // } catch (e) {}
  }

  /// SP_HDS_Disc
  Future<void> disc(
      String posID,
      int operatorNo,
      String tableNo,
      int salesNo,
      int splitNo,
      int salesRef,
      int discCode,
      String discRemarks,
      double discAmountOpen) async {
    try {
      String strSql;
      String errMsg;
      String resultMsg;
      String discTitle;
      int fnctnID;
      int subFnID;
      int fnFeature;
      double fnParm;
      bool disc_remakrs;
      bool coverBased;
      int intCoverBased = 0;
      String coverbasedtype;
      bool discItemAmt;
      bool discItemPer;
      bool discTotalAmt;
      bool discTotalPer;
      int cntDiscID;

      // state = DiscountState(workable: Workable.loading);

      int cntSubFunc = await repository.countDiscByID(discCode);
      if (cntSubFunc == 0) {
        state = state.copyWith(
            workable: Workable.ready,
            failiure: Failiure(
                errMsg: 'Invalid Discount! Cannot find the selected discount'));
        return;
      } else {
        DiscountModel disc = await repository.getDiscByDiscCode(discCode);

        discTitle = disc.discTitle;
        fnctnID = disc.fnctnID;
        subFnID = disc.subFnID;
        fnFeature = disc.fnFeature;
        fnParm = disc.fnParm.toDouble();
        disc_remakrs = disc.disc_remarks.toBool();
        coverBased = disc.coverBased.toBool();
        coverbasedtype = disc.coverbasedtype;

        List<String> data = await repository.getOperatorByID(operatorNo);

        discItemAmt = data[0].toBool();
        discItemPer = data[1].toBool();
        discTotalAmt = data[2].toBool();
        discTotalPer = data[3].toBool();

        cntDiscID = await repository.countDiscID(operatorNo, subFnID);

        if (await repository.countSalesRef1(salesNo, splitNo) == 0) {
          state = state.copyWith(
              workable: Workable.ready,
              failiure: Failiure(
                  errMsg:
                      'Discount $discTitle Failed! No item can be found to give discount'));
          return;
        } else {
          if (await repository.countSalesRef2(salesNo, splitNo, salesRef) > 0) {
            state = state.copyWith(
                workable: Workable.ready,
                failiure: Failiure(
                    errMsg:
                        'Discount $discTitle Failed! Further discounting is not allowed after a Bill Discount. Void Previous Bill Discount and try again'));
            return;
          } else {
            if (coverBased) {
              int nCB = await repository.countCoverbasedType(
                  coverbasedtype, salesNo, splitNo);

              // if (nCB != null) {
              intCoverBased = nCB;
              // } else {
              //   intCoverBased = 0;
              // }
            }

            // Start, Allow FnParm = 0 with FnFeature = 1
            if (fnParm <= 0 && fnFeature != 1) {
              if (fnctnID == 24 && fnFeature == 2) {
                state = state.copyWith(
                    workable: Workable.ready,
                    failiure: Failiure(
                        errMsg:
                            'Please set the Parameter of Item Discount Percent'));
                return;
              }
              if (fnctnID == 25 && fnFeature == 2) {
                state = state.copyWith(
                    workable: Workable.ready,
                    failiure: Failiure(
                        errMsg:
                            'Please set the Parameter of Bill Discount Percent'));
                return;
              }
            }
            // End, Allow FnParm = 0 with FnFeature = 1
            else {
              // Start, Fnparm = 0with FnFeature = 1 is Open Disc, then FnParm = DiscAmountOpen
              if (fnParm == 0 && fnFeature == 1) {
                fnParm = discAmountOpen;
              }
              // End
              if (fnctnID == 24) {
                if (salesRef == 0) {
                  state = state.copyWith(
                      workable: Workable.ready,
                      failiure: Failiure(
                          errMsg:
                              'Discount $discTitle Failed! Please insert an itme to give $discTitle'));
                  return;
                } else {
                  if (await repository.countSalesRef3(
                          salesNo, splitNo, salesRef) <
                      1) {
                    state = state.copyWith(
                        workable: Workable.ready,
                        failiure: Failiure(
                            errMsg:
                                'Discount $discTitle Failed! Please insert an item and try again'));
                    return;
                  } else {
                    String PLUNo;
                    String PLUName;

                    data = await repository.getPLU(salesNo, splitNo, salesRef);
                    PLUNo = data[0];
                    PLUName = data[1];

                    if (await repository.countPLUDiscountAllowed(PLUNo) < 1) {
                      state = state.copyWith(
                          workable: Workable.ready,
                          failiure: Failiure(
                              errMsg:
                                  'Discount $discTitle Failed! Discount isn ot allowed for PLU : $PLUName'));
                      return;
                    } else {
                      if (await repository.countPLUDiscentitle(PLUNo) > 0) {
                        if (await repository.countpluDisc(PLUNo, subFnID) < 1) {
                          state = state.copyWith(
                              workable: Workable.ready,
                              failiure: Failiure(
                                  errMsg:
                                      'Discount $discTitle Failed! PLU is not entitle for $discTitle'));
                          return;
                        }
                      }

                      if (await repository.countSalesRef4(
                              salesNo, splitNo, salesRef) >
                          0) {
                        state = state.copyWith(
                            workable: Workable.ready,
                            failiure: Failiure(
                                errMsg:
                                    'Discount $discTitle Failed! Please void the previous Item Discount given for the item and try again'));
                        return;
                      } else {
                        if (await repository.countSalesRef5(
                                salesNo, splitNo, salesRef) >
                            0) {
                          state = state.copyWith(
                              workable: Workable.ready,
                              failiure: Failiure(
                                  errMsg:
                                      'Discount $discTitle Failed! Please void the previous Promotion given for the item and try again'));
                          return;
                        } else {
                          double itemAmt = await repository.calcItemAmt(
                              salesNo, splitNo, salesRef);

                          if (fnFeature == 1) {
                            if (discItemAmt == 0) {
                              state = state.copyWith(
                                  workable: Workable.ready,
                                  failiure: Failiure(
                                      errMsg:
                                          'Discount $discTitle Failed! Operator does not have enough permission.'));
                              return;
                            } else {
                              if (cntDiscID <= 0) {
                                state = state.copyWith(
                                    workable: Workable.ready,
                                    failiure: Failiure(
                                        errMsg:
                                            'Discount $discTitle Failed! Operator does not have permission to give $discTitle'));
                                return;
                              } else {
                                if (fnParm > itemAmt) {
                                  state = state.copyWith(
                                      workable: Workable.ready,
                                      failiure: Failiure(
                                          errMsg:
                                              'Discount $discTitle Failed! Item Discount should not be greater than Item Amount'));
                                  return;
                                } else {
                                  await discItem(
                                      fnctnID,
                                      subFnID,
                                      'DAmount',
                                      fnParm,
                                      discTitle,
                                      posID,
                                      operatorNo,
                                      tableNo,
                                      salesNo,
                                      splitNo,
                                      salesRef,
                                      PLUNo,
                                      itemAmt,
                                      discRemarks);
                                }
                              }
                            }
                          }

                          if (fnFeature == 2) {
                            if (!discItemPer) {
                              state = state.copyWith(
                                  workable: Workable.ready,
                                  failiure: Failiure(
                                      errMsg:
                                          'Discount $discTitle Failed! Operator does not have enough permission.'));
                              return;
                            } else {
                              if (cntDiscID <= 0) {
                                state = state.copyWith(
                                    workable: Workable.ready,
                                    failiure: Failiure(
                                        errMsg:
                                            'Discount $discTitle Failed! Operator does not have permission to give $discTitle'));
                                return;
                              } else {
                                if (fnParm > 100 || fnParm < 0) {
                                  state = state.copyWith(
                                      workable: Workable.ready,
                                      failiure: Failiure(
                                          errMsg:
                                              'Discount $discTitle Failed! Discount percentage should be in the rage 0 - 100'));
                                  return;
                                } else {
                                  if (await repository.countSalesRef6(
                                          salesNo, splitNo, salesRef) >
                                      0) {
                                    state = state.copyWith(
                                        workable: Workable.ready,
                                        failiure: Failiure(
                                            errMsg:
                                                'Discount $discTitle Failed! Stop Rental before giving an Item Percentage Discount.'));
                                    return;
                                  } else {
                                    await discItem(
                                        fnctnID,
                                        subFnID,
                                        'DPercent',
                                        fnParm,
                                        discTitle,
                                        posID,
                                        operatorNo,
                                        tableNo,
                                        salesNo,
                                        splitNo,
                                        salesRef,
                                        PLUNo,
                                        itemAmt,
                                        discRemarks);
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }

              // Func 25
              if (fnctnID == 25) {
                if (await repository.countSalesRef7(
                        salesNo, splitNo, salesRef) >
                    0) {
                  state = state.copyWith(
                      workable: Workable.ready,
                      failiure: Failiure(
                          errMsg:
                              'Discount $discTitle Failed! Only one Bill Discount is allowed per bill. Void previous Bill Discount and try again'));
                  return;
                } else {
                  if (await repository.countSalesRef8(
                          salesNo, splitNo, salesRef) >
                      0) {
                    state = state.copyWith(
                        workable: Workable.ready,
                        failiure: Failiure(
                            errMsg:
                                'Discount $discTitle Failed! Stop Rental before giving a Bill Discount'));
                    return;
                  } else {
                    if (await repository.countSalesRef9(
                            salesNo, splitNo, salesRef) >
                        0) {
                      state = state.copyWith(
                          workable: Workable.ready,
                          failiure: Failiure(
                              errMsg:
                                  'Discount $discTitle Failed! Please void the previous Promotion given for the items and try again'));
                      return;
                    } else {
                      if (await repository.countSalesRef10(
                              salesNo, splitNo, salesRef) !=
                          await repository.countSalesRef11(
                              salesNo, splitNo, subFnID)) {
                        state = state.copyWith(
                            workable: Workable.ready,
                            failiure: Failiure(
                                errMsg:
                                    'Discount $discTitle Failed! PLU is not entitle for Discount $discTitle'));
                        return;
                      } else {
                        double total;
                        double disc;
                        double surcharge;

                        final List<double> vals =
                            await repository.getAmount(salesNo, splitNo);
                        total = vals[0];
                        disc = vals[1];
                        surcharge = vals[2];

                        if (fnFeature == 1) {
                          if (discTotalAmt == 0) {
                            state = state.copyWith(
                                workable: Workable.ready,
                                failiure: Failiure(
                                    errMsg:
                                        'Discount $discTitle Failed! Operator does not have enough permission'));
                            return;
                          } else {
                            if (cntDiscID <= 0) {
                              state = state.copyWith(
                                  workable: Workable.ready,
                                  failiure: Failiure(
                                      errMsg:
                                          'Discount $discTitle Failed! Operator does not have permission to give $discTitle'));
                              return;
                            } else {
                              if (fnParm > total) {
                                state = state.copyWith(
                                    workable: Workable.ready,
                                    failiure: Failiure(
                                        errMsg:
                                            'Discount $discTitle Failed! Bill Discount should not be greater than the Bill Total.'));
                                return;
                              } else {
                                await discBill(
                                    fnctnID,
                                    subFnID,
                                    'DAmount',
                                    fnParm,
                                    discTitle,
                                    coverBased,
                                    intCoverBased,
                                    posID,
                                    operatorNo,
                                    tableNo,
                                    salesNo,
                                    splitNo,
                                    total,
                                    disc,
                                    surcharge,
                                    discRemarks);
                              }
                            }
                          }
                        }

                        // fnFeature 2
                        if (fnFeature == 2) {
                          if (discTotalPer == 0) {
                            state = state.copyWith(
                                workable: Workable.ready,
                                failiure: Failiure(
                                    errMsg:
                                        'Discount $discTitle Failed! Operator does not have enough permission.'));
                            return;
                          } else {
                            if (cntDiscID <= 0) {
                              state = state.copyWith(
                                  workable: Workable.ready,
                                  failiure: Failiure(
                                      errMsg:
                                          'Discount $discTitle Failed! Operator does not have permission to give $discTitle'));
                              return;
                            } else {
                              if (fnParm > 100 || fnParm < 0) {
                                state = state.copyWith(
                                    workable: Workable.ready,
                                    failiure: Failiure(
                                        errMsg:
                                            'Discount $discTitle Failed! Discount percentage should be in the rage 0-100.'));
                                return;
                              } else {
                                await discBill(
                                    fnctnID,
                                    subFnID,
                                    'DPercent',
                                    fnParm,
                                    discTitle,
                                    coverBased,
                                    intCoverBased,
                                    posID,
                                    operatorNo,
                                    tableNo,
                                    salesNo,
                                    splitNo,
                                    total,
                                    disc,
                                    surcharge,
                                    discRemarks);
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      orderController.fetchOrderItems();
    } catch (e) {
      state = state.copyWith(
          workable: Workable.ready, failiure: Failiure(errMsg: e.toString()));
    }
  }
}
