import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/widgets/responsive.dart';

import '../../../constants/color_constant.dart';
import '../../../constants/dimension_constant.dart';
import '../../../constants/text_style_constant.dart';
import '../../../theme/theme_state_notifier.dart';

class FloorToolBar extends ConsumerStatefulWidget {
  FloorToolBar({Key? key}) : super(key: key);

  @override
  _FloorToolBarState createState() => _FloorToolBarState();
}

class _FloorToolBarState extends ConsumerState<FloorToolBar> {
  String sel = '1';
  late bool isDark;

  List<String> status = <String>['Open', 'View', 'Print', 'Clean'];

  final List<Map<String, MaterialColor>> _tableStatus = [
    {'Available': Colors.green},
    {'Reversed': Colors.red},
    {'Open': Colors.orange},
    {'Hold': Colors.yellow},
    {'No Order': Colors.pink},
    {'Clenaing': Colors.blue},
    {'Finalizing': Colors.grey},
    {'Shift Warning': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);
    return Responsive(mobile: _mobile(), tablet: _tablet(), desktop: _tablet());
  }

  void showInfoBottomSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.sm),
        ),
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                Container(
                  padding: EdgeInsets.all(Spacing.sm),
                  child: Column(
                    children: [
                      Text('Table Information'),
                      verticalSpaceRegular,
                      SizedBox(
                        height: 200.h,
                        child: GridView.builder(
                            itemCount: _tableStatus.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ScreenUtil().orientation ==
                                      Orientation.landscape
                                  ? 8
                                  : Responsive.isMobile(context)
                                      ? 4
                                      : 6,
                              mainAxisSpacing: 5,
                            ),
                            itemBuilder: (context, index) {
                              return _statusCard(
                                  _tableStatus[index].entries.first.value,
                                  _tableStatus[index].entries.first.key);
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  void showMoreAction() {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.sm)),
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                Container(
                  padding: EdgeInsets.all(Spacing.sm),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('More Action'),
                      verticalSpaceRegular,
                      Wrap(
                        alignment: WrapAlignment.center,
                        runSpacing: 10,
                        children: [
                          _checkBoxButton('Open', () {}),
                          SizedBox(width: 6.h),
                          _checkBoxButton('View', () {}),
                          SizedBox(width: 6.h),
                          _checkBoxButton('Print', () {}),
                          SizedBox(width: 6.h),
                          _checkBoxButton('Clean', () {}),
                          SizedBox(width: 6.h),
                          _button('Refresh', () {}, orange, orange),
                          SizedBox(width: 6.h),
                          _button('OP/Sign Out', () {}, orange, orange),
                          SizedBox(width: 6.h),
                          _button('Hide', () {}, orange, orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _mobile() {
    return Container(
      padding: EdgeInsets.only(
          top: ScreenUtil().statusBarHeight,
          right: ScreenUtil().orientation == Orientation.landscape
              ? MediaQuery.of(context).padding.right
              : 0,
          left: ScreenUtil().orientation == Orientation.landscape
              ? MediaQuery.of(context).padding.left
              : 0),
      // width: 428.w,
      // color: isDark ? primaryDarkColor : backgroundColor,
      child: Row(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              horizontalSpaceTiny,
              Container(
                width: 30.w,
                height: 30.w,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: StadiumBorder(),
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: const Icon(
                      Icons.menu,
                      size: mdiconsize,
                    )),
              ),
              _tableLayoutDropDown(),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  padding: EdgeInsets.all(Spacing.sm),
                  splashRadius: 24,
                  onPressed: () {
                    showInfoBottomSheet();
                  },
                  icon: Icon(Icons.info_outline)),
              IconButton(
                  splashRadius: 24,
                  onPressed: () {
                    showMoreAction();
                  },
                  icon: Icon(Icons.more_vert)),
              // IconButton(
              //     splashRadius: 24,
              //     icon: Icon(
              //       isDark ? Icons.wb_sunny : Icons.nightlight_round,
              //     ),
              //     color: isDark ? backgroundColor : primaryDarkColor,
              //     onPressed: () {
              //       isDark ? isDark = false : isDark = true;
              //       ref.read(themeProvider.notifier).setTheme(isDark);
              //     }),
            ],
          )
        ],
      ),
    );
  }

  Widget _tablet() {
    return Container(
      padding: EdgeInsets.only(
          top: ScreenUtil().statusBarHeight + Spacing.sm,
          right: ScreenUtil().orientation == Orientation.landscape
              ? MediaQuery.of(context).padding.right + Spacing.sm
              : Spacing.sm,
          left: ScreenUtil().orientation == Orientation.landscape
              ? MediaQuery.of(context).padding.left + Spacing.sm
              : Spacing.sm,
          bottom: Spacing.sm),
      // width: 926.w,
      // color: isDark ? primaryDarkColor : backgroundColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: Responsive.isMobile(context) ? 36 : 36,
                height: Responsive.isMobile(context) ? 36 : 36,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: StadiumBorder(),
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: const Icon(
                      Icons.menu,
                      size: smiconSize,
                    )),
              ),
              _tableLayoutDropDown(),
              Expanded(
                child: 1.sw > 900
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _checkBoxButton('Open', () {}),
                          SizedBox(width: 6.w),
                          _checkBoxButton('View', () {}),
                          SizedBox(width: 6.w),
                          _checkBoxButton('Print', () {}),
                          SizedBox(width: 6.w),
                          _checkBoxButton('Clean', () {}),
                          SizedBox(width: 6.w),
                          _button('Refresh', () {}, orange, orange),
                          SizedBox(width: 6.w),
                          _button('OP/Sign Out', () {}, orange, orange),
                          SizedBox(width: 6.w),
                          _button('Hide', () {}, orange, orange),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              padding: EdgeInsets.all(Spacing.sm),
                              splashRadius: 24,
                              onPressed: () {
                                showInfoBottomSheet();
                              },
                              icon: Icon(Icons.info_outline)),
                          IconButton(
                              splashRadius: 24,
                              onPressed: () {
                                showMoreAction();
                              },
                              icon: Icon(Icons.more_vert)),
                          // IconButton(
                          //     splashRadius: 24,
                          //     icon: Icon(
                          //       isDark ? Icons.wb_sunny : Icons.nightlight_round,
                          //     ),
                          //     color: isDark ? backgroundColor : primaryDarkColor,
                          //     onPressed: () {
                          //       isDark ? isDark = false : isDark = true;
                          //       ref.read(themeProvider.notifier).setTheme(isDark);
                          //     }),
                        ],
                      ),
              ),
            ],
          ),
          if (1.sw >= 900) verticalSpaceSmall,
          if (1.sw >= 900)
            Container(
              // width: 926.w,
              height: Responsive.isMobile(context) ? 25.h : 20.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ..._tableStatus.map((e) {
                            return _statusCard(
                                e.entries.first.value, e.entries.first.key);
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _switchButton(false, 'View Table', () {}),
                      _switchButton(false, 'View Detail', () {}),
                    ],
                  ),
                ],
              ),
            ),
          if (1.sw >= 900) verticalSpaceSmall,
        ],
      ),
    );
  }

  Widget _button(
      String text, Function callback, Color color, Color borderColor) {
    return SizedBox(
      height: Responsive.isMobile(context)
          ? 30.h
          : ScreenUtil().orientation == Orientation.landscape
              ? 16.h
              : 22.h,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          primary: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.sm),
            side: BorderSide(width: 1, color: borderColor),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: isDark
              ? bodyTextDarkStyle
              : bodyTextLightStyle.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _checkBoxButton(String text, Function callback) {
    return Container(
        // height: 16.h,
        padding: EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: orange,
          borderRadius: BorderRadius.circular(Spacing.sm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: mdiconsize,
              height: mdiconsize,
              child: Checkbox(
                value: true,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (bool? newValue) {},
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
                checkColor: orange,
                activeColor: Colors.white,
              ),
            ),
            horizontalSpaceSmall,
            Text(text,
                textAlign: TextAlign.center,
                style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
          ],
        ));
  }

  Widget _switchButton(bool value, String text, Function callback) {
    return Container(
      // height: 16.h,
      child: Row(
        children: [
          Text(
            text,
            style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
          ),
          Switch(
              value: value,
              onChanged: (bool newValue) {
                callback();
              }),
        ],
      ),
    );
  }

  Widget _tableLayoutDropDown() {
    List<DropdownMenuItem<int>> items = [
      DropdownMenuItem<int>(
        value: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Table Layout',
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
            ),
            _button('Select', () {}, orange, orange),
          ],
        ),
      ),
      DropdownMenuItem<int>(
        value: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Online',
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
            ),
            _button('Select', () {}, orange, orange),
          ],
        ),
      ),
    ];
    return DropdownButton(
      borderRadius: BorderRadius.circular(Spacing.sm),
      items: items,
      onChanged: (int? index) {},
      underline: Container(),
      icon: Icon(Icons.keyboard_arrow_down),
      value: 0,
      selectedItemBuilder: (BuildContext context) {
        return [
          SizedBox(
            width: Responsive.isMobile(context) ? 0.25.sw : 0.2.sw,
            child: Center(
              child: Text(
                'Table Layout',
                style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
              ),
            ),
          ),
          SizedBox(
            width: Responsive.isMobile(context) ? 0.25.sw : 0.2.sw,
            child: Text(
              'Online',
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
            ),
          ),
        ];
      },
    );
  }

  Widget _statusCard(MaterialColor statusColor, String statusString) {
    return Responsive(
      tablet: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                border: Border.all(
                    color: isDark ? primaryDarkColor : Colors.white, width: 1),
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(
              width: 2.w,
            ),
            Center(
              child: Text(
                statusString,
                style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      mobile: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isDark ? primaryDarkColor : Colors.white, width: 1),
                color: statusColor,
              ),
            ),
            SizedBox(
              height: 4.w,
            ),
            Center(
                child: Text(statusString,
                    style: isDark ? bodyTextDarkStyle : bodyTextLightStyle)),
          ],
        ),
      ),
      desktop: Container(),
    );
  }
}
