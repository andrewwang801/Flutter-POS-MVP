// ignore_for_file: prefer_relative_imports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/widgets/numpad.dart';
import 'package:raptorpos/constants/color_constant.dart';
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 250.w,
          height: 25.h,
          decoration: BoxDecoration(
            color: primaryDarkColor.withOpacity(0.8),
          ),
          child: Center(
            child: Text(
              cover,
              style: titleTextDarkStyle,
            ),
          ),
        ),
        Container(
          width: 250.w,
          height: 130.h,
          color: Colors.transparent,
          child: NumPad(
              buttonWidth: 250.w / 4,
              buttonHeight: 130.h / 4,
              buttonColor: isDark ? primaryButtonDarkColor : primaryButtonColor,
              delete: () {},
              onSubmit: () {
                ref.read(tableProvider.notifier).selectCover(cover.toInt());
              },
              controller: _controller),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
