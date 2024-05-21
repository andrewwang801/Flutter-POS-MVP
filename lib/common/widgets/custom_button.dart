import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:raptorpos/constants/text_style_constant.dart';

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
    final String _text = widget.text;
    final Function _callback = widget.callback;
    final Color _borderColor = widget.borderColor;
    final Color _fillColor = widget.fillColor;
    final double _height = widget.height ?? 25.h;
    final double _width = widget.width ?? 30.w;

    return InkWell(
        onTap: () {
          _callback();
        },
        child: Container(
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            color: _fillColor,
            border: Border.all(
              color: _borderColor,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Center(
            child: Text(_text,
                textAlign: TextAlign.center, style: bodyTextLightStyle),
          ),
        ));
  }
}
