import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/widgets/appbar.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/payment/provider/payment_state.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import 'package:raptorpos/common/extension/string_extension.dart';
import 'package:raptorpos/common/widgets/alert_dialog.dart';
import 'package:raptorpos/common/widgets/checkout.dart';
import 'package:raptorpos/common/widgets/numpad.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/payment/provider/payment_provider.dart';

import '../../floor_plan/presentation/floor_plan_screen.dart';

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

  @override
  void initState() {
    super.initState();

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
    bool isDark = ref.watch(themeProvider);
    OrderState state = ref.watch(orderProvoder);
    if (state is OrderSuccessState) {
      if (state.bills.isNotEmpty) {
        billTotal = state.bills[0];
      }
    }

    paymentState = ref.watch(paymentProvider);
    ref.listen<PaymentState>(paymentProvider, (prev, next) {
      if (next is PaymentSuccessState && next.paid) {
        switch (next.status) {
          case PaymentStatus.PAID:
            Get.back();
            break;
          case PaymentStatus.SEND_RECEIPT:
            break;
          case PaymentStatus.REPRINT:
            break;
          case PaymentStatus.CLOSE_RECIPT:
            break;
          case PaymentStatus.SHOW_ALERT:
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AppAlertDialog(
                    insetPadding: EdgeInsets.all(20),
                    title: 'Cash Payment',
                    message:
                        'Payment: $payment, Total Bill: $billTotal, Change: ${change.toStringAsFixed(2)}',
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
        }
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
          CheckOut(429.h),
          Expanded(child: _cashPayment(state)),
        ],
      ),
    );
  }

  Widget _cashPayment(OrderState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20.0),
          color: primaryDarkColor,
          child: Column(
            children: [
              SizedBox(
                width: 300.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Amount Due: ',
                      style: titleTextDarkStyle,
                      textAlign: TextAlign.left,
                    ),
                    Expanded(
                      child: Text(
                        state is OrderSuccessState && state.bills.isNotEmpty
                            ? '\$ ${state.bills[0].toStringAsFixed(2)}'
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
                      'Balance Due: ',
                      style: titleTextDarkStyle.copyWith(color: Colors.green),
                      textAlign: TextAlign.left,
                    ),
                    Expanded(
                      child: Text(
                        payment.toStringAsFixed(2).currencyString('\$'),
                        style: titleTextDarkStyle.copyWith(color: Colors.green),
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
                      'Change: ',
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
          height: 30.h,
        ),
        OrientationBuilder(
          builder: (context, orientation) {
            return SizedBox(
              width: orientation == Orientation.landscape ? 400.h : 300.w,
              height: orientation == Orientation.landscape ? 400.h : 300.w,
              child: NumPad(
                  buttonWidth:
                      orientation == Orientation.landscape ? 100.h : 75.w,
                  buttonHeight:
                      orientation == Orientation.landscape ? 100.h : 75.w,
                  delete: () {},
                  onSubmit: () {
                    doPayment(payment);
                  },
                  controller: _controller),
            );
          },
        )
      ],
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
              content: Text('Payment Cash Failed! Paid amount is not enough.'),
            );
          });
    }
  }
}
