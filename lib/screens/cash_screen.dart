import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:raptorpos/widgets/home_screen/bill_button_list.dart';
import 'package:raptorpos/widgets/home_screen/checkout.dart';

import '../constants/color_constant.dart';
import '../constants/text_style_constant.dart';
import '../model/theme_model.dart';
import '../widgets/common/appbar.dart';
import '../widgets/common/header.dart';

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

final List<FunctionModel> cashMethods = [
  FunctionModel('CASH', 1),
  FunctionModel('CREDIT BCA', 1),
  FunctionModel('DEBIT LAIN', 1),
  FunctionModel('GO RESTO', 1),
  FunctionModel('GOPAY', 6),
  FunctionModel('GRAB', 6),
  FunctionModel('OVO', 6),
  FunctionModel('SHOPPE', 6),
  FunctionModel('SHOPPE FOOD', 6),
  FunctionModel('TRANSFER', 6),
  FunctionModel('VISA/MASTER', 7),
  FunctionModel('VOUCHER 100K', 7),
  FunctionModel('VOUCHER 50K', 7),
];

class CashScreen extends StatefulWidget {
  CashScreen({Key? key}) : super(key: key);

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
        backgroundColor:
            themeNotifier.isDark ? backgroundDarkColor : backgroundColor,
        appBar: appBarWidget(),
        body: Column(
          children: [
            const Header(
                transID: 'POS001',
                operator: 'EMENU',
                mode: 'REG',
                order: '4',
                cover: '1',
                rcp: 'A2200000082'),
            Expanded(
              child: Row(
                children: [
                  Column(
                    children: [
                      CheckOut(),
                      SizedBox(
                        height: 10.h,
                      ),
                      BillButtonList(),
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
                            'Cash Modes',
                            style: titleTextLightStyle.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        width: 600.w,
                        height: 127.h,
                        child: GridView.builder(
                          itemCount: cashMethods.length,
                          itemBuilder: (BuildContext context, int index) {
                            final function = cashMethods[index];
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
                                  child: Text(function.label ?? '',
                                      textAlign: TextAlign.center,
                                      style: bodyTextLightStyle),
                                ),
                              ),
                            );
                          },
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  mainAxisSpacing: 1,
                                  mainAxisExtent: 40.h,
                                  crossAxisSpacing: 1),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      SizedBox(
                        width: 600.w,
                        height: 150.h,
                        child: Row(
                          children: [
                            Container(
                              color: Colors.white,
                              width: 400.w,
                              height: 150.h,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        width: 80.w,
                                        height: 40.h,
                                        child: Center(
                                            child: Text('Deposits',
                                                textAlign: TextAlign.center,
                                                style: bodyTextLightStyle)),
                                      ),
                                      Container(
                                        color: Colors.white,
                                        width: 80.w,
                                        height: 40.h,
                                        child: Center(
                                            child: Text('FOC',
                                                textAlign: TextAlign.center,
                                                style: bodyTextLightStyle)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        width: 80.w,
                                        height: 40.h,
                                        child: Center(
                                            child: Text('Remove Payment',
                                                textAlign: TextAlign.center,
                                                style: bodyTextLightStyle)),
                                      ),
                                      Container(
                                        color: Colors.white,
                                        width: 80.w,
                                        height: 40.h,
                                        child: Center(
                                            child: Text('Back To Main',
                                                textAlign: TextAlign.center,
                                                style: bodyTextLightStyle)),
                                      ),
                                    ],
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
