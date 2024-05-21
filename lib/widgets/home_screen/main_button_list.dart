import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/screens/functions_screen.dart';

import '../../screens/discount_screen.dart';
import '../common/custom_button.dart';
import '../common/numpad.dart';

final List<String> btnTexts = [
  'Trans Table',
  'Split Bill',
  'Preview Bill',
  'PRINT BILL',
  'MEM-BER',
  'PRMN',
  'FUNCT-ION',
  'CUST MODIFIER',
  'VOID',
  'DISC',
  'RFND',
  'MNGR',
  'OPT SIGN-IN',
  'TIME ATND',
  'Close',
];

class MainButtonList extends StatefulWidget {
  MainButtonList({Key? key}) : super(key: key);

  @override
  State<MainButtonList> createState() => _MainButtonListState();
}

class _MainButtonListState extends State<MainButtonList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600.w,
      height: 70.h,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 15,
        itemBuilder: (BuildContext context, int index) {
          return CustomButton(
            callback: () {
              switch (index) {
                case 6:
                  Get.to(FunctionsScreen(), transition: Transition.rightToLeft);
                  break;
                case 9:
                  Get.to(DiscountScreen());
                  break;
                default:
                  showNumPad();
                  break;
              }
            },
            text: btnTexts[index],
            fillColor: index == 14 ? Colors.red : Colors.white,
            borderColor: Colors.green,
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 73.w,
            mainAxisSpacing: 2.w,
            crossAxisSpacing: 5.h),
      ),
    );
  }

  showNumPad() {
    final TextEditingController _myController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: IntrinsicHeight(
              child: IntrinsicWidth(
                child: NumPad(
                    delete: () {}, onSubmit: () {}, controller: _myController),
              ),
            ),
          );
        });
  }
}
