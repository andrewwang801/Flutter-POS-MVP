import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/screens/cash_screen.dart';
import 'package:raptorpos/screens/floor_plan_screen.dart';
import 'package:raptorpos/screens/view_trans/viewtrans_screen.dart';

import '../../screens/sales_category_screen.dart';
import '../common/custom_button.dart';

final List<String> btnTexts = [
  "CASH",
  "TENDER",
  "SUBTOTAL",
  "TABLE/HOLD",
  "View Trans",
  "DINE-IN",
];

class BillButtonList extends StatefulWidget {
  BillButtonList({Key? key}) : super(key: key);

  @override
  State<BillButtonList> createState() => _BillButtonListState();
}

class _BillButtonListState extends State<BillButtonList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 246.w,
      height: 70.h,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
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
            text: btnTexts[index],
            borderColor: Colors.green,
            fillColor: Colors.green,
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 80.w,
            mainAxisSpacing: 3.w,
            crossAxisSpacing: 5.h),
      ),
    );
  }
}
