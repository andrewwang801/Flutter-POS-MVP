import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/GlobalConfig.dart';
import '../../common/constants/strings.dart';
import '../../common/extension/string_extension.dart';
import '../../common/extension/workable.dart';
import '../../common/widgets/alert_dialog.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/checkout.dart';
import '../../common/widgets/numpad.dart';
import '../../common/widgets/responsive.dart';
import '../../constants/color_constant.dart';
import '../../constants/dimension_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../floor_plan/presentation/floor_plan_screen.dart';
import '../../home/provider/order/order_provider.dart';
import '../../home/provider/order/order_state.dart';
import '../../print/provider/print_provider.dart';
import '../../print/provider/print_state.dart';
import '../../printer/provider/printer_provider.dart';
import '../../theme/theme_state_notifier.dart';
import '../provider/payment_provider.dart';
import '../provider/payment_state.dart';

class CashScreen extends ConsumerStatefulWidget {
  CashScreen({Key? key}) : super(key: key);

  @override
  _CashScreenState createState() => _CashScreenState();
}

class _CashScreenState extends ConsumerState<CashScreen> {
  double payment = 0.0;
  double change = 0.0;
  double billTotal = 0.0;
  TextEditingController _controller = TextEditingController();

  late PaymentState paymentState;
  late bool isDark;

  @override
  void initState() {
    super.initState();

    // Print
    ref.read(printProvider.notifier).kpPrint();
    // End of Print

    _controller.addListener(() {
      setState(() {
        payment = _controller.text.toDouble();
        if (payment > billTotal)
          change = payment - billTotal;
        else
          change = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);
    OrderState state = ref.watch(orderProvoder);
    if (state.workable == Workable.ready) {
      if (state.bills?.isNotEmpty ?? false) {
        billTotal = state.bills![0];
      }
    }

    ref.listen(printProvider, (previous, next) {
      if (next is PrintSuccessState) {
      } else if (next is PrintErrorState) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                insetPadding: EdgeInsets.all(20),
                title: 'Error',
                message: next.errMsg,
                onConfirm: () {},
              );
            });
      }
    });
    paymentState = ref.watch(paymentProvider);

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

    return Scaffold(
      backgroundColor: isDark ? backgroundDarkColor : backgroundColor,
      appBar: PreferredSize(
        child: AppBarWidget(true),
        preferredSize: Size.fromHeight(AppBar().preferredSize.height),
      ),
      body: Row(
        children: [
          CheckOut(
            428.h -
                ScreenUtil().statusBarHeight -
                AppBar().preferredSize.height,
          ),
          Expanded(child: SafeArea(child: _cashPayment(state))),
        ],
      ),
    );
  }

  Widget _cashPayment(OrderState state) {
    double numpadHeight =
        200.h - ScreenUtil().bottomBarHeight - ScreenUtil().statusBarHeight;

    return Container(
      height:
          428.h - ScreenUtil().bottomBarHeight - ScreenUtil().statusBarHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Responsive.isMobile(context) ? verticalSpaceTiny : verticalSpaceLarge,
          Container(
            padding: EdgeInsets.all(20.0),
            color: isDark ? primaryDarkColor : primaryLightColor,
            child: Column(
              children: [
                SizedBox(
                  width: 300.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '$k_amount_due: ',
                        style: titleTextDarkStyle,
                        textAlign: TextAlign.left,
                      ),
                      Expanded(
                        child: Text(
                          (state.bills?.isNotEmpty ?? false)
                              ? '\$ ${state.bills![0].toStringAsFixed(2)}'
                              : '\$ 0.00',
                          style: titleTextDarkStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                  width: 300.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '$k_balance_due: ',
                        style: titleTextDarkStyle,
                        textAlign: TextAlign.left,
                      ),
                      Expanded(
                        child: Text(
                          payment.toStringAsFixed(2).currencyString('\$'),
                          style: titleTextDarkStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                  width: 300.w,
                  child: Row(
                    children: [
                      Text(
                        '$k_change: ',
                        style: titleTextDarkStyle.copyWith(color: Colors.red),
                        textAlign: TextAlign.left,
                      ),
                      Expanded(
                        child: Text(
                          change.toStringAsFixed(2).currencyString('\$'),
                          style: titleTextDarkStyle.copyWith(color: Colors.red),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: Responsive.isMobile(context) ? 10.h : 30.h,
          ),
          Expanded(
            child: SizedBox(
              width: 270.w,
              height: numpadHeight,
              child: NumPad(
                  buttonColor:
                      isDark ? primaryButtonDarkColor : primaryButtonColor,
                  delete: () {},
                  onSubmit: () {
                    doPayment(payment);
                  },
                  controller: _controller),
            ),
          ),
          Responsive.isMobile(context) ? verticalSpaceTiny : verticalSpaceLarge,
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
            return const AppAlertDialog(
              content: Text(message_payment_cash_failed),
            );
          });
    }
  }
}
