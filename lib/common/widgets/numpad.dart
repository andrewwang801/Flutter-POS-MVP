import 'package:flutter/material.dart';
import 'package:raptorpos/common/widgets/responsive.dart';

import '../../constants/color_constant.dart';
import '../../constants/dimension_constant.dart';
import '../../constants/text_style_constant.dart';

// KeyPad widget
// This widget is reusable and its buttons are customizable (color, size)
class NumPad extends StatelessWidget {
  final bool isDark;
  final Color buttonColor;
  final Color iconColor;
  final TextEditingController controller;
  final Function delete;
  final Function onSubmit;
  final bool onlyNum;
  final Color backgroundColor;

  const NumPad({
    Key? key,
    this.isDark = false,
    this.buttonColor = primaryDarkColor,
    this.backgroundColor = backgroundColorVariant,
    this.iconColor = Colors.amber,
    required this.delete,
    required this.onSubmit,
    required this.controller,
    this.onlyNum = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        padding: EdgeInsets.all(4.0),
        color: backgroundColor,
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NumberButton(
                    number: 1,
                    color: buttonColor,
                    controller: controller,
                    isDark: isDark,
                    onlyNum: onlyNum,
                  ),
                  NumberButton(
                    number: 2,
                    color: buttonColor,
                    controller: controller,
                    isDark: isDark,
                    onlyNum: onlyNum,
                  ),
                  NumberButton(
                    number: 3,
                    color: buttonColor,
                    controller: controller,
                    isDark: isDark,
                    onlyNum: onlyNum,
                  ),
                  if (!onlyNum)
                    NumberButton(
                      icon: Icon(
                        Icons.cancel,
                        size: Responsive.isTablet(context)
                            ? lgiconSize
                            : smiconSize,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      type: ButtonType.RESET,
                      color: buttonColor,
                      controller: controller,
                      isDark: isDark,
                      onlyNum: onlyNum,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NumberButton(
                    number: 4,
                    color: buttonColor,
                    controller: controller,
                    isDark: isDark,
                    onlyNum: onlyNum,
                  ),
                  NumberButton(
                    number: 5,
                    color: buttonColor,
                    controller: controller,
                    isDark: isDark,
                    onlyNum: onlyNum,
                  ),
                  NumberButton(
                    number: 6,
                    color: buttonColor,
                    controller: controller,
                    isDark: isDark,
                    onlyNum: onlyNum,
                  ),
                  if (!onlyNum)
                    NumberButton(
                      icon: Icon(
                        Icons.restart_alt,
                        size: Responsive.isTablet(context)
                            ? lgiconSize
                            : smiconSize,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      type: ButtonType.RESET,
                      color: buttonColor,
                      controller: controller,
                      isDark: isDark,
                      onlyNum: onlyNum,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NumberButton(
                    number: 7,
                    color: buttonColor,
                    controller: controller,
                    isDark: isDark,
                    onlyNum: onlyNum,
                  ),
                  NumberButton(
                    number: 8,
                    color: buttonColor,
                    controller: controller,
                    isDark: isDark,
                    onlyNum: onlyNum,
                  ),
                  NumberButton(
                    number: 9,
                    color: buttonColor,
                    controller: controller,
                    isDark: isDark,
                    onlyNum: onlyNum,
                  ),
                  if (!onlyNum)
                    NumberButton(
                      icon: Icon(
                        Icons.done_rounded,
                        size: Responsive.isTablet(context)
                            ? lgiconSize
                            : smiconSize,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      type: ButtonType.CONFIRM,
                      submit: onSubmit,
                      color: buttonColor,
                      controller: controller,
                      isDark: isDark,
                      onlyNum: onlyNum,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // this button is used to delete the last number
                  NumberButton(
                    number: 0,
                    color: buttonColor,
                    controller: controller,
                    isDark: isDark,
                    onlyNum: onlyNum,
                  ),
                  // this button is used to submit the entered value
                  NumberButton(
                    text: '.',
                    color: buttonColor,
                    controller: controller,
                    isDark: isDark,
                    onlyNum: onlyNum,
                  ),
                  NumberButton(
                    icon: Icon(
                      Icons.backspace,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    type: ButtonType.DEL,
                    color: buttonColor,
                    controller: controller,
                    isDark: isDark,
                    onlyNum: onlyNum,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// define NumberButton widget
enum ButtonType { DEL, RESET, CONFIRM }

class NumberButton extends StatelessWidget {
  final int? number;
  final Icon? icon;
  final ButtonType? type;
  final Function? submit;
  final String? text;
  final Color color;
  final TextEditingController controller;
  final isDark;
  final bool onlyNum;

  const NumberButton({
    Key? key,
    this.isDark,
    this.number,
    this.icon,
    this.type,
    this.submit,
    this.text,
    required this.onlyNum,
    required this.color,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int flex = 1;
    if (type == ButtonType.DEL) flex = 2;
    if (onlyNum) flex = 1;
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(3.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: color,
            minimumSize: Size.fromHeight(double.infinity),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            // padding: EdgeInsets.all(Spacing.sm),
          ),
          onPressed: () {
            if (number != null) {
              controller.text += number.toString();
            } else if (icon != null) {
              switch (type) {
                case ButtonType.DEL:
                  final String text = controller.text;
                  if (text.isNotEmpty)
                    controller.text = text.substring(0, text.length - 1);
                  break;
                case ButtonType.RESET:
                  controller.text = '';
                  break;
                case ButtonType.CONFIRM:
                  submit!();
                  break;
                default:
                  controller.text = '';
                  break;
              }
            } else if (text != null) {
              controller.text += text!;
            }
          },
          child: _buttonWidget(isDark),
        ),
      ),
    );
  }

  Widget _buttonWidget(bool isDark) {
    if (number != null) {
      return Text(
        number.toString(),
        style: isDark
            ? numPadTextStyle
            : numPadTextStyle.copyWith(color: Colors.black),
      );
    } else if (icon != null) {
      return icon!;
    } else {
      return FittedBox(
        fit: BoxFit.contain,
        child: Text(
          text!,
          style: isDark
              ? numPadTextStyle
              : numPadTextStyle.copyWith(color: Colors.black),
        ),
      );
    }
  }
}
