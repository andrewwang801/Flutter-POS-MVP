// ignore_for_file: prefer_relative_imports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/widgets/numpad.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/floor_plan/provider/table_provider.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../../common/extension/string_extension.dart';

class CoverWidget extends ConsumerStatefulWidget {
  const CoverWidget({Key? key}) : super(key: key);

  @override
  _CoverWidgetState createState() => _CoverWidgetState();
}

class _CoverWidgetState extends ConsumerState<CoverWidget> {
  final TextEditingController _controller = TextEditingController();
  String cover = '';
  late bool isDark;

  @override
  void initState() {
    _controller.addListener(() {
      setState(() {
        cover = _controller.text;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);

    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 250.w,
            height: Responsive.isMobile(context) ? 40.h : 25.h,
            decoration: BoxDecoration(
              color: isDark
                  ? primaryDarkColor.withOpacity(0.8)
                  : primaryLightColor.withOpacity(0.8),
            ),
            child: Center(
              child: Text(
                cover,
                style: titleTextDarkStyle,
              ),
            ),
          ),
          verticalSpaceSmall,
          Container(
            width: 250.w,
            height: Responsive.isMobile(context) ? 220.h : 130.h,
            color: Colors.transparent,
            child: NumPad(
                buttonWidth: 250.w / 4,
                buttonHeight:
                    Responsive.isMobile(context) ? 220.h / 4 : 130.h / 4,
                buttonColor:
                    isDark ? primaryButtonDarkColor : primaryButtonColor,
                delete: () {},
                onSubmit: () {
                  ref.read(tableProvider.notifier).selectCover(cover.toInt());
                },
                controller: _controller),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
