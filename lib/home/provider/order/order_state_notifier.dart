import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../../common/GlobalConfig.dart';
import '../../../common/extension/string_extension.dart';
import '../../../common/extension/workable.dart';
import '../../../common/widgets/orderitem_widget.dart';
import '../../../discount/repository/discount_repository.dart';
import '../../../floor_plan/presentation/floor_plan_screen.dart';
import '../../../payment/repository/i_payment_repository.dart';
import '../../../print/provider/print_controller.dart';
import '../../../print/repository/i_print_repository.dart';
import '../../../printer/provider/printer_state.dart';
import '../../../sales_report/application/sales_report_state.dart';
import '../../../zday_report/application/zday_report_state.dart';
import '../../model/modifier.dart';
import '../../model/order_item_model.dart';
import '../../model/order_mod_model.dart';
import '../../model/order_prep_model.dart';
import '../../repository/order/i_order_repository.dart';
import 'order_state.dart';

@Injectable()
class OrderStateNotifier extends StateNotifier<OrderState> {
  OrderStateNotifier(this.orderRepository, this.paymentRepository,
      this.discRepository, this.printRepository,
      {@factoryParam required this.printController})
      : super(OrderState());
  final IOrderRepository orderRepository;
  final IPaymentRepository paymentRepository;
  final DiscountRepository discRepository;
  final IPrintRepository printRepository;
  final PrintController printController;

  int? _salesRef = 0;
  // create order item
  Future<void> addOrderItem(
      String posID,
      int operatorNo,
      String tablNo,
      int salesNo,
      int splitNo,
      String pluNo,
      int cover,
      double qty,
      int catId) async {
    DateTime now = DateTime.now();
    String strCurDate = DateFormat('yyyy-MM-dd').format(now);
    String strCurTime = DateFormat('HH:mm:ss.0').format(now);

    // state = OrderInitialState();
    // try {
    List<int> taxs = await orderRepository.getTaxFromSC(catId);

    int pluCnt = await orderRepository.countPLU(pluNo, 1);
    if (pluCnt == 0) {
      state = state.copyWith(
          failure: Failure(errMsg: 'Can not find the PLU: $pluNo'));
    } else {
      List<List<String>> pluDtls =
          await orderRepository.getPLUDetailsByNumber(pluNo);
      List<String> tempPluDtls = pluDtls[0];
      String pluName = tempPluDtls[0];
      int dept = tempPluDtls[1].toInt();
      double amount = tempPluDtls[2].toDouble();
      int selPluKp1 = tempPluDtls[3].toInt();
      int selPluKp2 = tempPluDtls[4].toInt();
      int selPluKp3 = tempPluDtls[5].toInt();
      String pluLnkTo = tempPluDtls[6];
      int rcpId = tempPluDtls[7].toInt();
      double avgCost = tempPluDtls[8].toDouble();
      bool prep = tempPluDtls[9].toBool();
      String pluNameCh = tempPluDtls[10];
      bool rentalItem = tempPluDtls[11].toBool();
      bool comments = tempPluDtls[12].toBool();
      bool trackPrep = tempPluDtls[13].toBool();

      if (!trackPrep) {
        trackPrep = tempPluDtls[14].toBool();
      }
      String taxTag = tempPluDtls[15];
      int soldPluCnt = await orderRepository.countSoldPLU(pluNo);
      if (soldPluCnt > 0) {
        orderRepository.updateSoldPLU(1, pluNo);
      }
      // insert order item
      else {
        int itemSeqNo = await getListSeqNo(salesNo);
        int setRecipeRefNo = 0;
        bool setRecipeSetMenu = false;

        OrderItemModel orderItem = OrderItemModel(
          POSID: posID,
          OperatorNo: operatorNo,
          Covers: cover,
          TableNo: tablNo,
          SalesNo: salesNo,
          SplitNo: splitNo,
          // SalesRef: 1,
          PLUSalesRef: 0,
          ItemSeqNo: itemSeqNo,
          PLUNo: pluNo,
          Department: dept,
          SDate: strCurDate,
          STime: strCurTime,
          Quantity: qty.toInt(),
          ItemName: pluName,
          ItemName_Chinese: pluNameCh,
          ItemAmount: amount.toDouble(),
          PaidAmount: 0,
          ChangeAmount: 0,
          Tax0: 0,
          Tax1: 0,
          Tax2: 0,
          Tax3: 0,
          Tax4: 0,
          Tax5: 0,
          Tax6: 0,
          Tax7: 0,
          Tax8: 0,
          Tax9: 0,
          PromotionId: 0,
          TransMode: '',
          RefundID: 0,
          TransStatus: ' ',
          FunctionID: 26,
          SubFunctionID: 0,
          MembershipID: 0,
          LoyaltyCardNo: '',
          AvgCost: avgCost,
          RecipeId: rcpId,
          PriceShift: 0,
          CategoryId: catId,
          Preparation: prep.toInt(),
          FOCItem: 0,
          FOCType: '',
          ApplyTax0: taxs[0],
          ApplyTax1: taxs[1],
          ApplyTax2: taxs[2],
          ApplyTax3: taxs[3],
          ApplyTax4: taxs[4],
          ApplyTax5: taxs[5],
          ApplyTax6: taxs[6],
          ApplyTax7: taxs[7],
          ApplyTax8: taxs[8],
          ApplyTax9: taxs[9],
          LnkTo: pluLnkTo,
          Setmenu: setRecipeSetMenu.toInt(),
          SetMenuRef: setRecipeRefNo,
          TblHold: 0,
          RentalItem: rentalItem.toInt(),
          SeatNo: 0,
          SalesAreaID: '0',
          ServerNo: operatorNo,
          comments: comments.toInt(),
          Trackprep: trackPrep.toInt(),
          TaxTag: '0',
          KDSPrint: 0,
        );
        await orderRepository.insertOrderItem(orderItem);

        List<String> values = [
          salesNo.toString(),
          splitNo.toString(),
          tablNo,
          itemSeqNo.toString()
        ];
        await orderRepository.updatePLUSalesRef(values, 1);
        _salesRef = await orderRepository.getItemSalesRef(
            salesNo, splitNo, tablNo, itemSeqNo, 0);
        int? pluSalesNo =
            await orderRepository.getMaxSalesRef(salesNo, splitNo, -1);

        if (selPluKp1 != 0) {
          await orderRepository.insertKPStatus(
              salesNo, splitNo, itemSeqNo, selPluKp1);
        }
        if (selPluKp2 != 0) {
          await orderRepository.insertKPStatus(
              salesNo, splitNo, itemSeqNo, selPluKp2);
        }
        if (selPluKp3 != 0) {
          await orderRepository.insertKPStatus(
              salesNo, splitNo, itemSeqNo, selPluKp3);
        }

        if (POSDefault.blnSplitQuantity) {
          // global blnSplitQuantity
          if (POSDefault.blnSplitKPStatus) {
            // global !blnSplitKPStatus
            values = [
              salesNo.toString(),
              splitNo.toString(),
              itemSeqNo.toString()
            ];
            await orderRepository.updateOrderStatus(values, 1);

            values = [
              salesNo.toString(),
              splitNo.toString(),
              _salesRef.toString()
            ];
            await orderRepository.updateOrderStatus(values, 2);
          }
        }
        if (POSDefault.taxInclusive) {
          // global !taxInclusive
          int countExempt = await orderRepository.countPLU(pluNo, 2);
          if (countExempt > 0) {
            int? taxCode = await orderRepository.getTaxCode();
            if (taxCode != null) {
              for (var i = 0; i < taxCode; i++) {
                String strPluTax = 'exmpttax$i';
                bool bExmpt =
                    await orderRepository.checkExemptTax(strPluTax, pluNo);
                if (bExmpt && _salesRef != null) {
                  String strTax = 'ApplyTax$i';
                  await orderRepository.updateItemTax(
                      strTax, salesNo, splitNo, _salesRef!);
                }
              }
            }
          }
        }
      }
    }
  }

