import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../../common/widgets/alert_dialog.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/dimension_constant.dart';
import '../../application/kitchen_provider.dart';
import '../../application/kitchen_state.dart';

class KitchenReprint extends ConsumerStatefulWidget {
  const KitchenReprint(
      {required this.salesNo,
      required this.splitNo,
      required this.tableNo,
      Key? key})
      : super(key: key);

  final int salesNo;
  final int splitNo;
  final String tableNo;

  @override
  _KitchenReprintState createState() => _KitchenReprintState();
}

class _KitchenReprintState extends ConsumerState<KitchenReprint> {
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    // fetch reprint items
    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      ref
          .read(kitchenProvider.notifier)
          .fetchReprintData(widget.salesNo, widget.splitNo, widget.tableNo);
    });
  }

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);

    // Listen state changes
    ref.listen(kitchenProvider, (previous, KitchenState next) {
      if (next.workable == Workable.failure) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                message: next.failiure?.errMsg ?? '',
                isDark: isDark,
              );
            });
      }
    });

    return Container(
      padding: const EdgeInsets.all(Spacing.screenHPadding),
      width: 500.w,
      height: 250.h,
      child: Column(
        children: [
          Expanded(child: reprintItemList()),
          btnGroup(),
        ],
      ),
    );
  }

  List<bool> reprintCheck = <bool>[];
  List<String> sRefArray = <String>[];
  List<String> iSeqNoArray = <String>[];

  Widget reprintItemList() {
    KitchenState state = ref.watch(kitchenProvider);
    List<DataRow> dataRows = <DataRow>[];
    if (state.workable == Workable.loading) {
    } else if (state.workable == Workable.ready) {
      final List<List<String>> reprintArray =
          state.kitchenData?.reprintArray ?? [];
      reprintCheck = List.filled(reprintArray.length, false);

      dataRows = List.generate(reprintArray.length, (int index) {
        return DataRow(
          onSelectChanged: (bool? value) {
            reprintCheck[index] = value!;
            if (value) {
              sRefArray.add(reprintArray[index][0]);
              iSeqNoArray.add(reprintArray[index][1]);
            } else {
              sRefArray.remove(reprintArray[index][0]);
              iSeqNoArray.remove(reprintArray[index][1]);
            }
          },
          selected: reprintCheck[index],
          cells: <DataCell>[
            DataCell(Text(reprintArray[index][2])),
            DataCell(Text(reprintArray[index][3])),
            DataCell(Text(reprintArray[index][4])),
          ],
        );
      });
    } else if (state.workable == Workable.failure) {
    } else {}

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('Item Name')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Count')),
          ],
          rows: dataRows,
        ),
      ),
    );
  }

  Widget btnGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
            width: 120.w,
            height: 30.h,
            callback: () {
              fire();
            },
            text: 'FIRE',
            borderColor: primaryDarkColor,
            fillColor: primaryDarkColor),
        horizontalSpaceLarge,
        CustomButton(
            width: 120.w,
            height: 30.h,
            callback: () {
              Get.back();
            },
            text: 'CLOSE',
            borderColor: primaryDarkColor,
            fillColor: primaryDarkColor),
      ],
    );
  }

  void fire() {
    if (sRefArray.isNotEmpty || iSeqNoArray.isNotEmpty) {
      ref.read(kitchenProvider.notifier).doKitchenReprint(widget.salesNo,
          widget.splitNo, widget.tableNo, sRefArray, iSeqNoArray);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AppAlertDialog(
              onConfirm: () {},
              title: 'Error',
              message: 'No item to reprint, kindly select item(s) to reprint',
              isDark: isDark,
            );
          });
    }
  }
}
