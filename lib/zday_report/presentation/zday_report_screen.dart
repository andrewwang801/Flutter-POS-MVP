import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/extension/workable.dart';
import '../../common/widgets/alert_dialog.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/responsive.dart';
import '../../constants/color_constant.dart';
import '../../constants/dimension_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../theme/theme_state_notifier.dart';
import '../application/zday_report_provider.dart';
import '../application/zday_report_state.dart';

class ZDayReportScreen extends ConsumerStatefulWidget {
  ZDayReportScreen({Key? key}) : super(key: key);

  @override
  _ZDayReportScreenState createState() => _ZDayReportScreenState();
}

class _ZDayReportScreenState extends ConsumerState<ZDayReportScreen> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      ref.read(zDayReportProvider.notifier).fetchZDay();
    });
    super.initState();
  }

  late bool isDark;
  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);

    ref.listen(zDayReportProvider, (previous, ZDayReportState next) {
      if (next.failure != null) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                title: 'Error',
                message: next.failure?.errMsg,
                isDark: isDark,
                onConfirm: () {},
              );
            });
      } else {}
    });

    return Dialog(
      child: Container(
        padding: EdgeInsets.all(Spacing.md),
        height: Responsive.isMobile(context) ? 700.w : 350.h,
        width: Responsive.isMobile(context) ? 400.w : 360.w,
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
        'Z Day Report',
        style: isDark ? titleTextDarkStyle : titleTextLightStyle,
      ),
    );
  }

  Widget _zDayReport() {
    ZDayReportState state = ref.watch(zDayReportProvider);
    String zDayReport = '';
    if (state.workable == Workable.ready) {
      zDayReport = state.data?.zDayReport ?? '';
    } else if (state.workable == Workable.loading) {
      zDayReport = 'loading...';
    } else if (state.workable == Workable.failure) {
      zDayReport = 'Error';
    }

    return Container(
      width: Responsive.isMobile(context) ? 500.w : 360.w,
      padding: EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: SingleChildScrollView(
        // child: Text(zDayReport),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...state.data?.zDayWidgets ?? []],
        ),
      ),
    );
  }

  Widget _btnGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
            callback: () {
              ref.read(zDayReportProvider.notifier).doZDay();
            },
            text: 'DO Z DAY',
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
