import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/cash/presentation/cash_screen.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/floor_plan/presentation/floor_plan_screen.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import 'package:raptorpos/trans/presentation/trans.dart';
import 'package:raptorpos/sales_category/sales_category_screen.dart';
import './custom_button.dart';

class BillButtonList extends ConsumerStatefulWidget {
  BillButtonList({Key? key}) : super(key: key);

  @override
  _BillButtonListState createState() => _BillButtonListState();
}

class _BillButtonListState extends ConsumerState<BillButtonList> {
  final List<String> billBtnTexts = [
    "CASH",
    "TENDER",
    "Print Bill",
    "DINE-IN",
    "DISC",
    "PROMO",
    "VOID",
  ];
  // "TENDER",
  // "SUBTOTAL",
  // "TABLE/HOLD",

  @override
  Widget build(BuildContext context) {
    bool isDark = ref.read(themeProvider);
    return SizedBox(
      width: 260.w,
      height: 40.h,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: billBtnTexts.length,
        itemBuilder: (BuildContext context, int index) {
          return CustomButton(
            callback: () {
              switch (index) {
                case 0:
                  Get.to(CashScreen());
                  break;
                case 1:
                  break;
                case 2:
                  break;
                case 3:
                  Get.to(FloorPlanScreen());
                  break;
                case 4:
                  Get.to(ViewTransScreen());
                  break;
                case 5:
                  Get.to(SalesCategoryScreen());
                  break;
                default:
                  Get.to(ViewTransScreen());
                  break;
              }
            },
            text: billBtnTexts[index],
            fillColor: isDark ? primaryDarkColor : Colors.white,
            borderColor: isDark ? primaryDarkColor : Colors.green,
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisExtent: 84.w,
          mainAxisSpacing: 3.w,
        ),
      ),
    );
  }
}
