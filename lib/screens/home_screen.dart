import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../constants/color_constant.dart';
import '../model/theme_model.dart';
import '../widgets/common/appbar.dart';
import '../widgets/common/header.dart';
import '../widgets/common/numpad.dart';
import '../widgets/home_screen/bill_button_list.dart';
import '../widgets/home_screen/checkout.dart';
import '../widgets/home_screen/main_button_list.dart';
import '../widgets/home_screen/menu_item_list.dart';
import '../widgets/home_screen/menu_list.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _myController = TextEditingController();
  var _showNumPad = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
        backgroundColor:
            themeNotifier.isDark ? backgroundDarkColor : backgroundColor,
        appBar: appBarWidget(false),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _showNumPad = !_showNumPad;
            });
          },
          child: Icon(Icons.numbers),
        ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 0.h,
                      ),
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 5.h,
                              ),
                              SizedBox(
                                height: 30.h,
                                child: MenuList(),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Container(
                                height: 230.h,
                                width: 600.w,
                                child: MenuItemList(),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              MainButtonList(),
                            ],
                          ),
                          if (_showNumPad)
                            Positioned(
                              right: 20.w,
                              bottom: 45.h,
                              child: NumPad(
                                  delete: () {},
                                  onSubmit: () {},
                                  controller: _myController),
                            ),
                        ],
                      ),
                    ),
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
