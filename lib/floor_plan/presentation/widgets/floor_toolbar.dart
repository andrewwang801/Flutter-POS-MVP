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
                              crossAxisCount: 4,
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
      // padding: EdgeInsets.all(Spacing.sm),
      width: 428.w,
      color: isDark ? backgroundDarkColor : backgroundColor,
      child: Column(
        children: [
          Row(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    // padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
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
                ],
              ),
              Spacer(),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        showInfoBottomSheet();
                      },
                      icon: Icon(Icons.info_outline)),
                  IconButton(
                      onPressed: () {
                        showMoreAction();
                      },
                      icon: Icon(Icons.more_vert))
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _tablet() {
    return Container(
      padding: EdgeInsets.all(Spacing.sm),
      width: 926.w,
      color: isDark ? backgroundDarkColor : backgroundColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: minTouchTarget,
                height: minTouchTarget,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(minTouchTarget / 2),
                      ),
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
                child: Row(
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
                ),
              ),
            ],
          ),
          Container(
            width: 926.w,
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
                    _switchButton('View Table', () {}),
                    _switchButton('View Detail', () {}),
                    _switchButton('Dark Mode', () {})
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(
      String text, Function callback, Color color, Color borderColor) {
    return SizedBox(
      height: Responsive.isMobile(context) ? 30.h : 16.h,
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

  Widget _switchButton(String text, Function callback) {
    return Container(
      // height: 16.h,
      child: Row(
        children: [
          Text(
            text,
            style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
          ),
          Switch(value: false, onChanged: (bool newValue) {}),
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
            width: 140.w,
            child: Center(
              child: Text(
                'Table Layout',
                style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
              ),
            ),
          ),
          SizedBox(
            width: 140.w,
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
                      color: isDark ? primaryDarkColor : Colors.white,
                      width: 1),
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10.w)),
            ),
            SizedBox(
              width: 2.w,
            ),
            Center(
                child: Text(statusString,
                    style: isDark ? bodyTextDarkStyle : bodyTextLightStyle)),
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