  Future<void> updateOrderItem(
      String pluNumber,
      String modifier,
      int qty,
      bool focItem,
      Map<String, Map<String, String>> prepSelect,
      OrderItemModel orderItem) async {
    tempPLUNo = orderItem.PLUNo ?? '';
    sRef = orderItem.SalesRef ?? 0;
    lnkTo = orderItem.LnkTo ?? '';
    tempPLUName = orderItem.ItemName ?? '';
    iSeqNo = orderItem.ItemSeqNo ?? 0;
    pluSRef = orderItem.SalesRef ?? 0;

    try {
      // if (lnkTo.isEmpty) {
      //   // TODO(smith): Update Set Menu
      // } else {
      await orderRepository.updateItemQuantity(GlobalConfig.salesNo,
          GlobalConfig.splitNo, GlobalConfig.tableNo, qty, sRef);
      // }

      List<OrderPrepModel> prepArr = await orderRepository.getOrderPrepData(
          GlobalConfig.salesNo,
          GlobalConfig.splitNo,
          sRef,
          GlobalConfig.tableNo);
      List<OrderModData> modArr = await orderRepository.getOrderModData(
          GlobalConfig.salesNo,
          GlobalConfig.splitNo,
          sRef,
          GlobalConfig.tableNo);

      if (modifier.isNotEmpty) {
        if (modArr.isNotEmpty) {
          final String modExist = modArr[0].modName;
          modifier = '++$modifier';
          final int modSRef = modArr[0].modSalesRef;

          if (modExist != modifier) {
            await orderRepository.updateItemModifier(GlobalConfig.salesNo,
                GlobalConfig.splitNo, GlobalConfig.tableNo, modifier, modSRef);
          }
        } else {
          await addModifier(
              POSDtls.deviceNo,
              GlobalConfig.operatorNo,
              GlobalConfig.cover,
              GlobalConfig.tableNo,
              GlobalConfig.salesNo,
              GlobalConfig.splitNo,
              modifier,
              sRef);
        }
      } else if (modArr.isNotEmpty) {
        final int modSRef = modArr[0].modSalesRef;
        await orderRepository.voidOrder(
            GlobalConfig.salesNo,
            GlobalConfig.splitNo,
            GlobalConfig.tableNo,
            sRef,
            '',
            GlobalConfig.operatorNo);
      }

      List<String> prepKey = prepSelect.keys.toList();
      if (prepArr.isNotEmpty) {
        if (prepArr.length == prepKey.length) {
          for (int i = 0; i < prepKey.length; i++) {
            final String prepPLUNo = prepKey[0];
            Map<String, String> prepDtls = prepSelect[prepPLUNo] ?? {};
            final int prepQty = prepDtls['Quantity']?.toInt() ?? 0;

            for (int j = 0; j < prepArr.length; j++) {
              final int prepSRef = prepArr[j].prepSalesRef;
              final String prepPLUNoExist = prepArr[j].prepNumber;

              if (prepPLUNo == prepPLUNoExist) {
                await orderRepository.updateItemQuantity(
                    GlobalConfig.salesNo,
                    GlobalConfig.splitNo,
                    GlobalConfig.tableNo,
                    prepQty,
                    prepSRef);
                break;
              } else {
                await prepOrderItem(
                    POSDtls.deviceNo,
                    GlobalConfig.operatorNo,
                    GlobalConfig.tableNo,
                    GlobalConfig.salesNo,
                    GlobalConfig.splitNo,
                    prepPLUNo,
                    GlobalConfig.cover,
                    qty,
                    sRef);
              }
            }
          }
        }
      } else {
        for (int i = 0; i < prepKey.length; i++) {
          final String prepPLUNo = prepKey[i];
          final Map<String, String> prepDtls = prepSelect[prepPLUNo] ?? {};
          final int prepQty = prepDtls['Quantity']?.toInt() ?? 0;

          await prepOrderItem(
              POSDtls.deviceNo,
              GlobalConfig.operatorNo,
              GlobalConfig.tableNo,
              GlobalConfig.salesNo,
              GlobalConfig.splitNo,
              prepPLUNo,
              GlobalConfig.cover,
              qty,
              sRef);
        }
      }
      if (focItem) {
        await orderRepository.doFOCItem(
            GlobalConfig.salesNo,
            GlobalConfig.splitNo,
            GlobalConfig.tableNo,
            POSDtls.deviceNo,
            GlobalConfig.operatorNo,
            POSDtls.PShift.toInt(),
            iSeqNo,
            POSDtls.categoryID,
            GlobalConfig.PLUName,
            sRef);
      }
      List<OrderItemModel> orderItems = await orderRepository.fetchOrderItems(
          GlobalConfig.salesNo, GlobalConfig.splitNo, GlobalConfig.tableNo);
      state = state.copyWith(
        orderItems: orderItems,
        bills: await calcBill(),
        paymentPermission: await paymentRepository.checkPaymentPermission(
            GlobalConfig.operatorNo, 5),
        orderItemTree: configureTree(orderItems),
        workable: Workable.ready,
      );
    } catch (e) {
      state = state.copyWith(failure: Failure(errMsg: e.toString()));
    }
  }

