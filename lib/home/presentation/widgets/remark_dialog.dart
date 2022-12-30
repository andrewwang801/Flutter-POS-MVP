import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/keyboard/virtual_keyboard_2.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../../common/extension/workable.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/dimension_constant.dart';
import '../../../constants/text_style_constant.dart';
import '../../provider/order/order_provider.dart';
import '../../provider/order/order_state.dart';

class RemarksDialog extends ConsumerStatefulWidget {
  RemarksDialog({Key? key}) : super(key: key);

  @override
  _RemarksDialogState createState() => _RemarksDialogState();
}

class _RemarksDialogState extends ConsumerState<RemarksDialog> {
  String strRemarks = '';
  int selectedIndex = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    OrderState state = ref.watch(orderProvoder);
    bool isDark = ref.watch(themeProvider);

    List<List<String>> remarks = [];
    if (state.workable == Workable.ready && state.remarks != null) {
      remarks = state.remarks!;
    }

    return Dialog(
      backgroundColor: isDark ? backgroundDarkColor : backgroundColor,
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        width: 0.8.sw,
        height: 0.7.sh,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: Text(
                'Entry Void Remarks',
                style: isDark ? titleTextDarkStyle : titleTextLightStyle,
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: remarks.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(Spacing.xs),
                      child: ListTile(
                        title: Text(remarks[index][1]),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        tileColor: index == selectedIndex
                            ? isDark
                                ? primaryDarkColor
                                : backgroundColorVariant
                            : isDark
                                ? primaryDarkColor
                                : backgroundColorVariant,
                        onTap: () {
                          setState(() {
                            strRemarks = remarks[index][1];
                            selectedIndex = index;
                          });
                        },
                      ),
                    );
                  }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        if (selectedIndex != -1) {
                          selectRemarks();
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(primary: orange),
                      child: Text('Select')),
                ),
                horizontalSpaceTiny,
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        newRemarks();
                      },
                      style: ElevatedButton.styleFrom(primary: orange),
                      child: Text('New Remarks')),
                ),
                horizontalSpaceTiny,
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        cancel();
                      },
                      style: ElevatedButton.styleFrom(primary: orange),
                      child: Text('Close')),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  selectRemarks() {
    ref.read(orderProvoder.notifier).voidOrderItemRemarks(0, strRemarks);
  }

  newRemarks() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Dialog(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                height: 35.h,
                width: double.infinity,
                child: Center(
                  child: Text(strRemarks),
                ),
              ),
              VirtualKeyboard(
                  height: 180.h,
                  textColor: Colors.white,
                  type: VirtualKeyboardType.Alphanumeric,
                  callback: (String str) {
                    setState(() {
                      strRemarks = str;
                    });
                  },
                  returnCallback: (String text) {
                    ref
                        .read(orderProvoder.notifier)
                        .voidOrderItemRemarks(0, strRemarks);
                    Get.back();
                    Get.back();
                  },
                  textController: TextEditingController()),
            ]));
          });
        });
  }

  cancel() {
    Get.back();
  }
}
