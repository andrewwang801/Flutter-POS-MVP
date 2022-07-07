import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:raptorpos/home/repository/order/i_order_repository.dart';
import 'package:raptorpos/payment/repository/i_payment_repository.dart';
import '../../constants/color_constant.dart';
import '../../theme/theme_model.dart';
import '../../common/widgets//bill_button_list.dart';
import '../../common/widgets//checkout.dart';

import '../../constants/text_style_constant.dart';
import '../../transfer_items/transfer_items_screen.dart';
import '../../trans/presentation/trans.dart';

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

class FunctionModel {
  final String? label;
  final int color;

  FunctionModel(this.label, this.color);
}

final List<FunctionModel> functions = <FunctionModel>[
  FunctionModel('All Void', 6),
  FunctionModel('Change Category', 6),
  FunctionModel('Change Cover', 6),
  FunctionModel('Kitchen Talk', 6),
  FunctionModel('Preview Bill', 6),
  FunctionModel('Transfer Items', 6),
  FunctionModel('Remarks', 6),
  FunctionModel('Split Bill', 5),
  FunctionModel('View Trans', 5),
  FunctionModel('X Day', 5),
  FunctionModel('XZ Report', 5),
];

class FunctionsScreen extends StatefulWidget {
  FunctionsScreen({Key? key}) : super(key: key);

  @override
  State<FunctionsScreen> createState() => _FunctionsScreenState();
}

class _FunctionsScreenState extends State<FunctionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder:
        (BuildContext context, ThemeModel themeNotifier, Widget? child) {
      return Scaffold(
        backgroundColor: themeNotifier.isDark
            ? backgroundDarkColor
            : const Color.fromARGB(255, 244, 238, 233),
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
                      'Functions',
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
                        final FunctionModel function = functions[index];
                        return InkWell(
                          onTap: () {
                            switch (index) {
                              case 5:
                                Get.to(TransferItemsScreen());
                                break;
                              case 8:
                                Get.to(ViewTransScreen());
                                break;
                              case 17:
                                break;
                              default:
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: functionColors[function.color],
                                border: Border.all(
                                  color: Colors.green,
                                ),
                                borderRadius: BorderRadius.circular(3.0),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: themeNotifier.isDark
                                        ? backgroundDarkColor
                                        : Colors.white,
                                    spreadRadius: 1.0,
                                    blurRadius: 1.0,
                                  )
                                ]),
                            child: Center(
                              child: Text(function.label ?? '',
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
