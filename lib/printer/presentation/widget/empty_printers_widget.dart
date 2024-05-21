import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/dimension_constant.dart';
import '../../../constants/text_style_constant.dart';

class EmptyPrintersWidget extends StatelessWidget {
  const EmptyPrintersWidget(
      {Key? key,
      required this.message,
      required this.icon,
      required this.isDark})
      : super(key: key);

  final String message;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.red,
            size: iconSize * 2,
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            message,
            style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
          ),
        ],
      ),
    );
  }
}
