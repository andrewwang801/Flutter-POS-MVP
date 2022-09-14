import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import '../../common/widgets/alert_dialog.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/responsive.dart';
import '../../constants/color_constant.dart';
import '../../constants/dimension_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../theme/theme_state_notifier.dart';
import '../application/sales_report_provider.dart';
import '../application/sales_report_state.dart';

class SalesReportScreen extends ConsumerStatefulWidget {
  SalesReportScreen({Key? key}) : super(key: key);

  @override
  _SalesReportScreenState createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends ConsumerState<SalesReportScreen> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      ref.read(salesReportProvider.notifier).fetchData();
    });
    super.initState();
  }

  late bool isDark;
  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);

    ref.listen(salesReportProvider, (previous, SalesReportState next) {
      if (next.failure != null) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                title: 'Error',
                message: next.failure?.errMsg,
                onConfirm: () {},
              );
            });
      } else {}
    });

    return Dialog(
      child: Container(
        padding: EdgeInsets.all(Spacing.md),
        height: 350.h,
        width: Responsive.isMobile(context) ? 500.w : 360.w,
        child: Column(
          children: [
            _header(),
            verticalSpaceRegular,
            Expanded(child: _zDayReport()),
            verticalSpaceRegular,
            _btnGroup(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Center(
      child: Text(
        'Sales Report',
        style: isDark ? titleTextDarkStyle : titleTextLightStyle,
      ),
    );
  }

  Widget _zDayReport() {
    SalesReportState state = ref.watch(salesReportProvider);
    String salesReport = '';
    if (state.workable == Workable.ready) {
      salesReport = state.data?.salesReport ?? '';
    } else if (state.workable == Workable.loading) {
      salesReport = 'loading...';
    } else if (state.workable == Workable.failure) {
      salesReport = 'Error';
    }

    return Container(
      width: Responsive.isMobile(context) ? 500.w : 360.w,
      padding: EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: SingleChildScrollView(
        // child: Text(salesReport),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...state.data?.widgets ?? []],
        ),
      ),
    );
  }

  // Widget _dateTime() {
  //   return Row(
  //     children: [
  //       Expanded(child: Text('Start Date')),
  //       Expanded(
  //         flex: 6,
  //         child: GestureDetector(
  //           onTap: () {},
  //           child: Container(
  //             height: Responsive.isMobile(context) ? 35.h : 20.h,
  //             decoration: BoxDecoration(
  //               color: isDark ? primaryDarkColor : secondaryBackgroundColor,
  //               borderRadius: BorderRadius.circular(4.0),
  //             ),
  //             child: Center(
  //               child: Text(
  //                 dateFormat.format(endDate),
  //                 style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _btnGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
            callback: () {
              // ref.read(salesReportProvider.notifier).refreshReport();
            },
            text: 'Refresh',
            borderColor: isDark ? primaryDarkColor : primaryLightColor,
            fillColor: isDark ? primaryDarkColor : primaryLightColor),
        horizontalSpaceRegular,
        CustomButton(
            callback: () {
              Get.back();
            },
            text: 'Cancel',
            borderColor: isDark ? primaryDarkColor : primaryLightColor,
            fillColor: isDark ? primaryDarkColor : primaryLightColor),
      ],
    );
  }
}
