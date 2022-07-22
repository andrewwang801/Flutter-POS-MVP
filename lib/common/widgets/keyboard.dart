import 'package:flutter/material.dart';

import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';

// KeyPad widget
// This widget is reusable and its buttons are customizable (color, size)
class Keyboard extends StatelessWidget {
  final double buttonWidth;
  final double buttonHeight;
  final Color buttonColor;
  final Color iconColor;
  final TextEditingController controller;
  final Function delete;
  final Function onSubmit;

  const Keyboard({
    Key? key,
    required this.buttonWidth,
    required this.buttonHeight,
    this.buttonColor = primaryDarkColor,
    this.iconColor = Colors.amber,
    required this.delete,
    required this.onSubmit,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // implement the number keys (from 0 to 9) with the KeyButton widget
            // the KeyButton widget is defined in the bottom of this file
            children: [
              KeyButton(
                text: 'Q',
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
              KeyButton(
                text: 'W',
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
              KeyButton(
                text: 'E',
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
              KeyButton(
                icon: const Icon(Icons.cancel),
                type: ButtonType.RESET,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
            ],
          ),
          // SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              KeyButton(
                number: 4,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
              KeyButton(
                number: 5,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
              KeyButton(
                number: 6,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
              KeyButton(
                icon: const Icon(Icons.restart_alt),
                type: ButtonType.RESET,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
            ],
          ),
          // SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              KeyButton(
                number: 7,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
              KeyButton(
                number: 8,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
              KeyButton(
                number: 9,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
              KeyButton(
                icon: const Icon(Icons.done_rounded),
                type: ButtonType.CONFIRM,
                submit: onSubmit,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
            ],
          ),
          // SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // this button is used to delete the last number
              KeyButton(
                number: 0,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
              // this button is used to submit the entered value
              KeyButton(
                text: '.',
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
              KeyButton(
                icon: const Icon(Icons.backspace),
                type: ButtonType.DEL,
                width: buttonWidth * 2,
                height: buttonHeight,
                color: buttonColor,
                controller: controller,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// define KeyButton widget
enum ButtonType { DEL, RESET, CONFIRM }

class KeyButton extends StatelessWidget {
  final int? number;
  final Icon? icon;
  final ButtonType? type;
  final Function? submit;
  final String? text;
  final double width;
  final double height;
  final Color color;
  final TextEditingController controller;

  const KeyButton({
    Key? key,
    this.number,
    this.icon,
    this.type,
    this.submit,
    this.text,
    required this.width,
    required this.height,
    required this.color,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: () {
          if (number != null) {
            controller.text += number.toString();
          } else if (icon != null) {
            switch (type) {
              case ButtonType.DEL:
                final String text = controller.text;
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
        child: Center(
          child: _buttonWidget(),
        ),
      ),
    );
  }

  Widget _buttonWidget() {
    if (number != null) {
      return Text(
        number.toString(),
        style: numPadTextStyle.copyWith(fontWeight: FontWeight.bold),
      );
    } else if (icon != null) {
      return icon!;
    } else {
      return Text(
        text!,
        style: numPadTextStyle.copyWith(fontWeight: FontWeight.bold),
      );
    }
  }
}
