import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/functions/presentation/functions_screen.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../../discount/presentation/discount_screen.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/numpad.dart';

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
  // 'Close',
];

class MainButtonList extends ConsumerStatefulWidget {
  MainButtonList({Key? key}) : super(key: key);

  @override
  _MainButtonListState createState() => _MainButtonListState();
}

class _MainButtonListState extends ConsumerState<MainButtonList> {
  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    return SizedBox(
      width: 600.w,
      height: 70.h,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: btnTexts.length,
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
                  break;
              }
            },
            text: btnTexts[index],
            fillColor: index == 14
                ? Colors.red
                : isDark
                    ? primaryDarkColor
                    : Colors.white,
            borderColor: isDark ? primaryDarkColor : Colors.green,
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 78.w,
            mainAxisSpacing: 5.w,
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
