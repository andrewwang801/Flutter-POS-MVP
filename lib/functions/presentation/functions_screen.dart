import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/common/widgets/appbar.dart';
import 'package:raptorpos/common/widgets/responsive.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/workable.dart';
import '../../common/widgets//bill_button_list.dart';
import '../../common/widgets//checkout.dart';
import '../../common/widgets/alert_dialog.dart';
import '../../constants/color_constant.dart';
import '../../constants/dimension_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../home/repository/order/i_order_repository.dart';
import '../../payment/repository/i_payment_repository.dart';
import '../../print/provider/print_controller.dart';
import '../../printer/presentation/printer_setting_screen.dart';
import '../../promo/application/promo_provider.dart';
import '../../promo/application/promo_state.dart';
import '../../sales_report/application/sales_report_controller.dart';
import '../../sales_report/presentation/sales_report_screen.dart';
import '../../theme/theme_state_notifier.dart';
import '../../trans/presentation/trans.dart';
import '../../zday_report/presentation/zday_report_screen.dart';
import '../application/function_provider.dart';
import '../application/function_state.dart';
import '../model/function_model.dart';

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
                message: next.failiure!.errMsg,
              );
            });
      }
    });

    isDark = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: isDark
          ? backgroundDarkColor
          : const Color.fromARGB(255, 244, 238, 233),
      appBar: PreferredSize(
        child: AppBarWidget(true),
        preferredSize: Size.fromHeight(AppBar().preferredSize.height),
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
                child: CheckOut(428.h -
                    10.h -
                    10.h -
                    (Responsive.isMobile(context) ? 50.h : 40.h) -
                    appBarHeight -
                    ScreenUtil().statusBarHeight -
                    16),
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
                  child: funcGridView(),
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

  Widget funcGridView() {
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
                            child: Text(bill),
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
            child: Container(
              margin: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  color: isDark ? primaryDarkColor : primaryLightColor,
                  border: Border.all(
                    color: isDark
                        ? primaryDarkColor.withOpacity(0.7)
                        : primaryLightColor,
                  ),
                  borderRadius: BorderRadius.circular(3.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: isDark
                          ? primaryDarkColor.withOpacity(0.7)
                          : primaryLightColor.withOpacity(0.7),
                      spreadRadius: 1.0,
                      blurRadius: 1.0,
                    )
                  ]),
              child: Center(
                child: Text(function.title,
                    textAlign: TextAlign.center,
                    style: isDark ? buttonTextDarkStyle : buttonTextLightStyle),
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
}
