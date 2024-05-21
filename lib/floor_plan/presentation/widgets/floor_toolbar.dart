import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../constants/color_constant.dart';
import '../../../constants/text_style_constant.dart';
import '../../../theme/theme_model.dart';

class FloorToolBar extends StatefulWidget {
  FloorToolBar({Key? key}) : super(key: key);

  @override
  State<FloorToolBar> createState() => _FloorToolBarState();
}

class _FloorToolBarState extends State<FloorToolBar> {
  String sel = '1';

  List<String> status = <String>['Open', 'View', 'Print', 'Clean'];

  final List<Map<String, MaterialColor>> _tableStatus = [
    {'Available': Colors.green},
    {'Reversed': Colors.red},
    {'Reversed': Colors.orange},
    {'Reversed': Colors.yellow},
    {'Reversed': Colors.pink},
    {'Reversed': Colors.blue},
    {'Reversed': Colors.grey},
    {'Reversed': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Container(
        width: 926.w,
        height: 70.h,
        child: Column(
          children: [
            SizedBox(
              height: 5.h,
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Row(
                      children: [
                        ...List.generate(status.length, (index) {
                          return Expanded(
                            child: Row(
                              children: [
                                Radio<int>(
                                  groupValue: 0,
                                  value: index,
                                  onChanged: (value) {},
                                ),
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(status[index],
                                      style: themeNotifier.isDark
                                          ? bodyTextDarkStyle
                                          : bodyTextLightStyle),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _button(100.w, 30.h, 'Refresh', () {}),
                        SizedBox(width: 5.w),
                        _button(100.w, 30.h, 'Functions', () {}),
                        SizedBox(width: 5.w),
                        _button(100.w, 30.h, 'View Open Table OFF', () {}),
                        SizedBox(width: 5.w),
                        _button(100.w, 30.h, 'View Details OFF', () {}),
                        SizedBox(width: 5.w),
                        _button(100.w, 30.h, 'OP/SIGN-OUT', () {}),
                        SizedBox(width: 5.w),
                        _button(100.w, 30.h, 'Close', () {}),
                        SizedBox(width: 5.w),
                        _button(100.w, 30.h, 'Hide', () {})
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            Container(
              width: 926.w,
              height: 20.h,
              child: Row(
                children: [
                  ..._tableStatus.map((e) {
                    return _statusCard(
                        e.entries.first.value, e.entries.first.key);
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _button(double width, double height, String text, Function callback) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: themeNotifier.isDark ? primaryDarkColor : Colors.white,
            boxShadow: [
              BoxShadow(
                color: themeNotifier.isDark
                    ? backgroundDarkColor
                    : Colors.grey[300]!,
                spreadRadius: 2.0,
                blurRadius: 3.0,
              ),
            ],
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Center(
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: themeNotifier.isDark
                      ? bodyTextDarkStyle
                      : bodyTextLightStyle)));
    });
  }

  Widget _statusCard(MaterialColor statusColor, String statusString) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: themeNotifier.isDark
                          ? primaryDarkColor
                          : Colors.white,
                      width: 1),
                  color: statusColor,
                  borderRadius: BorderRadius.circular(3.0)),
            ),
            SizedBox(
              width: 5.w,
            ),
            Container(
              height: 30.w,
              child: Center(
                  child: Text(statusString,
                      style: themeNotifier.isDark
                          ? bodyTextDarkStyle
                          : bodyTextLightStyle)),
            ),
          ],
        ),
      );
    });
  }
}