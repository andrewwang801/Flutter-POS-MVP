// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../../common/widgets/alert_dialog.dart';
import '../../../home/presentation/home_screen.dart';
import '../../model/table_data_model.dart';
import '../../provider/table_provider.dart';
import '../../provider/table_state.dart';
import 'cover_widget.dart';

class FloorLayout extends ConsumerStatefulWidget {
  const FloorLayout({Key? key}) : super(key: key);

  @override
  _FloorLayoutState createState() => _FloorLayoutState();
}

class _FloorLayoutState extends ConsumerState<FloorLayout> {
  late bool isDark;

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);
    final TableState state = ref.watch(tableProvider);

    ref.listen(tableProvider, (Object? previous, Object? next) {
      if (next is TableSuccessState) {
        if (next.notify_type == NOTIFY_TYPE.SHOW_COVER) {
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
                        callback: (int cover) {
                          ref.read(tableProvider.notifier).selectCover(cover);
                        },
                      ),
                    ),
                  ),
                );
              });
        }
        if (next.notify_type == NOTIFY_TYPE.COVER_SELECT_ERROR) {
          showDialog(
              context: context,
              builder: (context) {
                return AppAlertDialog(
                  title: 'Error',
                  isDark: isDark,
                  message: next.errMsg,
                  onConfirm: () {},
                );
              });
        }
        if (next.notify_type == NOTIFY_TYPE.GOTO_MAIN) {
          Get.offAll(HomeScreen());
        }
      }
      if (next is TableErrorState) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                title: 'Error',
                isDark: isDark,
                message: next.errMsg,
                onConfirm: () {},
              );
            });
      }
    });

    if (state is TableSuccessState) {
      return Expanded(
        child: Container(
            padding: EdgeInsets.only(
                top: Spacing.sm,
                right: ScreenUtil().orientation == Orientation.landscape
                    ? MediaQuery.of(context).padding.right + Spacing.sm
                    : Spacing.sm,
                left: ScreenUtil().orientation == Orientation.landscape
                    ? MediaQuery.of(context).padding.left + Spacing.sm
                    : Spacing.sm,
                bottom: ScreenUtil().bottomBarHeight),
            color: isDark ? backgroundDarkColor : backgroundColorVariant,
            child: GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.isMobile(context)
                      ? ScreenUtil().orientation == Orientation.landscape
                          ? 8
                          : 5
                      : 10,
                  crossAxisSpacing: Responsive.isMobile(context) ? 20 : 50,
                  mainAxisSpacing: Responsive.isMobile(context) ? 20 : 50,
                ),
                itemCount: state.tableList.length,
                itemBuilder: (BuildContext context, int index) {
                  return _tableWidget(state.tableList[index]);
                })
            // Stack(
            // children: [
            // ...List.generate(areas.length, (index) {
            //   return AreaWidget(area: areas[index]);
            // }),),
            // ],
            // ),
            ),
      );
    }
    if (state is TableLoadingState) {
      return const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _tableWidget(TableDataModel table) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          ref.read(tableProvider.notifier).selectTable(table.tableNo);
        },
        child: Container(
          decoration: BoxDecoration(
            color: greenVariant2,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                table.tableNo,
                style: isDark ? buttonTextDarkStyle : buttonTextLightStyle,
              ),
              Text(
                table.tableStatus,
                style: isDark ? buttonTextDarkStyle : buttonTextLightStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
