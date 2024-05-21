import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';
import 'package:riverpod/riverpod.dart';

import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import 'adapters/trans_data.dart';
import '../../theme/theme_model.dart';
import '../../common/widgets/custom_button.dart';
import '../../payment/presentation/cash_screen.dart';
import 'trans_detail_screen.dart';

const List<String> btns = <String>[
  'Open',
  'View',
  'New Table',
  'Tender',
  'Release Table',
  'Print',
  'Kitchen Re-Print',
  'Re-Print All',
  'Close',
];

class ViewTransScreen extends ConsumerStatefulWidget {
  ViewTransScreen({Key? key}) : super(key: key);

  @override
  _ViewTransScreenState createState() => _ViewTransScreenState();
}

class _ViewTransScreenState extends ConsumerState<ViewTransScreen> {
  final ScrollController _vScrollController = ScrollController();
  final TransData transData = TransData();

  // Radio Group Value for Trans filter
  int filterGroupValue = 0;
  int rfidGroupValue = 0;

  // Multi Check Options for Trans filter
  bool tblOpenDate = false;
  bool posID = false;

  late bool isDark;

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: isDark ? backgroundDarkColor : backgroundColor,
      appBar: AppBar(
        title: Text('Raptor POS', style: titleTextDarkStyle),
        actions: [
          IconButton(
              icon: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
              onPressed: () {
                isDark ? isDark = false : isDark = true;
              })
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 626.w,
            height: 424.h - AppBar().preferredSize.height,
            color: isDark ? backgroundDarkColor : backgroundColor,
            child: transTable(),
          ),
          SizedBox(
            width: 300.w,
            child: Container(
              child: operationSideBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget transTable() {
    return Scrollbar(
      controller: _vScrollController,
      isAlwaysShown: true,
      child: SingleChildScrollView(
          controller: _vScrollController,
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            child: PaginatedDataTable(
              columns: <DataColumn>[
                DataColumn(label: Text('Rcptno', style: bodyTextLightStyle)),
                DataColumn(label: Text('POSID', style: bodyTextLightStyle)),
                DataColumn(label: Text('Table', style: bodyTextLightStyle)),
                DataColumn(label: Text('Remarks', style: bodyTextLightStyle)),
                DataColumn(label: Text('First Op', style: bodyTextLightStyle)),
                DataColumn(label: Text('Total', style: bodyTextLightStyle)),
                DataColumn(label: Text('OpenDate', style: bodyTextLightStyle)),
                DataColumn(label: Text('Time', style: bodyTextLightStyle)),
                DataColumn(label: Text('Split', style: bodyTextLightStyle)),
                DataColumn(label: Text('OP No', style: bodyTextLightStyle)),
                DataColumn(
                    label: Text('Table Status', style: bodyTextLightStyle)),
                DataColumn(label: Text('Mode', style: bodyTextLightStyle)),
              ],
              source: transData,
              columnSpacing: 40,
              horizontalMargin: 10,
              rowsPerPage: 8,
              showCheckboxColumn: false,
            ),
          )),
    );
  }

  Widget operationSideBar() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: [
                filterGroup(),
                Positioned(
                  child: Container(
                    color: isDark ? backgroundDarkColor : backgroundColor,
                    child: Text('Find',
                        style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            Expanded(child: buttonGroup()),
          ],
        ),
      ),
    );
  }

  Widget filterGroup() {
    final double marginTop = 3.5.h;
    return Container(
      margin: EdgeInsets.only(top: marginTop),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Radio(value: 0, groupValue: 0, onChanged: (int? value) {}),
                Text('All',
                    style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
              ],
            ),
            Row(
              children: <Widget>[
                Radio(value: 0, groupValue: 0, onChanged: (int? value) {}),
                Text('Selected Operator',
                    style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Radio(
                          value: 0, groupValue: 0, onChanged: (int? value) {}),
                      Text('RFID',
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 20.h,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          height: 20.h,
                          width: 40.w,
                          child: const Icon(Icons.folder_open),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(value: false, onChanged: (bool? value) {}),
                Text('TBL Open Date',
                    style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
              ],
            ),
            Row(
              children: [
                Checkbox(value: false, onChanged: (bool? value) {}),
                Text('POSID',
                    style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: CustomButton(
                        callback: () {},
                        text: 'Refresh',
                        borderColor: Colors.green,
                        fillColor: Colors.green),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: CustomButton(
                        callback: () {},
                        text: 'Copy Bill',
                        borderColor: Colors.green,
                        fillColor: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonGroup() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
          itemCount: btns.length,
          physics: ScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 25.h,
            mainAxisSpacing: 5.h,
            crossAxisSpacing: 5.w,
          ),
          itemBuilder: (context, index) {
            return CustomButton(
                callback: () {
                  switch (index) {
                    case 1:
                      Get.to(TransDetailScreen());
                      break;
                    case 3:
                      Get.to(CashScreen());
                      break;
                    default:
                      break;
                  }
                },
                text: btns[index],
                borderColor: Colors.green,
                fillColor: Colors.green);
          }),
    );
  }
}
