import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/widgets/checkout_summary.dart';
import 'package:raptorpos/common/widgets/order_header.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/floor_plan/provider/table_provider.dart';
import 'package:raptorpos/functions/application/function_provider.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/payment/presentation/tender_screen.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';
import 'package:raptorpos/common/extension/workable.dart';

import '../../../constants/color_constant.dart';
import 'package:raptorpos/common/utils/presentation_util.dart';
import 'alert_dialog.dart';
import 'checkout_list.dart';

class CheckOut extends ConsumerStatefulWidget {
  const CheckOut({this.Callback, Key? key}) : super(key: key);
  final Function(OrderItemModel)? Callback;

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends ConsumerState<CheckOut> {
  final ScrollController _vScrollController = ScrollController();
  bool isDark = false;
  @override
  Widget build(BuildContext context) {
    ref.listen(orderProvoder, (previous, OrderState next) {
      if (next.workable == Workable.ready &&
          next.operation == OPERATIONS.SHOW_REMARKS) {
        PresentationUtil().showRemarksDialog(context);
      }
      if (next.failure != null && next.workable != Workable.failure) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                title: 'Error',
                isDark: isDark,
                message: next.failure!.errMsg,
                onConfirm: () {},
              );
            });
      }
    });

    isDark = ref.watch(themeProvider);
    OrderState state = ref.watch(orderProvoder);

    double totalTax = 0.0;
    if (state.workable == Workable.ready && state.bills != null) {
      for (var i = 4; i < state.bills!.length; i++) {
        totalTax += state.bills![i];
      }
    }
    return Scaffold(
      backgroundColor: isDark ? primaryDarkColor : Colors.white,
      body: Container(
        padding: EdgeInsets.all(Spacing.xs),
        // color: isDark
        //     ? primaryDarkColor.withOpacity(0.9)
        //     : Colors.white.withOpacity(1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Order(),
            OrderHeader(),
            Expanded(
                child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? primaryDarkColor : backgroundColor,
                    ),
                    child: CheckoutList(
                      callback: widget.Callback,
                    ))),
            verticalSpaceSmall,
            checkout_summary(isDark: isDark, state: state, totalTax: totalTax),
            CheckOutButtons(),
          ],
        ),
      ),
    );
  }

  Widget Order() {
    return ListTile(
      title: Text('Order'),
    );
  }

  Widget CheckOutButtons() {
    final OrderState state = ref.watch(orderProvoder);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              ref.read(functionProvider.notifier).voidAllOrder();
            },
            child: Text('Void'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(red),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.sm))),
            ),
          ),
        ),
        SizedBox(
          width: Spacing.sm,
        ),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              ref.read(tableProvider.notifier).holdTable();
            },
            child: Text('Hold'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(blue),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.sm))),
            ),
          ),
        ),
        SizedBox(
          width: Spacing.sm,
        ),
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: () {
              doTenderPayment(state);
            },
            child: Text('Check Out'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(orange),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.sm))),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> doTenderPayment(OrderState state) async {
    if (state.workable == Workable.ready) {
      if (state.bills?.isEmpty ?? false) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                title: 'Error',
                isDark: isDark,
                message: 'Order is empty!',
                onConfirm: () {},
              );
            });
        return;
      }
      if (state.paymentPermission ?? false) {
        final double sTotal = state.bills![2];
        final double gTotal = state.bills![0];
        // update order items in HeldItems table
        await ref.read(orderProvoder.notifier).updateHeldItem(sTotal, gTotal);
        // fetch updated order items
        ref.read(orderProvoder.notifier).fetchOrderItems();
        // Print
        Get.to(TenderScreen(
          gTotal: gTotal,
        ));
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                title: 'Error',
                isDark: isDark,
                message: 'Not allowed to pay!',
                onConfirm: () {},
              );
            });
      }
    } else {}
  }
}
