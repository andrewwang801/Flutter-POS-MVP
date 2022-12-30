import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/GlobalConfig.dart';
import 'package:raptorpos/common/constants/strings.dart';
import 'package:raptorpos/common/extension/string_extension.dart';
import 'package:raptorpos/common/widgets/checkout_summary.dart';
import 'package:raptorpos/common/widgets/order_header.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/floor_plan/presentation/floor_plan_screen.dart';
import 'package:raptorpos/floor_plan/presentation/widgets/cover_widget.dart';
import 'package:raptorpos/floor_plan/provider/table_provider.dart';
import 'package:raptorpos/floor_plan/provider/table_state.dart';
import 'package:raptorpos/functions/application/function_provider.dart';
import 'package:raptorpos/functions/application/function_state.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/payment/presentation/mobile_tender_screen.dart';
import 'package:raptorpos/payment/presentation/tender_screen.dart';
import 'package:raptorpos/payment/provider/payment_provider.dart';
import 'package:raptorpos/payment/provider/payment_state.dart';
import 'package:raptorpos/print/provider/print_provider.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';
import 'package:raptorpos/common/extension/workable.dart';

import '../../../constants/color_constant.dart';
import '../../../constants/text_style_constant.dart';
import 'package:raptorpos/common/utils/presentation_util.dart';
import '../alert_dialog.dart';
import '../checkout_list.dart';

class MobileCheckout extends ConsumerStatefulWidget {
  const MobileCheckout({this.Callback, Key? key}) : super(key: key);
  final Function(OrderItemModel)? Callback;

  @override
  _MobileCheckoutState createState() => _MobileCheckoutState();
}

class _MobileCheckoutState extends ConsumerState<MobileCheckout> {
  final ScrollController _vScrollController = ScrollController();
  bool isDark = false;

  double payment = 0.0;
  double change = 0.0;
  double billTotal = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    OrderState state = ref.watch(orderProvoder);
    List<OrderItemModel> orderItems = <OrderItemModel>[];

    if (state.workable == Workable.ready) {
      if (state.bills?.isNotEmpty ?? false) {
        billTotal = state.bills![0];
        orderItems.addAll(state.orderItems ?? []);
      }
    }

