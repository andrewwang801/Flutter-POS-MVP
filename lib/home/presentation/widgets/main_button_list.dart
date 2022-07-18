import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/GlobalConfig.dart';
import '../../../common/widgets/alert_dialog.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/numpad.dart';
import '../../../constants/color_constant.dart';
import '../../../discount/presentation/discount_screen.dart';
import '../../../floor_plan/presentation/floor_plan_screen.dart';
import '../../../functions/presentation/functions_screen.dart';
import '../../../print/provider/print_provider.dart';
import '../../../print/provider/print_state.dart';
import '../../../printer/presentation/printer_setting_screen.dart';
import '../../../theme/theme_state_notifier.dart';

final List<String> btnTexts = [
  'Trans Table',
  'Preview Bill',
  'PRINT BILL',
  'FUNCT-ION',
  'VOID',
  'HOLD TABLE',
  'ADD PRINTER',
];

class MainButtonList extends ConsumerStatefulWidget {
  const MainButtonList({Key? key}) : super(key: key);

  @override
  _MainButtonListState createState() => _MainButtonListState();
}

class _MainButtonListState extends ConsumerState<MainButtonList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    ref.listen(printProvider, (previous, next) {
      if (next is PrintSuccessState) {
      } else if (next is PrintErrorState) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                title: 'Error',
                message: next.errMsg,
                onConfirm: () {},
              );
            });
      }
    });
    return SizedBox(
      width: 600.w,
      height: 40.h,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: btnTexts.length,
        itemBuilder: (BuildContext context, int index) {
          return CustomButton(
            callback: () async {
              switch (index) {
                case 2:
                  await ref
                      .read(printProvider.notifier)
                      .doPrint(3, GlobalConfig.salesNo, '');
                  break;
                case 5:
                  Get.to(FloorPlanScreen());
                  break;
                case 3:
                  Get.to(FunctionsScreen(), transition: Transition.rightToLeft);
                  break;
                case 6:
                  Get.to(
                      ProgressHUD(
                        barrierEnabled: false,
                        child: PrinterSettingScreen(),
                      ),
                      transition: Transition.rightToLeft);
                  break;
                case 4:
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
            crossAxisCount: 1,
            mainAxisExtent: 90.w,
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
                    buttonWidth: 60,
                    buttonHeight: 60,
                    delete: () {},
                    onSubmit: () {},
                    controller: _myController),
              ),
            ),
          );
        });
  }
}
