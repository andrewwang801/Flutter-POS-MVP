import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:raptorpos/home/repository/order/i_order_repository.dart';
import 'package:raptorpos/payment/repository/i_payment_repository.dart';
import '../common/widgets/bill_button_list.dart';
import '../common/widgets/checkout.dart';

import '../constants/color_constant.dart';
import '../constants/text_style_constant.dart';
import '../theme/theme_model.dart';

List<MaterialColor> functionColors = [
  Colors.green,
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.pink,
  Colors.blue,
  Colors.grey,
  Colors.teal,
];

class FakeSalesCategoryModel {
  final String? label;
  final int color;

  FakeSalesCategoryModel(this.label, this.color);
}

final List<FakeSalesCategoryModel> functions = [
  FakeSalesCategoryModel('DINE IN', 0),
  FakeSalesCategoryModel('TAKE AWAY', 0),
];

class SalesCategoryScreen extends StatefulWidget {
  SalesCategoryScreen({Key? key}) : super(key: key);

  @override
  State<SalesCategoryScreen> createState() => _SalesCategoryScreenState();
}

class _SalesCategoryScreenState extends State<SalesCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
        backgroundColor:
            themeNotifier.isDark ? backgroundDarkColor : backgroundColor,
        appBar: AppBar(
          title: Text('Raptor POS', style: titleTextDarkStyle),
          actions: [
            IconButton(
                icon: Icon(themeNotifier.isDark
                    ? Icons.nightlight_round
                    : Icons.wb_sunny),
                onPressed: () {
                  themeNotifier.isDark
                      ? themeNotifier.isDark = false
                      : themeNotifier.isDark = true;
                })
          ],
        ),
        body: Row(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 5.h,
                ),
                CheckOut(320.h),
                SizedBox(
                  height: 10.h,
                ),
                BillButtonList(
                  paymentRepository: GetIt.I<IPaymentRepository>(),
                  orderRepository: GetIt.I<IOrderRepository>(),
                ),
              ],
            ),
            SizedBox(
              width: 26.w,
            ),
            Column(
              children: [
                SizedBox(
                  height: 40.h,
                  child: Center(
                    child: Text(
                      "Sales Category",
                      style: bodyTextLightStyle.copyWith(
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: 600.w,
                    child: GridView.builder(
                      itemCount: functions.length,
                      itemBuilder: (BuildContext context, int index) {
                        var function = functions[index];
                        return InkWell(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                                color: functionColors[function.color],
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(3.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeNotifier.isDark
                                        ? backgroundDarkColor
                                        : Colors.white,
                                    spreadRadius: 1.0,
                                    blurRadius: 1.0,
                                  )
                                ]),
                            child: Center(
                              child: Text(function.label ?? "",
                                  textAlign: TextAlign.center,
                                  style: bodyTextLightStyle),
                            ),
                          ),
                        );
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 1,
                          mainAxisExtent: 60.h,
                          crossAxisSpacing: 1),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40.h,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
