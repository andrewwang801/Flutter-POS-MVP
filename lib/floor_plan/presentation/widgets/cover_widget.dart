// ignore_for_file: prefer_relative_imports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/widgets/numpad.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../../common/extension/string_extension.dart';

class CoverWidget extends ConsumerStatefulWidget {
  CoverWidget({required this.callback, Key? key}) : super(key: key);

  final void Function(int cover) callback;

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

    return Container(
      padding: EdgeInsets.all(Spacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Responsive.isMobile(context) ? 300.w : 300.w,
            padding: EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: isDark
                  ? primaryDarkColor.withOpacity(0.8)
                  : backgroundColorVariant.withOpacity(0.8),
              border: Border.all(width: 1, color: orange),
              borderRadius: BorderRadius.circular(Spacing.sm),
            ),
            child: Center(
              child: Text(
                cover,
                style: isDark ? titleTextDarkStyle : titleTextLightStyle,
              ),
            ),
          ),
          verticalSpaceSmall,
          Container(
            width: Responsive.isMobile(context) ? 300.w : 300.w,
            color: Colors.transparent,
            child: NumPad(
                buttonColor:
                    isDark ? primaryButtonDarkColor : backgroundColorVariant,
                delete: () {},
                onSubmit: () {
                  widget.callback(cover.toInt());
                },
                isDark: isDark,
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