  String tempPLUNo = '';
  int sRef = 0;
  String lnkTo = '';
  String tempPLUName = '';
  int iSeqNo = 0;
  int pluSRef = 0;
  int qty = 0;
  Future<void> voidOrderItemRemarks(int status, String remarks) async {
    try {
      if (state.workable == Workable.ready) {
        await orderRepository.voidOrder(
            GlobalConfig.salesNo,
            GlobalConfig.splitNo,
            GlobalConfig.tableNo,
            sRef,
            remarks,
            GlobalConfig.operatorNo);
        sRef = 0;
        List<OrderItemModel> orderItems = await orderRepository.fetchOrderItems(
            GlobalConfig.salesNo, GlobalConfig.splitNo, GlobalConfig.tableNo);
        state = state.copyWith(
          orderItems: orderItems,
          bills: await calcBill(),
          paymentPermission: await paymentRepository.checkPaymentPermission(
              GlobalConfig.operatorNo, 5),
          orderItemTree: configureTree(orderItems),
          workable: Workable.ready,
        );
      }
    } catch (e) {
      state = state.copyWith(failure: Failure(errMsg: e.toString()));
    }
  }

  Future<void> voidOrderItem(OrderItemModel orderItem) async {
    try {
      if (state.workable == Workable.ready) {
        tempPLUNo = orderItem.PLUNo ?? '';
        sRef = orderItem.SalesRef ?? 0;
        lnkTo = orderItem.LnkTo ?? '';
        tempPLUName = orderItem.ItemName ?? '';
        iSeqNo = orderItem.ItemSeqNo ?? 0;
        pluSRef = orderItem.SalesRef ?? 0;
        qty = orderItem.Quantity ?? 0;

        if (orderItem.FunctionID == 25) {
          int voidRemarks =
              await orderRepository.getPostVoidData(sRef, GlobalConfig.salesNo);
          if (voidRemarks > 0) {
            if (qty > 1) {
              // TODO(smith): show split quantity
            } else {
              // TODO(smith): show remarks dialog
              final List<List<String>> remarks =
                  await orderRepository.getVoidRemarks();
              state = state.copyWith(
                  operation: OPERATIONS.SHOW_REMARKS, remarks: remarks);
            }
          } else {
            await orderRepository.voidOrder(
                GlobalConfig.salesNo,
                GlobalConfig.splitNo,
                GlobalConfig.tableNo,
                sRef,
                '',
                GlobalConfig.operatorNo);

            List<OrderItemModel> orderItems =
                await orderRepository.fetchOrderItems(GlobalConfig.salesNo,
                    GlobalConfig.splitNo, GlobalConfig.tableNo);
            state = state.copyWith(
              orderItems: orderItems,
              bills: await calcBill(),
              paymentPermission: await paymentRepository.checkPaymentPermission(
                  GlobalConfig.operatorNo, 5),
              orderItemTree: configureTree(orderItems),
              workable: Workable.ready,
            );
          }
        } else {
          bool isBillDisc = await discRepository.CheckDiscBill(
              GlobalConfig.salesNo, GlobalConfig.splitNo);
          if (isBillDisc) {
            throw Exception(
                'Void Item Failed! \n Void item not allowed after a "Bill Discount". Void Previous "Bill Discount" and try again');
          } else {
            if (qty > 1) {
              // TODO(smith): show split qty
            } else {
              int voidRemarks = await orderRepository.getPostVoidData(
                  sRef, GlobalConfig.salesNo);
              if (voidRemarks > 0) {
                // TODO(smith): Remarks Dialog
                final List<List<String>> remarks =
                    await orderRepository.getVoidRemarks();
                state = state.copyWith(
                    operation: OPERATIONS.SHOW_REMARKS, remarks: remarks);
              } else {
                await orderRepository.voidOrder(
                    GlobalConfig.salesNo,
                    GlobalConfig.splitNo,
                    GlobalConfig.tableNo,
                    sRef,
                    '',
                    GlobalConfig.operatorNo);

                List<OrderItemModel> orderItems =
                    await orderRepository.fetchOrderItems(GlobalConfig.salesNo,
                        GlobalConfig.splitNo, GlobalConfig.tableNo);
                state = state.copyWith(
                  orderItems: orderItems,
                  bills: await calcBill(),
                  paymentPermission: await paymentRepository
                      .checkPaymentPermission(GlobalConfig.operatorNo, 5),
                  orderItemTree: configureTree(orderItems),
                  workable: Workable.ready,
                );
              }
            }
          }
        }
      }
    } catch (e) {
      state = state.copyWith(failure: Failure(errMsg: e.toString()));
    }
  }

