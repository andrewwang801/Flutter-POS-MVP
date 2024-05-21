import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/print/provider/print_controller.dart';

import '../../../common/GlobalConfig.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/numpad.dart';
import '../../../common/widgets/responsive.dart';
import '../../../constants/color_constant.dart';
import '../../../floor_plan/presentation/floor_plan_screen.dart';
import '../../../functions/presentation/functions_screen.dart';
import '../../../print/provider/print_provider.dart';
import '../../../printer/presentation/printer_setting_screen.dart';
import '../../../theme/theme_state_notifier.dart';
import '../../../trans/presentation/viewtrans_screen.dart';

final List<String> btnTexts = [
  'View Trans',
  'Preview Bill',
  'PRINT BILL',
  'FUNCT-ION',
  'VOID',
  'HOLD TABLE',
  'PRINTER SETTING',
];

class MainButtonList extends ConsumerStatefulWidget {
  const MainButtonList({Key? key}) : super(key: key);

  @override
  _MainButtonListState createState() => _MainButtonListState();
}

class _MainButtonListState extends ConsumerState<MainButtonList> {
  late bool isDark;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);
    return SizedBox(
      width: 600.w,
      height: Responsive.isMobile(context) ? 35.h : 40.h,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: btnTexts.length,
        itemBuilder: (BuildContext context, int index) {
          return CustomButton(
            callback: () async {
              switch (index) {
                case 0:
                  Get.to(const ViewTransScreen());
                  break;
                case 1:
                  String bill = await GetIt.I<PrintController>()
                      .getBillForPreview(
                          GlobalConfig.salesNo,
                          GlobalConfig.splitNo,
                          GlobalConfig.cover,
                          GlobalConfig.tableNo,
                          GlobalConfig.rcptNo);
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(bill),
                          ),
                        );
                      });
                  break;
                case 2:
                  await ref
                      .read(printProvider.notifier)
                      .printBill(GlobalConfig.salesNo, '');
                  break;
                case 3:
                  Get.to(FunctionsScreen(), transition: Transition.rightToLeft);
                  break;
                // void
                case 4:
                  break;
                case 5:
                  Get.to(FloorPlanScreen());
                  break;
                case 6:
                  Get.to(
                      ProgressHUD(
                        barrierEnabled: false,
                        child: PrinterSettingScreen(),
                      ),
                      transition: Transition.rightToLeft);
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
            borderColor: isDark ? primaryDarkColor : primaryLightColor,
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
}
