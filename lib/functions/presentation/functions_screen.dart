import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/common/keyboard/virtual_keyboard_2.dart';
import 'package:raptorpos/common/widgets/appbar.dart';
import 'package:raptorpos/common/widgets/responsive.dart';

import '../../common/widgets//bill_button_list.dart';
import '../../common/widgets//checkout.dart';
import '../../common/widgets/alert_dialog.dart';
import '../../constants/color_constant.dart';
import '../../constants/dimension_constant.dart';
import '../../floor_plan/presentation/floor_plan_screen.dart';
import '../../floor_plan/presentation/widgets/cover_widget.dart';
import '../../floor_plan/provider/table_provider.dart';
import '../../home/provider/order/order_provider.dart';
import '../../home/provider/order/order_state.dart';
import '../../home/repository/order/i_order_repository.dart';
import '../../payment/repository/i_payment_repository.dart';
import '../../promo/application/promo_provider.dart';
import '../../promo/application/promo_state.dart';
import '../../theme/theme_state_notifier.dart';
import '../application/function_provider.dart';
import '../application/function_state.dart';
import 'widgets/funclist_widget.dart';

List<MaterialColor> functionColors = [
  Colors.green,
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.pink,
  Colors.blue,
  Colors.grey,
  Colors.teal,
];

class FunctionsScreen extends ConsumerStatefulWidget {
  FunctionsScreen({Key? key}) : super(key: key);

  @override
  _FunctionsScreenState createState() => _FunctionsScreenState();
}

class _FunctionsScreenState extends ConsumerState<FunctionsScreen> {
  late bool isDark;
  String strRemarks = '';

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      ref.read(functionProvider.notifier).fetchFunctions();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

    isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark
          ? backgroundDarkColor
          : const Color.fromARGB(255, 244, 238, 233),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(AppBar().preferredSize.height),
        child: AppBarWidget(true),
      ),
      body: Row(
        children: [
          Column(
            children: [
              SizedBox(
                height: 5.h,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CheckOut(),
              ),
              SizedBox(
                height: 10.h,
              ),
              BillButtonList(
                paymentRepository: GetIt.I<IPaymentRepository>(),
                orderRepository: GetIt.I<IOrderRepository>(),
              ),
            ],
          ),
          SizedBox(
            width: 26.w,
          ),
          Column(
            children: [
              SizedBox(
                height: 5.h + 8,
              ),
              Expanded(
                child: SizedBox(
                  width: Responsive.isMobile(context) ? 470.w : 550.w,
                  child: FuncGridView(isDark),
                ),
              ),
              SizedBox(
                height: 40.h,
              ),
            ],
          ),
        ],
      ),
    );
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
