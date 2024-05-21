import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/common/GlobalConfig.dart';
import 'package:raptorpos/common/keyboard/virtual_keyboard_2.dart';
import 'package:raptorpos/common/widgets/alert_dialog.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/floor_plan/presentation/floor_plan_screen.dart';
import 'package:raptorpos/floor_plan/presentation/widgets/cover_widget.dart';
import 'package:raptorpos/floor_plan/provider/table_provider.dart';
import 'package:raptorpos/functions/application/function_provider.dart';
import 'package:raptorpos/functions/application/function_state.dart';
import 'package:raptorpos/functions/model/function_model.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/print/provider/print_controller.dart';
import 'package:raptorpos/print/provider/print_provider.dart';
import 'package:raptorpos/printer/presentation/printer_setting_screen.dart';
import 'package:raptorpos/promo/application/promo_provider.dart';
import 'package:raptorpos/promo/application/promo_state.dart';
import 'package:raptorpos/sales_report/presentation/sales_report_screen.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';
import 'package:raptorpos/trans/presentation/viewtrans_screen.dart';
import 'package:raptorpos/trans/presentation/viewtrans_screen_tablet.dart';
import 'package:raptorpos/zday_report/presentation/zday_report_screen.dart';

import '../../constants/dimension_constant.dart';

class SideBarDrawer extends ConsumerStatefulWidget {
  SideBarDrawer({Key? key}) : super(key: key);

  @override
  _SideBarDrawerState createState() => _SideBarDrawerState();
}

class _SideBarDrawerState extends ConsumerState<SideBarDrawer> {
  bool isDark = false;
  String strRemarks = '';

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);

    ref.listen(promoProvider, (previous, PromoState next) {
      if (next.failiure != null) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                isDark: isDark,
                message: next.failiure!.errMsg,
              );
            });
      }
    });

    ref.listen(functionProvider, (previous, FunctionState next) {
      if (next.failiure != null) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                isDark: isDark,
                message: next.failiure!.errMsg,
              );
            });
      }
    });

    ref.listen(orderProvoder, (previous, OrderState next) {
      if (next.operation == OPERATIONS.SHOW_TABLE_MANAGEMENT) {
        Get.to(() => const FloorPlanScreen());
      } else if (next.operation == OPERATIONS.SHOW_TABLE_NUM) {
        showDialog(
            context: context,
            builder: (context) {
              return IntrinsicHeight(
                child: IntrinsicWidth(
                  child: Dialog(
                    backgroundColor:
                        isDark ? primaryDarkColor : backgroundColorVariant,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Spacing.sm)),
                    child: CoverWidget(
                      callback: (int tableNo) {
                        ref
                            .read(tableProvider.notifier)
                            .tableNoNotify(tableNo.toString());
                      },
                    ),
                  ),
                ),
              );
            });
      } else if (next.operation == OPERATIONS.SHOW_KEYBOARD) {
        newRemarks();
      }
    });
    // GlobalConfig.functions.add(FunctionModel(66, 'View Trans', 26));
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Function',
                    style: isDark ? titleTextDarkStyle : titleTextLightStyle,
                  ),
                ),
                CloseButton(
                  callback: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: ((context, index) {
                  FunctionModel function = GlobalConfig.functions[index];
                  return ListTile(
                    title: Text(function.title),
                    onTap: () async {
                      switch (function.functionID) {
                        case 109:
                          Get.to(
                              () => ProgressHUD(child: PrinterSettingScreen()));
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
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(Spacing.sm)),
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

                        // case 66:
                        //   Responsive.isMobile(context)
                        //       ? Get.to(ViewTransScreen())
                        //       : Get.to(TabletViewTransScreen());
                        //   break;

                        default:
                      }
                    },
                  );
                }),
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemCount: GlobalConfig.functions.length),
          ),
        ],
      ),
    );
  }

  void voidPromotion() {
    ref.read(promoProvider.notifier).voidPromotion();
  }

  void allVoid() {
    ref.read(functionProvider.notifier).voidAllOrder();
  }

  void newRemarks() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Dialog(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                height: 35.h,
                width: double.infinity,
                child: Center(
                  child: Text(strRemarks),
                ),
              ),
              VirtualKeyboard(
                  height: 180.h,
                  textColor: Colors.white,
                  type: VirtualKeyboardType.Alphanumeric,
                  callback: (String str) {
                    setState(() {
                      strRemarks = str;
                    });
                  },
                  returnCallback: (String text) {
                    ref
                        .read(orderProvoder.notifier)
                        .voidOrderItemRemarks(1, strRemarks);
                    Get.back();
                    Get.back();
                  },
                  textController: TextEditingController()),
            ]));
          });
        });
  }
}

class CloseButton extends StatelessWidget {
  const CloseButton({Key? key, required this.callback}) : super(key: key);

  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: minTouchTarget,
      height: minTouchTarget,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Spacing.xs),
            ),
          ),
          onPressed: callback,
          child: const Icon(
            Icons.close,
            size: smiconSize,
            color: red,
          )),
    );
  }
}
