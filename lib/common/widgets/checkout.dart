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
  const CheckOut(this.height, {Key? key}) : super(key: key);
  final double height;

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends ConsumerState<CheckOut> {
  final ScrollController _vScrollController = ScrollController();
  bool isDark = true;
  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);
    OrderState state = ref.watch(orderProvoder);

    double totalTax = 0.0;
    if (state is OrderSuccessState) {
      for (var i = 4; i < state.bills.length; i++) {
        totalTax += state.bills[i];
      }
    }
    return Container(
      width: 320.w,
      height: widget.height,
      color: isDark ? primaryDarkColor : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Expanded(child: orderItemsTable()),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    color: primaryDarkColor,
                  ),
                  child: _orderItemList())),
          Container(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("STotal:",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("Disc:",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("Tax:",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("Svc+ST:",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("PPN 10%:",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("GTotal:",
                          style: isDark
                              ? bodyTextDarkStyle.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)
                              : bodyTextLightStyle.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
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
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                          state is OrderSuccessState && state.bills.isNotEmpty
                              ? '\$ ${state.bills[2].toStringAsFixed(2)}'
                              : "\$ 0.00",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                          state is OrderSuccessState && state.bills.isNotEmpty
                              ? '\$ ${state.bills[3].toStringAsFixed(2)}'
                              : "\$ 0.00",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                          state is OrderSuccessState && state.bills.isNotEmpty
                              ? '\$ ${totalTax.toStringAsFixed(2)}'
                              : "\$ 0.00",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("\$ 0.00",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("\$ 0.00",
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                          state is OrderSuccessState && state.bills.isNotEmpty
                              ? '\$ ${state.bills[0].toStringAsFixed(2)}'
                              : "\$ 0.00",
                          style: isDark
                              ? bodyTextDarkStyle.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)
                              : bodyTextLightStyle.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
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
    OrderState state = ref.watch(orderProvoder);
    final OrderData orderData = OrderData(
        isDark,
        state is OrderSuccessState ? state.orderItems : <OrderItemModel>[],
        context);
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

  Widget _orderItemList() {
    final OrderState state = ref.watch(orderProvoder);
    final bool isLoading =
        state is OrderLoadingState || state is OrderInitialState;
    final bool hasError = state is OrderErrorState;
    if (isLoading) {
      return Container();
    } else if (hasError) {
      return Container();
    } else if (state is OrderSuccessState) {
      if (state.orderItems == null) {
        return Container();
      } else {
        return ListView.separated(
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemCount: state.orderItemTree!.length,
            itemBuilder: (BuildContext context, int index) {
              return state.orderItemTree![index].render(context, 4);
            });
      }
    } else {
      return Container();
    }
  }
}
