import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';

import '../../../common/GlobalConfig.dart';
import '../../../common/extension/workable.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/dimension_constant.dart';
import '../../../constants/text_style_constant.dart';
import '../../../print/provider/print_controller.dart';
import '../../../printer/presentation/printer_setting_screen.dart';
import '../../../promo/application/promo_provider.dart';
import '../../../sales_report/presentation/sales_report_screen.dart';
import '../../../trans/presentation/viewtrans_screen.dart';
import '../../../zday_report/presentation/zday_report_screen.dart';
import '../../application/function_provider.dart';
import '../../application/function_state.dart';
import '../../model/function_model.dart';

class FuncGridView extends ConsumerStatefulWidget {
  FuncGridView(this.isDark, {Key? key}) : super(key: key);

  final bool isDark;

  @override
  _FuncGridViewState createState() => _FuncGridViewState();
}

class _FuncGridViewState extends ConsumerState<FuncGridView> {
  @override
  Widget build(BuildContext context) {
    FunctionState state = ref.watch(functionProvider);

    if (state.workable == Workable.loading) {
      return Container();
    } else if (state.workable == Workable.ready) {
      List<FunctionModel> functions =
          state.data?.functionList ?? <FunctionModel>[];
      return GridView.builder(
        itemCount: functions.length,
        itemBuilder: (BuildContext context, int index) {
          final FunctionModel function = functions[index];
          return InkWell(
            borderRadius: BorderRadius.circular(3.0),
            onTap: () async {
              switch (function.functionID) {
                case 109:
                  Get.to(() => ProgressHUD(child: PrinterSettingScreen()));
                  break;
                case 73:
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
                            child: Text(
                              bill,
                              style: TextStyle(fontSize: bodyFontSize),
                            ),
                          ),
                        );
                      });
                  break;
                case 111:
                  Get.to(const ViewTransScreen());
                  break;
                case 17:
                  break;
                // All Void
                case 32:
                  allVoid();
                  break;

                // Sales Report
                case 19:
                  showDialog(
                      context: context,
                      builder: (context) {
                        return SalesReportScreen();
                      });
                  break;

                // ZDay Report
                case 174:
                  showDialog(
                      context: context,
                      builder: (context) {
                        return ZDayReportScreen();
                      });
                  break;

                // Void Promo
                case 65:
                  voidPromotion();
                  break;
                default:
              }
            },
            child: Ink(
              padding: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  color: widget.isDark ? primaryDarkColor : primaryLightColor,
                  border: Border.all(
                    color: widget.isDark
                        ? primaryDarkColor.withOpacity(0.7)
                        : primaryLightColor,
                  ),
                  borderRadius: BorderRadius.circular(3.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: widget.isDark
                          ? primaryDarkColor.withOpacity(0.7)
                          : primaryLightColor.withOpacity(0.7),
                      spreadRadius: 1.0,
                      blurRadius: 1.0,
                    )
                  ]),
              child: Center(
                child: Text(function.title,
                    textAlign: TextAlign.center,
                    style: widget.isDark
                        ? buttonTextDarkStyle
                        : buttonTextLightStyle),
              ),
            ),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 1,
            mainAxisExtent: 60.h,
            crossAxisSpacing: 1),
      );
    } else {
      return Container();
    }
  }

  void voidPromotion() {
    ref.read(promoProvider.notifier).voidPromotion();
  }

  void allVoid() {
    ref.read(functionProvider.notifier).voidAllOrder();
  }
}
