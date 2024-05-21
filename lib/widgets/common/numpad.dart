import 'package:flutter/material.dart';

import '../../constants/text_style_constant.dart';

// KeyPad widget
// This widget is reusable and its buttons are customizable (color, size)
class NumPad extends StatelessWidget {
  final double buttonSize;
  final Color buttonColor;
  final Color iconColor;
  final TextEditingController controller;
  final Function delete;
  final Function onSubmit;

  const NumPad({
    Key? key,
    this.buttonSize = 50,
    this.buttonColor = Colors.green,
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
            // implement the number keys (from 0 to 9) with the NumberButton widget
            // the NumberButton widget is defined in the bottom of this file
            children: [
              NumberButton(
                number: 1,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: 2,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: 3,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              Container(
                width: buttonSize * 3,
                height: buttonSize,
                color: Colors.green,
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.cancel,
                    color: iconColor,
                  ),
                  // iconSize: buttonSize,
                ),
              ),
            ],
          ),
          // SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: 4,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: 5,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: 6,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              Container(
                width: buttonSize * 3,
                height: buttonSize,
                color: Colors.green,
                child: TextFormField(
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  ),
                ),
              ),
            ],
          ),
          // SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: 7,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: 8,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              NumberButton(
                number: 9,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              Container(
                width: buttonSize * 3,
                height: buttonSize,
                color: Colors.green,
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.restart_alt,
                    color: iconColor,
                  ),
                  // iconSize: buttonSize,
                ),
              ),
            ],
          ),
          // SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // this button is used to delete the last number
              Container(
                width: buttonSize,
                height: buttonSize,
                color: Colors.green,
                child: IconButton(
                  onPressed: () => delete(),
                  icon: Icon(
                    Icons.backspace,
                    color: iconColor,
                  ),
                  // iconSize: buttonSize,
                ),
              ),
              NumberButton(
                number: 0,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
              // this button is used to submit the entered value
              Container(
                width: buttonSize,
                height: buttonSize,
                color: Colors.green,
                child: Center(
                    child: Text(
                  '.',
                  style: bodyTextDarkStyle,
                )),
              ),
              Container(
                width: buttonSize * 3,
                height: buttonSize,
                color: Colors.green,
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.done_rounded,
                    color: iconColor,
                  ),
                  // iconSize: buttonSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// define NumberButton widget
// its shape is round
class NumberButton extends StatelessWidget {
  final int number;
  final double size;
  final Color color;
  final TextEditingController controller;

  const NumberButton({
    Key? key,
    required this.number,
    required this.size,
    required this.color,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        onPressed: () {
          controller.text += number.toString();
        },
        child: Center(
          child: Text(
            number.toString(),
            style: numPadTextStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