  Future<void> addModifier(
      String posID,
      int operatorNo,
      int cover,
      String tableNo,
      int salesNo,
      int splitNo,
      String modifier,
      int salesRef) async {
    OrderItemModel? parentOrderItem =
        await orderRepository.getItemParentData(salesNo, splitNo, salesRef);
    if (parentOrderItem != null) {
      String? pluNo = parentOrderItem.PLUNo;
      int categoryId = parentOrderItem.CategoryId ?? 0;

      DateTime now = DateTime.now();
      String strCurDate = DateFormat('yyyy-MM-dd').format(now);
      String strCurTime = DateFormat('HH:mm:ss.0').format(now);
      state = state.copyWith(workable: Workable.loading);

      List<int> taxs = await orderRepository.getTaxFromSC(categoryId);
      int seatNo = 0;
      if (pluNo != null) {
        String tempModifierPLU = pluNo;
        int checkData =
            await orderRepository.countItem(pluNo, salesNo, splitNo, salesRef);
        if (checkData > 0) {
          String? val = await orderRepository.getItemData(
              tempModifierPLU, salesNo, splitNo, salesRef);
          if (val != null) {
            seatNo = val.toInt();
          }
        }

        int msgId;
        String message = '';
        String messageCh = '';
        checkData = await orderRepository.countPLU(pluNo, 3);
        if (checkData > 0) {
          ModifierModel? modifierModel =
              await orderRepository.getModDtls(modifier);
          if (modifierModel != null) {
            msgId = modifierModel.msgId ?? 0;
            message = '++${modifierModel.message}';
            messageCh = '++${modifierModel.messageCh}';
          }
        } else {
          message = '++$modifier';
          messageCh = '++$modifier';
        }

        checkData =
            await orderRepository.countItem('1', salesNo, splitNo, salesRef);
        if (checkData > 0) {
          int val =
              await orderRepository.getPrepStatus(salesNo, splitNo, salesRef);
          if (val.toBool()) {
            _salesRef = await orderRepository.getItemSalesRef(
                salesNo, splitNo, tableNo, salesRef, 1);
          }
          if (_salesRef != null) {
            checkData = await orderRepository.countItem(
                '1', salesNo, splitNo, _salesRef!);
          }
          if (checkData > 0) {
            pluNo = await orderRepository.getItemData(
                '-1', salesNo, splitNo, salesRef);
          }
        }
        int itemSeqNo = await getListSeqNo(salesNo);

        if (pluNo != null) {
          int selPLUKP1 = 0, selPLUKP2 = 0, selPLUKP3 = 0;
          bool rentalItem = false;
          checkData = await orderRepository.countPLU(pluNo, 1);
          if (checkData > 0) {
            List<List<String>> pluData =
                await orderRepository.getPLUDetailsByNumber(pluNo);
            List<String> tempPluData = pluData[0];
            selPLUKP1 = tempPluData[3].toInt();
            selPLUKP2 = tempPluData[4].toInt();
            selPLUKP3 = tempPluData[5].toInt();
            rentalItem = tempPluData[11].toBool();
          }

          OrderItemModel orderItem = OrderItemModel(
            POSID: posID,
            OperatorNo: operatorNo,
            Covers: cover,
            TableNo: tableNo,
            SalesNo: salesNo,
            SplitNo: splitNo,
            // SalesRef: 1,
            PLUSalesRef: 0,
            ItemSeqNo: itemSeqNo,
            PLUNo: pluNo,
            Department: 0,
            SDate: strCurDate,
            STime: strCurTime,
            Quantity: 0,
            ItemName: message,
            ItemName_Chinese: messageCh,
            ItemAmount: 0,
            PaidAmount: 0,
            ChangeAmount: 0,
            Tax0: 0,
            Tax1: 0,
            Tax2: 0,
            Tax3: 0,
            Tax4: 0,
            Tax5: 0,
            Tax6: 0,
            Tax7: 0,
            Tax8: 0,
            Tax9: 0,
            PromotionId: 0,
            TransMode: '',
            RefundID: 0,
            TransStatus: ' ',
            FunctionID: 26,
            SubFunctionID: 0,
            MembershipID: 0,
            LoyaltyCardNo: 'M',
            AvgCost: 101,
            RecipeId: 0,
            PriceShift: 0,
            CategoryId: categoryId,
            Preparation: 1,
            FOCItem: 0,
            FOCType: '',
            ApplyTax0: taxs[0],
            ApplyTax1: taxs[1],
            ApplyTax2: taxs[2],
            ApplyTax3: taxs[3],
            ApplyTax4: taxs[4],
            ApplyTax5: taxs[5],
            ApplyTax6: taxs[6],
            ApplyTax7: taxs[7],
            ApplyTax8: taxs[8],
            ApplyTax9: taxs[9],
            LnkTo: '1',
            Setmenu: 0,
            SetMenuRef: 0,
            TblHold: 0,
            RentalItem: rentalItem.toInt(),
            SeatNo: 0,
            SalesAreaID: '0',
            ServerNo: operatorNo,
            comments: 0,
            Trackprep: 0,
            TaxTag: 'V',
            KDSPrint: 0,
          );
          await orderRepository.insertOrderItem(orderItem);
          if (selPLUKP1 != 0) {
            await orderRepository.insertKPStatus(
                salesNo, splitNo, itemSeqNo, selPLUKP1);
          }
          if (selPLUKP2 != 0) {
            await orderRepository.insertKPStatus(
                salesNo, splitNo, itemSeqNo, selPLUKP2);
          }
          if (selPLUKP3 != 0) {
            await orderRepository.insertKPStatus(
                salesNo, splitNo, itemSeqNo, selPLUKP3);
          }
        }
      }
    }
  }

