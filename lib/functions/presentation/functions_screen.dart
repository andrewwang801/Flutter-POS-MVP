import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../common/GlobalConfig.dart';
import '../../common/widgets//bill_button_list.dart';
import '../../common/widgets//checkout.dart';
import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../home/repository/order/i_order_repository.dart';
import '../../payment/repository/i_payment_repository.dart';
import '../../print/provider/print_controller.dart';
import '../../printer/presentation/printer_setting_screen.dart';
import '../../theme/theme_state_notifier.dart';
import '../../trans/presentation/trans.dart';
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
    isDark = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: isDark
          ? backgroundDarkColor
          : const Color.fromARGB(255, 244, 238, 233),
      appBar: AppBar(
        title: Text('Raptor POS', style: titleTextDarkStyle),
        actions: [
          IconButton(
              icon: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
              onPressed: () {
                isDark ? isDark = false : isDark = true;
              })
        ],
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
                child: CheckOut(320.h),
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
                height: 5.h,
              ),
              Expanded(
                child: SizedBox(
                  width: 550.w,
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
                  Get.to(PrinterSettingScreen());
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
                            padding: const EdgeInsets.all(8.0),
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
                default:
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: primaryDarkColor,
                  border: Border.all(
                    color: isDark
                        ? primaryDarkColor.withOpacity(0.7)
                        : Colors.green,
                  ),
                  borderRadius: BorderRadius.circular(3.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: isDark
                          ? primaryDarkColor.withOpacity(0.7)
                          : Colors.white,
                      spreadRadius: 1.0,
                      blurRadius: 1.0,
                    )
                  ]),
              child: Center(
                child: Text(function.title,
                    textAlign: TextAlign.center,
                    style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
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
}
