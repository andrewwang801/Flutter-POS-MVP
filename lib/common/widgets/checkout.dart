import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../../constants/color_constant.dart';
import '../../../constants/text_style_constant.dart';
import 'package:raptorpos/common/adapters/order_data.dart';

class CheckOut extends ConsumerStatefulWidget {
  CheckOut({Key? key}) : super(key: key);

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends ConsumerState<CheckOut> {
  final ScrollController _vScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    return Container(
      width: 300.w,
      height: 280.h,
      color: isDark ? backgroundDarkColor : backgroundColor,
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
                            style: isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
                        Text("Disc:",
                            style: isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
                        Text("Sc:",
                            style: isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
                        Text("Svc+ST:",
                            style: isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
                        Text("PPN 10%:",
                            style: isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
                        Text("GTotal:",
                            style: isDark
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
                            style: isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
                        Text("\$0.00",
                            style: isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
                        Text("\$0.00",
                            style: isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
                        Text("\$0.00",
                            style: isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
                        Text("\$0.00",
                            style: isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
                        Text("\$0.00",
                            style: isDark
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
  }

  Widget orderItemsTable() {
    bool isDark = ref.watch(themeProvider);
    final OrderData orderData = OrderData(isDark);
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
                        style:
                            isDark ? bodyTextDarkStyle : bodyTextLightStyle)),
                DataColumn(
                    label: Text('Descrption',
                        style:
                            isDark ? bodyTextDarkStyle : bodyTextLightStyle)),
                DataColumn(
                    label: Text('Table',
                        style:
                            isDark ? bodyTextDarkStyle : bodyTextLightStyle)),
              ],
              source: orderData,
              columnSpacing: 60,
              horizontalMargin: 10,
              rowsPerPage: 5,
              showCheckboxColumn: false,
            ),
          )),
    );
  }
}