  Future<void> prepOrderItem(
      String posID,
      int operatorNo,
      String tablNo,
      int salesNo,
      int splitNo,
      String pluNo,
      int cover,
      int qty,
      int pluSalesRef) async {
    DateTime now = DateTime.now();
    String strCurDate = DateFormat('yyyy-MM-dd').format(now);
    String strCurTime = DateFormat('HH:mm:ss.0').format(now);

    if (_salesRef == null) {
      return;
    }

    OrderItemModel? orderItem =
        await orderRepository.getItemParentData(salesNo, splitNo, _salesRef!);

    if (orderItem == null && orderItem!.CategoryId != null) return;

    int categoryId = orderItem.CategoryId!;

    List<int> taxs = await orderRepository.getTaxFromSC(categoryId);

    int pluCnt = await orderRepository.countPLU(pluNo, 1);
    if (pluCnt == 0) {
      state = state.copyWith(
          failure: Failure(errMsg: 'Can not find the PLU: $pluNo'));
    } else {
      List<List<String>> pluDtls =
          await orderRepository.getPLUDetailsByNumber(pluNo);
      List<String> tempPluDtls = pluDtls[0];
      String pluName = tempPluDtls[0];
      int dept = tempPluDtls[1].toInt();
      double amount = tempPluDtls[2].toDouble();
      int selPluKp1 = tempPluDtls[3].toInt();
      int selPluKp2 = tempPluDtls[4].toInt();
      int selPluKp3 = tempPluDtls[5].toInt();
      String pluLnkTo = tempPluDtls[6];
      int rcpId = tempPluDtls[7].toInt();
      double avgCost = tempPluDtls[8].toDouble();
      bool prep = tempPluDtls[9].toBool();
      String pluNameCh = tempPluDtls[10];
      bool rentalItem = tempPluDtls[11].toBool();
      bool comments = tempPluDtls[12].toBool();
      bool trackPrep = tempPluDtls[13].toBool();

      if (!trackPrep) {
        trackPrep = tempPluDtls[14].toBool();
      }
      String taxTag = tempPluDtls[15];
      int soldPluCnt = await orderRepository.countSoldPLU(pluNo);
      if (soldPluCnt > 0) {
        orderRepository.updateSoldPLU(1, pluNo);
      }
      // insert order item
      else {
        int itemSeqNo = await getListSeqNo(salesNo);
        int setRecipeRefNo = 0;
        bool setRecipeSetMenu = false;

        OrderItemModel orderItem = OrderItemModel(
          POSID: posID,
          OperatorNo: operatorNo,
          Covers: cover,
          TableNo: tablNo,
          SalesNo: salesNo,
          SplitNo: splitNo,
          // SalesRef: 1,
          PLUSalesRef: _salesRef,
          ItemSeqNo: itemSeqNo,
          PLUNo: pluNo,
          Department: dept,
          SDate: strCurDate,
          STime: strCurTime,
          Quantity: qty.toInt(),
          ItemName: pluName,
          ItemName_Chinese: pluNameCh,
          ItemAmount: amount.toDouble(),
          PaidAmount: 0,
          ChangeAmount: 0,
          Tax0: 0,
          Tax1: 0,
          Tax2: 0,
          Tax3: 0,
          Tax4: 0,
          Tax5: 0,
          Tax6: 0,
          Tax7: 0,
          Tax8: 0,
          Tax9: 0,
          PromotionId: 0,
          TransMode: '',
          RefundID: 0,
          TransStatus: ' ',
          FunctionID: 26,
          SubFunctionID: 0,
          MembershipID: 0,
          LoyaltyCardNo: '',
          AvgCost: avgCost,
          RecipeId: rcpId,
          PriceShift: 0,
          CategoryId: categoryId,
          Preparation: prep.toInt(),
          FOCItem: 0,
          FOCType: '',
          ApplyTax0: taxs[0],
          ApplyTax1: taxs[1],
          ApplyTax2: taxs[2],
          ApplyTax3: taxs[3],
          ApplyTax4: taxs[4],
          ApplyTax5: taxs[5],
          ApplyTax6: taxs[6],
          ApplyTax7: taxs[7],
          ApplyTax8: taxs[8],
          ApplyTax9: taxs[9],
          LnkTo: pluLnkTo,
          Setmenu: setRecipeSetMenu.toInt(),
          SetMenuRef: setRecipeRefNo,
          TblHold: 0,
          RentalItem: rentalItem.toInt(),
          SeatNo: 0,
          SalesAreaID: '0',
          ServerNo: operatorNo,
          comments: comments.toInt(),
          Trackprep: trackPrep.toInt(),
          TaxTag: '0',
          KDSPrint: 0,
        );
        await orderRepository.insertOrderItem(orderItem);

        List<String> values = [
          salesNo.toString(),
          splitNo.toString(),
          tablNo,
          itemSeqNo.toString()
        ];
        await orderRepository.updatePLUSalesRef(values, 1);
        _salesRef = await orderRepository.getItemSalesRef(
            salesNo, splitNo, tablNo, itemSeqNo, 0);
        int? pluSalesNo =
            await orderRepository.getMaxSalesRef(salesNo, splitNo, -1);

        if (selPluKp1 != 0) {
          await orderRepository.insertKPStatus(
              salesNo, splitNo, itemSeqNo, selPluKp1);
        }
        if (selPluKp2 != 0) {
          await orderRepository.insertKPStatus(
              salesNo, splitNo, itemSeqNo, selPluKp2);
        }
        if (selPluKp3 != 0) {
          await orderRepository.insertKPStatus(
              salesNo, splitNo, itemSeqNo, selPluKp3);
        }

        if (POSDefault.blnSplitQuantity) {
          // global blnSplitQuantity
          if (POSDefault.blnSplitKPStatus) {
            // global !blnSplitKPStatus
            values = [
              salesNo.toString(),
              splitNo.toString(),
              itemSeqNo.toString()
            ];
            await orderRepository.updateOrderStatus(values, 1);

            values = [
              salesNo.toString(),
              splitNo.toString(),
              _salesRef.toString()
            ];
            await orderRepository.updateOrderStatus(values, 2);
          }
        }
        if (POSDefault.taxInclusive) {
          // global !taxInclusive
          int countExempt = await orderRepository.countPLU(pluNo, 2);
          if (countExempt > 0) {
            int? taxCode = await orderRepository.getTaxCode();
            if (taxCode != null) {
              for (var i = 0; i < taxCode; i++) {
                String strPluTax = 'exmpttax$i';
                bool bExmpt =
                    await orderRepository.checkExemptTax(strPluTax, pluNo);
                if (bExmpt && _salesRef != null) {
                  String strTax = 'ApplyTax$i';
                  await orderRepository.updateItemTax(
                      strTax, salesNo, splitNo, _salesRef!);
                }
              }
            }
          }
        }
      }
    }
  }

