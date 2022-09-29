import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/widgets/responsive.dart';

import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

class CustomButton extends ConsumerStatefulWidget {
  final Function callback;
  final String text;
  final Color borderColor;
  final Color fillColor;
  final double? height;
  final double? width;

  CustomButton({
    Key? key,
    required this.callback,
    required this.text,
    required this.borderColor,
    required this.fillColor,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends ConsumerState<CustomButton> {
  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    final String _text = widget.text;
    final Function _callback = widget.callback;
    final Color _borderColor = widget.borderColor;
    final Color _fillColor = widget.fillColor;
    final double _height =
        widget.height ?? (Responsive.isMobile(context) ? 50.h : 25.h);
    final double _width = widget.width ?? 80.w;

    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: _fillColor,
        border: Border.all(
          color: _borderColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _callback();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: _height / 10),
            child: Center(
              child: Text(_text,
                  textAlign: TextAlign.center,
                  style: isDark ? buttonTextDarkStyle : buttonTextLightStyle),
            ),
          ),
        ),
      ),
    );
  }
}
