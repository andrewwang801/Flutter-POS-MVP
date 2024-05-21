import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/adapters/order_data.dart';
import 'package:raptorpos/common/widgets/checkout_summary.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/presentation/widgets/menu_item_detail.dart';
import 'package:raptorpos/home/presentation/widgets/remark_dialog.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';
import 'package:raptorpos/common/extension/workable.dart';

import '../../../constants/color_constant.dart';
import '../../../constants/text_style_constant.dart';
import 'package:raptorpos/common/utils/presentation_util.dart';
import 'alert_dialog.dart';
import 'checkout_list.dart';

class CheckOut extends ConsumerStatefulWidget {
  const CheckOut(this.height, {this.Callback, Key? key}) : super(key: key);
  final double height;
  final Function(OrderItemModel)? Callback;

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends ConsumerState<CheckOut> {
  final ScrollController _vScrollController = ScrollController();
  bool isDark = true;
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
    return Container(
      width: Responsive.isMobile(context) ? 400.w : 320.w,
      height: widget.height,
      color: isDark
          ? primaryDarkColor.withOpacity(0.9)
          : Colors.white.withOpacity(0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Expanded(child: orderItemsTable()),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? primaryDarkColor : Colors.white,
                  ),
                  child: CheckoutList(
                    callback: widget.Callback,
                  ))),
          checkout_summary(isDark: isDark, state: state, totalTax: totalTax),
        ],
      ),
    );
  }

  Widget orderItemsTable() {
    OrderState state = ref.watch(orderProvoder);
    final OrderData orderData =
        OrderData(isDark, state.orderItems ?? <OrderItemModel>[], context);
    return Scrollbar(
      controller: _vScrollController,
      isAlwaysShown: false,
      child: SingleChildScrollView(
          controller: _vScrollController,
          physics: const ClampingScrollPhysics(),
          child: Theme(
            data: ThemeData(
              cardColor: isDark ? primaryDarkColor : Colors.white,
              dividerColor: isDark ? Color(0xff333333) : backgroundColor,
              textTheme: TextTheme(
                caption: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
            child: PaginatedDataTable(
              columnSpacing: 10.w,
              arrowHeadColor: isDark ? Colors.white : Colors.black,
              columns: <DataColumn>[
                DataColumn(
                    label: Text('QTY',
                        style:
                            isDark ? bodyTextDarkStyle : bodyTextLightStyle)),
                DataColumn(
                    label: Text('Descrption',
                        style:
                            isDark ? bodyTextDarkStyle : bodyTextLightStyle)),
                DataColumn(
                    label: Text('Amount',
                        style:
                            isDark ? bodyTextDarkStyle : bodyTextLightStyle)),
                DataColumn(
                    label: Text('Category',
                        style:
                            isDark ? bodyTextDarkStyle : bodyTextLightStyle)),
                DataColumn(
                    label: Text('Payment',
                        style:
                            isDark ? bodyTextDarkStyle : bodyTextLightStyle)),
              ],
              source: orderData,
              horizontalMargin: 6,
              rowsPerPage: 8,
              showCheckboxColumn: false,
            ),
          )),
    );
  }
}
