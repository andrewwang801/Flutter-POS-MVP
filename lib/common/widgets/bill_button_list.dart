import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/cash/presentation/cash_screen.dart';
import 'package:raptorpos/floor_plan/presentation/floor_plan_screen.dart';

import 'package:raptorpos/trans/presentation/trans.dart';
import 'package:raptorpos/sales_category/sales_category_screen.dart';
import './custom_button.dart';

class BillButtonList extends StatefulWidget {
  BillButtonList({Key? key}) : super(key: key);

  @override
  State<BillButtonList> createState() => _BillButtonListState();
}

class _BillButtonListState extends State<BillButtonList> {
  final List<String> billBtnTexts = [
    "CASH",
    "TENDER",
    "SUBTOTAL",
    "TABLE/HOLD",
    "View Trans",
    "DINE-IN",
  ];

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
            text: billBtnTexts[index],
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
