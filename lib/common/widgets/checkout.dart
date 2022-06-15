import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../../constants/color_constant.dart';
import '../../../constants/text_style_constant.dart';
import 'package:raptorpos/common/adapters/order_data.dart';

class CheckOut extends ConsumerStatefulWidget {
  CheckOut({Key? key}) : super(key: key);

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends ConsumerState<CheckOut> {
  final ScrollController _vScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    OrderState state = ref.watch(orderProvoder);

    double totalTax = 0.0;
    if (state is OrderSuccessState) {
      for (var i = 4; i < state.bills.length; i++) {
        totalTax += state.bills[i];
      }
    }
    return Container(
      width: 320.w,
      height: 320.h,
      color: isDark ? primaryDarkColor : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: orderItemsTable()),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text("STotal:",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text("Disc:",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text("Tax:",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text("Svc+ST:",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text("PPN 10%:",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text("GTotal:",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                          state is OrderSuccessState
                              ? '\$ ${state.bills[2].toStringAsFixed(2)}'
                              : "\$ 0.00",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                          state is OrderSuccessState
                              ? '\$ ${state.bills[3].toStringAsFixed(2)}'
                              : "\$ 0.00",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                          state is OrderSuccessState
                              ? '\$ $totalTax'
                              : "\$ 0.00",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text("\$ 0.00",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text("\$ 0.00",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                          state is OrderSuccessState
                              ? '\$ ${state.bills[0].toStringAsFixed(2)}'
                              : "\$ 0.00",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget orderItemsTable() {
    bool isDark = ref.watch(themeProvider);
    OrderState state = ref.watch(orderProvoder);
    final OrderData orderData = OrderData(
        isDark,
        state is OrderSuccessState ? state.orderItems : <OrderItemModel>[],
        context);
    return Scrollbar(
      controller: _vScrollController,
      isAlwaysShown: true,
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
              ],
              source: orderData,
              horizontalMargin: 6,
              rowsPerPage: 7,
              showCheckboxColumn: false,
            ),
          )),
    );
  }
}