    ref.listen(tableProvider, (Object? previous, Object? next) {
      if (next is TableSuccessState) {
        if (next.notify_type == NOTIFY_TYPE.SHOW_COVER) {
          showDialog(
              context: context,
              builder: (context) {
                return IntrinsicHeight(
                  child: IntrinsicWidth(
                    child: Dialog(
                      backgroundColor:
                          isDark ? primaryDarkColor : backgroundColorVariant,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.sm)),
                      child: CoverWidget(
                        callback: (int tableNo) {
                          ref
                              .read(tableProvider.notifier)
                              .tableNoNotify(tableNo.toString());
                        },
                      ),
                    ),
                  ),
                );
              });
        } else if (next.notify_type == NOTIFY_TYPE.GOTO_TABLE_LAYOUT) {
          Get.to(FloorPlanScreen());
        }
      }
      if (next is TableErrorState) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                title: 'Error',
                isDark: isDark,
                message: next.errMsg,
                onConfirm: () {},
              );
            });
      }
    });

    ref.listen(functionProvider, (previous, FunctionState next) {
      if (next.failiure != null) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                isDark: isDark,
                message: next.failiure!.errMsg,
              );
            });
      }
    });
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

    ref.listen<PaymentState>(paymentProvider, (prev, next) async {
      if (next is PaymentSuccessState && (next.paid ?? false)) {
        switch (next.status) {
          case PaymentStatus.PAID:
            ref
                .read(printProvider.notifier)
                .printBill(GlobalConfig.salesNo, 'Close Tables');
            Get.back();
            Get.to(FloorPlanScreen());
            break;
          case PaymentStatus.SEND_RECEIPT:
            break;
          case PaymentStatus.REPRINT:
            break;
          case PaymentStatus.CLOSE_RECIPT:
            break;
          case PaymentStatus.SHOW_ALERT:
          case null:
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AppAlertDialog(
                    insetPadding: EdgeInsets.all(20),
                    title: k_cash_payment,
                    isDark: isDark,
                    message:
                        '$k_payment: $payment, $k_total_bill: $billTotal, $k_change: ${change.toStringAsFixed(2)}',
                    onCancel: () {},
                    onConfirm: () {
                      ref
                          .read(paymentProvider.notifier)
                          .updatePaymentStatus(PaymentStatus.PAID);
                    },
                  );
                });
            break;
          case PaymentStatus.NONE:
            break;
          case PaymentStatus.PAYMENT_REMOVED:
            break;
          case PaymentStatus.PERMISSION_ERROR:
            break;
        }
      } else if (next is PaymentErrorState) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                insetPadding: EdgeInsets.all(20),
                title: 'Error',
                isDark: isDark,
                message: next.msg,
                onConfirm: () {
                  ref
                      .read(paymentProvider.notifier)
                      .updatePaymentStatus(PaymentStatus.PAID);
                },
              );
            });
      }
    });

    isDark = ref.watch(themeProvider);
    OrderState orderState = ref.watch(orderProvoder);

    double totalTax = 0.0;
    if (state.workable == Workable.ready && state.bills != null) {
      for (var i = 4; i < state.bills!.length; i++) {
        totalTax += orderState.bills![i];
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? primaryLightColor : primaryDarkColor,
          ),
        ),
        titleSpacing: 0,
        title: Text(
          'Detail Payment',
          style: isDark ? normalTextDarkStyle : normalTextLightStyle,
        ),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () {
              // ref.read(functionProvider.notifier).voidAllOrder();
              ref.read(orderProvoder.notifier).voidOrderItem(orderItems.last);
              orderItems.removeLast();
            },
            child: Container(
              padding: EdgeInsets.all(16),
              width: 55,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: red),
                  borderRadius: BorderRadius.circular(Spacing.xs),
                ),
                child: Icon(
                  Icons.close,
                  color: red,
                  size: 16,
                ),
              ),
            ),
          ),
          // IconButton(
          //     icon: Icon(
          //       isDark ? Icons.wb_sunny : Icons.nightlight_round,
          //     ),
          //     color: isDark ? backgroundColor : primaryDarkColor,
          //     onPressed: () {
          //       isDark ? isDark = false : isDark = true;
          //       ref.read(themeProvider.notifier).setTheme(isDark);
          //     }),
        ],
      ),
      body: ScreenUtil().orientation == Orientation.landscape
          ? landscape(state, totalTax)
          : portait(state, totalTax),
    );
  }

  Widget landscape(OrderState state, double totalTax) {
    return SafeArea(
      bottom: false,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(Spacing.sm),
                  child: Row(
                    children: [
                      horizontalSpaceSmall,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${GlobalConfig.TransMode}',
                            style:
                                isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                            textAlign: TextAlign.left,
                          ),
                          verticalSpaceTiny,
                          Text(
                            'Table ${GlobalConfig.tableNo}',
                            style: isDark
                                ? normalTextDarkStyle.copyWith(
                                    fontWeight: FontWeight.bold)
                                : normalTextLightStyle.copyWith(
                                    fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Text(
                          '${GlobalConfig.rcptNo}',
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(Spacing.xs),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Order(),
                        OrderHeader(),
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? backgroundDarkColor
                                      : backgroundColor,
                                ),
                                child: CheckoutList(
                                  callback: widget.Callback,
                                ))),
                        Container(
                          color: isDark ? backgroundDarkColor : backgroundColor,
                          height: MediaQuery.of(context).padding.bottom,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                verticalSpaceSmall,
                checkout_summary(
                    isDark: isDark, state: state, totalTax: totalTax),
                CheckOutButtons(),
                Container(
                  color: isDark ? backgroundDarkColor : backgroundColor,
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget portait(OrderState state, double totalTax) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(Spacing.sm),
                  child: Row(
                    children: [
                      horizontalSpaceSmall,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${GlobalConfig.TransMode}',
                            style:
                                isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                            textAlign: TextAlign.left,
                          ),
                          verticalSpaceTiny,
                          Text(
                            'Table ${GlobalConfig.tableNo}',
                            style: isDark
                                ? normalTextDarkStyle.copyWith(
                                    fontWeight: FontWeight.bold)
                                : normalTextLightStyle.copyWith(
                                    fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Text(
                          '${GlobalConfig.rcptNo}',
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(Spacing.xs),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Order(),
                        OrderHeader(),
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? backgroundDarkColor
                                      : Colors.white,
                                ),
                                child: CheckoutList(
                                  callback: widget.Callback,
                                ))),
                        verticalSpaceSmall,
                        checkout_summary(
                            isDark: isDark, state: state, totalTax: totalTax),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          CheckOutButtons(),
          Container(
            color: isDark ? primaryDarkColor : backgroundColorVariant,
            height: MediaQuery.of(context).padding.bottom,
          ),
        ],
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

    return Container(
      color: isDark
          ? ScreenUtil().orientation == Orientation.landscape
              ? backgroundDarkColor
              : primaryDarkColor
          : ScreenUtil().orientation == Orientation.landscape
              ? backgroundColor
              : backgroundColorVariant,
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          Material(
            color: isDark ? backgroundDarkColor : backgroundColorVariant,
            borderRadius: BorderRadius.circular(Spacing.xs),
            child: ListTile(
              // leading: Checkbox(
              //   value: true,
              //   onChanged: (bool? value) {},
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(Spacing.xs),
              //   ),
              //   activeColor: lightBlue,
              //   checkColor: blue,
              // ),
              title: Text('Tender'),
              trailing: Icon(Icons.edit),
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.sm),
                side: BorderSide(width: 1, color: lightBlue),
              ),
              onTap: () {
                Get.to(MobileTenderScreen(gTotal: billTotal));
              },
            ),
          ),
          verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 65.h,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(tableProvider.notifier).holdTable();
                    },
                    child: Text('Hold'),
                    style: ElevatedButton.styleFrom(
                      primary: blue,
                      padding: EdgeInsets.all(Spacing.sm),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.sm)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: Spacing.sm,
              ),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 64.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      // doTenderPayment(state);
                      // Print
                      ref.read(printProvider.notifier).kpPrint();
                      // End of Print
                      doPayment(billTotal);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Check Out',
                          style: isDark
                              ? listItemTextDarkStyle
                              : listItemTextLightStyle.copyWith(
                                  color: Colors.white),
                        ),
                        Spacer(),
                        Text(
                          '234'.currencyString('\$'),
                          style: isDark
                              ? normalTextDarkStyle
                              : normalTextLightStyle.copyWith(
                                  color: Colors.white),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(Spacing.sm),
                      primary: orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.sm)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Future<void> doPayment(double payment) async {
    if (payment >= billTotal) {
      const int payType = 5;
      if (payment.toString().length > 21) {
        payment = (payment.toString().substring(0, 18)).toDouble();
      }
      await ref.read(paymentProvider.notifier).doPayment(payType, payment);
      await ref.read(orderProvoder.notifier).fetchOrderItems();
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AppAlertDialog(
              isDark: isDark,
              content: Text(message_payment_cash_failed),
            );
          });
    }
  }
}
