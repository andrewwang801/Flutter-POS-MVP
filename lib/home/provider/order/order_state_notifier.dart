import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:raptorpos/common/extension/string_extension.dart';
import 'package:raptorpos/home/model/order_item_model.dart';

import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/home/repository/order/i_order_repository.dart';

@Injectable()
class OrderStateNotifier extends StateNotifier<OrderState> {
  final IOrderRepository orderRepository;

  OrderStateNotifier(this.orderRepository) : super(OrderInitialState());

  // create order item
  void addOrderItem(String posID, int operatorNo, String tablNo, int salesNo,
      int splitNo, String pluNo, int cover, double qty, int catId) async {
    DateTime now = DateTime.now();
    String strCurDate = DateFormat('yyyy-MM-dd').format(now);
    String strCurTime = DateFormat('HH:mm:ss.0').format(now);

    state = OrderInitialState();
    try {
      List<int> taxs = await orderRepository.getTaxFromSC(catId);

      int pluCnt = await orderRepository.countPLU(pluNo, 1);
      if (pluCnt == 0) {
        state = OrderErrorState(errMsg: 'Can not find the PLU: $pluNo');
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
          //orderRepository.updateSoldPLU(1, pluNo);
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
            ItemAmount: amount.toInt(),
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
          orderRepository.insertOrderItem(orderItem);
          // end of insert order item
          state = OrderSuccessState(
              await orderRepository.fetchOrderItems(), await calcBill());
        }
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      state = OrderErrorState(errMsg: e.toString());
    }
  }

  void updateOrderItem() {}

  void addModifier() {}

  void prepOrderItem() {}

  void focOrderItem() {}

  // calc bill
  Future<List<double>> calcBill() async {
    if (true /* checkItemOrder */) {
      var paymentData = await orderRepository.fetchAmountOrder(1, 1, 3, false);
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

  void fetchOrderItems() async {
    try {
      state = OrderSuccessState(
          await orderRepository.fetchOrderItems(), await calcBill());
    } catch (e) {
      print('Error: ${e.toString()}');
      state = OrderErrorState(errMsg: e.toString());
    }
  }
}