  Future<void> focOrderItem(
      int salesNo,
      int splitNo,
      String tableNo,
      String posID,
      int operatorNo,
      int pShift,
      int itemSeqNo,
      int categoryID,
      String pluNo,
      int salesRef) async {
    await orderRepository.doFOCItem(salesNo, splitNo, tableNo, posID,
        operatorNo, pShift, itemSeqNo, categoryID, pluNo, salesRef);
  }

  // calc bill
  // TODO
  Future<List<double>> calcBill() async {
    if (true /* checkItemOrder */) {
      var paymentData = await orderRepository.fetchAmountOrder(
          GlobalConfig.salesNo,
          GlobalConfig.splitNo,
          GlobalConfig.tableNo,
          POSDefault.taxInclusive);
      var taxTitleData = await orderRepository.getTaxRateData();
      int cntTaxTitle = taxTitleData.length;

      double gTotal = paymentData[0];
      double taxTotal = paymentData[1];
      double sTotal = paymentData[2];
      double disc = paymentData[3];
      // List<double> bills = <double>[gTotal, taxTotal, sTotal, disc];
      List<double> bills = <double>[];
      bills.addAll(paymentData);
      for (var i = 0; i < cntTaxTitle; i++) {}
      return bills;
    }
  }

  Future<void> createOrderItem(String pluNumber, String modifier, int qty,
      bool focItem, Map<String, Map<String, String>> prepSelect) async {
    try {
      // state = OrderInitialState();
      await addOrderItem(
          POSDtls.deviceNo,
          GlobalConfig.operatorNo,
          GlobalConfig.tableNo,
          GlobalConfig.salesNo,
          GlobalConfig.splitNo,
          pluNumber,
          GlobalConfig.cover,
          qty.toDouble(),
          POSDtls.categoryID);

      OrderItemModel? lastOrderItem = await orderRepository.getLastOrderData(
          GlobalConfig.salesNo, GlobalConfig.splitNo, GlobalConfig.tableNo);
      if (lastOrderItem != null) {
        int tempSalesRef = lastOrderItem.SalesRef ?? 0;
        int tempItemSeqNo = lastOrderItem.ItemSeqNo ?? 0;

        if (modifier.isNotEmpty) {
          await addModifier(
              POSDtls.deviceNo,
              GlobalConfig.operatorNo,
              GlobalConfig.cover,
              GlobalConfig.tableNo,
              GlobalConfig.salesNo,
              GlobalConfig.splitNo,
              modifier,
              tempSalesRef);
        }
        for (String item in prepSelect.keys) {
          Map<String, String> prepDetail = prepSelect[item]!;
          int prepQty = (prepDetail['Quantity'] ?? '0').toInt();
          await prepOrderItem(
              POSDtls.deviceNo,
              GlobalConfig.operatorNo,
              GlobalConfig.tableNo,
              GlobalConfig.salesNo,
              GlobalConfig.splitNo,
              item,
              GlobalConfig.cover,
              prepQty,
              tempSalesRef);
        }
        if (focItem) {
          await focOrderItem(
              GlobalConfig.salesNo,
              GlobalConfig.splitNo,
              GlobalConfig.tableNo,
              POSDtls.deviceNo,
              GlobalConfig.operatorNo,
              1, // shift
              tempItemSeqNo,
              POSDtls.categoryID,
              pluNumber,
              tempSalesRef);
        }
      }
      List<OrderItemModel> orderItems = await orderRepository.fetchOrderItems(
          GlobalConfig.salesNo, GlobalConfig.splitNo, GlobalConfig.tableNo);
      state = state.copyWith(
        orderItems: orderItems,
        bills: await calcBill(),
        paymentPermission: await paymentRepository.checkPaymentPermission(
            GlobalConfig.operatorNo, 5),
        orderItemTree: configureTree(orderItems),
        workable: Workable.ready,
      );
    } catch (e) {
      state = state.copyWith(failure: Failure(errMsg: e.toString()));
    }
  }

