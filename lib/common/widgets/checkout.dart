import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/adapters/order_data.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/presentation/widgets/remark_dialog.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';
import 'package:raptorpos/common/extension/workable.dart';

import '../../../constants/color_constant.dart';
import '../../../constants/text_style_constant.dart';
import 'alert_dialog.dart';

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
        showRemarksDialog();
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
      width: Responsive.isMobile(context)
          ? 400.w -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom
          : 320.w,
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
                  child: _orderItemList())),
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "STotal:",
                          style: isDark
                              ? normalTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : normalTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Disc:",
                          style: isDark
                              ? normalTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : normalTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Tax:",
                          style: isDark
                              ? normalTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : normalTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text("GTotal:",
                            style: isDark
                                ? normalTextDarkStyle.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)
                                : normalTextLightStyle.copyWith(
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
                          (state.bills?.isNotEmpty ?? false)
                              ? '\$ ${state.bills![2].toStringAsFixed(2)}'
                              : "\$ 0.00",
                          style: isDark
                              ? normalTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : normalTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          (state.bills?.isNotEmpty ?? false)
                              ? '\$ ${state.bills![3].toStringAsFixed(2)}'
                              : "\$ 0.00",
                          style: isDark
                              ? normalTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : normalTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          (state.bills?.isNotEmpty ?? false)
                              ? '\$ ${totalTax.toStringAsFixed(2)}'
                              : "\$ 0.00",
                          style: isDark
                              ? normalTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : normalTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                            (state.bills?.isNotEmpty ?? false)
                                ? '\$ ${state.bills![0].toStringAsFixed(2)}'
                                : "\$ 0.00",
                            style: isDark
                                ? normalTextDarkStyle.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)
                                : normalTextLightStyle.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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

  Widget _orderItemList() {
    final OrderState state = ref.watch(orderProvoder);
    final bool isLoading = state.workable == Workable.loading ||
        state.workable == Workable.initial;
    final bool hasError =
        state.workable == Workable.failure && state.failure != null;
    if (isLoading) {
      return Container();
    } else if (hasError) {
      return Container();
    } else if (state.workable == Workable.ready) {
      return Column(
        children: [
          ListTileTheme(
            contentPadding: EdgeInsets.zero,
            dense: true,
            child: ExpansionTile(
              title: Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10.w),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Text(
                          'QTY',
                          textAlign: TextAlign.left,
                          style: isDark
                              ? listItemTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : listItemTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Text(
                          'Description',
                          textAlign: TextAlign.left,
                          style: isDark
                              ? listItemTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : listItemTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Text(
                          'Price',
                          textAlign: TextAlign.left,
                          style: isDark
                              ? listItemTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : listItemTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Text(
                          'SC',
                          textAlign: TextAlign.left,
                          style: isDark
                              ? listItemTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : listItemTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: SizedBox(width: 10.w),
            ),
          ),
          Expanded(
            child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemCount: state.orderItemTree!.length,
                itemBuilder: (BuildContext context, int index) {
                  return state.orderItemTree![index].render(
                    context,
                    4,
                    isDark,
                    () {
                      setState(() {
                        ref.read(orderProvoder.notifier).voidOrderItem(
                            state.orderItemTree![index].orderItem);
                        // state.orderItemTree!.removeAt(index);
                      });
                    },
                    clickListener: widget.Callback,
                  );
                }),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  // Show Remarks Dialog
  showRemarksDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RemarksDialog();
        });
  }
}
