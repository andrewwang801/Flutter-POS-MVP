import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../data_source/order_data.dart';
import '../../model/theme_model.dart';

class CheckOut extends StatefulWidget {
  CheckOut({Key? key}) : super(key: key);

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  final ScrollController _vScrollController = ScrollController();
  final OrderData orderData = OrderData();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Container(
        width: 300.w,
        height: 280.h,
        color: themeNotifier.isDark ? backgroundDarkColor : backgroundColor,
        child: Column(
          children: [
            Expanded(child: orderItemsTable()),
            Center(
              child: Container(
                padding: EdgeInsets.all(10.h),
                width: 200.w,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("STotal:",
                              style: themeNotifier.isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle),
                          Text("Disc:",
                              style: themeNotifier.isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle),
                          Text("Sc:",
                              style: themeNotifier.isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle),
                          Text("Svc+ST:",
                              style: themeNotifier.isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle),
                          Text("PPN 10%:",
                              style: themeNotifier.isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle),
                          Text("GTotal:",
                              style: themeNotifier.isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$65,000',
                              style: themeNotifier.isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle),
                          Text("\$0.00",
                              style: themeNotifier.isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle),
                          Text("\$0.00",
                              style: themeNotifier.isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle),
                          Text("\$0.00",
                              style: themeNotifier.isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle),
                          Text("\$0.00",
                              style: themeNotifier.isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle),
                          Text("\$0.00",
                              style: themeNotifier.isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget orderItemsTable() {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Scrollbar(
        controller: _vScrollController,
        isAlwaysShown: true,
        child: SingleChildScrollView(
            controller: _vScrollController,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              child: PaginatedDataTable(
                columns: <DataColumn>[
                  DataColumn(
                      label: Text('QTY',
                          style: themeNotifier.isDark
                              ? bodyTextDarkStyle
                              : bodyTextLightStyle)),
                  DataColumn(
                      label: Text('Descrption',
                          style: themeNotifier.isDark
                              ? bodyTextDarkStyle
                              : bodyTextLightStyle)),
                  DataColumn(
                      label: Text('Table',
                          style: themeNotifier.isDark
                              ? bodyTextDarkStyle
                              : bodyTextLightStyle)),
                ],
                source: orderData,
                columnSpacing: 60,
                horizontalMargin: 10,
                rowsPerPage: 5,
                showCheckboxColumn: false,
              ),
            )),
      );
    });
  }
}