  Future<int> getListSeqNo(int salesNo) async {
    int seqNo = 0;
    int data = await orderRepository.getItemSeqNo(salesNo);
    if (data == 100) {
      seqNo = 103;
    } else {
      seqNo = data + 1;
    }
    return seqNo;
  }

  Future<void> fetchOrderItems() async {
    try {
      List<OrderItemModel> orderItems = await orderRepository.fetchOrderItems(
          GlobalConfig.salesNo, GlobalConfig.splitNo, GlobalConfig.tableNo);
      state = state.copyWith(
        orderItems: orderItems,
        bills: orderItems.isNotEmpty ? await calcBill() : [],
        workable: Workable.ready,
        paymentPermission: await paymentRepository.checkPaymentPermission(
            GlobalConfig.operatorNo, 5),
        orderItemTree: configureTree(orderItems),
      );
    } catch (e) {
      print('Error: ${e.toString()}');
      state = state.copyWith(
          failure: Failure(errMsg: e.toString()), workable: Workable.failure);
    }
  }

  List<ParentOrderItemWidget> configureTree(List<OrderItemModel> orderItems) {
    List<OrderItemModel> parentItems = orderItems.where((element) {
      return element.Preparation == 0;
    }).toList();
    final List<ParentOrderItemWidget> parentItemWidgets = parentItems.map((e) {
      final ParentOrderItemWidget parentOrderItemWidget =
          ParentOrderItemWidget(orderItem: e, isDark: false);
      orderItems.removeWhere(
          (OrderItemModel element) => element.SalesRef == e.SalesRef);

      List<OrderItemModel> subOrderItems = <OrderItemModel>[];
      for (int i = 0; i < orderItems.length; i++) {
        final OrderItemModel orderitem = orderItems[i];
        if (orderitem.Preparation == 0) {
          break;
        }
        parentOrderItemWidget.addChild(ParentOrderItemWidget(
          orderItem: orderitem,
          isDark: false,
        ));
        subOrderItems.add(orderitem);
      }
      subOrderItems.forEach((element) {
        orderItems
            .removeWhere((orderItem) => orderItem.SalesRef == element.SalesRef);
      });
      subOrderItems.clear();
      return parentOrderItemWidget;
    }).toList();
    return parentItemWidgets;
  }

  Future<void> updateHeldItem(double sTotal, double gTotal) async {
    // update order items in HeldItems table
    await orderRepository.updateHoldItem(GlobalConfig.salesNo,
        GlobalConfig.splitNo, GlobalConfig.tableNo, sTotal, gTotal, 0);
    // fetch updated order items
  }

  // Void All Order
  int oprtNo = 0;
  bool showBFOC = false, showDisc = false, showFunc = false, showPromo = false;

  Future<void> voidAllOrder() async {
    try {
      if (GlobalConfig.checkTableOpen > 0) {
        if (GlobalConfig.AllVoid) {
          if (GlobalConfig.checkItemOrder > 0) {
            List<List<String>> scArray =
                await printRepository.getKPSalesCategory(GlobalConfig.salesNo,
                    GlobalConfig.splitNo, 'HeldItems', 'KPStatus', 0);
            if (scArray.isNotEmpty) {
              await orderRepository.updateHoldItem(GlobalConfig.salesNo,
                  GlobalConfig.splitNo, GlobalConfig.tableNo, 0, 0, 0);
            }

            final int voidRemark =
                await orderRepository.getPostVoidData(0, GlobalConfig.salesNo);
            if (voidRemark > 0) {
              // TODO(Smith): show custom keyboard
              GlobalConfig.CustomKeyboard = 1;
              oprtNo = GlobalConfig.operatorNo;
              state = state.copyWith(operation: OPERATIONS.SHOW_KEYBOARD);
            } else {
              await orderRepository.voidAllOrder(
                  GlobalConfig.salesNo,
                  GlobalConfig.splitNo,
                  GlobalConfig.tableNo,
                  POSDtls.deviceNo,
                  GlobalConfig.operatorNo,
                  GlobalConfig.cover,
                  GlobalConfig.TransMode,
                  InitSalesVar.memId,
                  POSDtls.PShift.toInt(),
                  POSDtls.categoryID,
                  '',
                  '');
              await printController.printBill(
                  GlobalConfig.salesNo, 'Void Tables');
              showBFOC = false;
              showDisc = false;
              showFunc = false;
              showPromo = false;

              if (POSDtls.TBLManagement) {
                // TODO(Smith): Show table management screen
                state =
                    state.copyWith(operation: OPERATIONS.SHOW_TABLE_MANAGEMENT);
              } else {
                // TODO(Smith): reset status
                if (POSDtls.forceTable) {
                  // TODO(Smith): Show table number screen
                  state = state.copyWith(operation: OPERATIONS.SHOW_TABLE_NUM);
                }
              }
            }
          }
        } else {
          // TODO(Smith): Send Sales to Online Controller
        }
      } else {}
    } catch (e) {}
  }
}
