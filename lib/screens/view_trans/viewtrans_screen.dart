import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../data_source/trans_data.dart';
import '../../model/theme_model.dart';
import '../../widgets/common/custom_button.dart';
import '../cash_screen.dart';
import 'trans_detail_screen.dart';

const List<String> btnTexts = <String>[
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

class ViewTransScreen extends StatefulWidget {
  ViewTransScreen({Key? key}) : super(key: key);

  @override
  State<ViewTransScreen> createState() => _ViewTransScreenState();
}

class _ViewTransScreenState extends State<ViewTransScreen> {
  final ScrollController _vScrollController = ScrollController();
  final TransData transData = TransData();

  // Radio Group Value for Trans filter
  int filterGroupValue = 0;
  int rfidGroupValue = 0;

  // Multi Check Options for Trans filter
  bool tblOpenDate = false;
  bool posID = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
        backgroundColor:
            themeNotifier.isDark ? backgroundDarkColor : backgroundColor,
        appBar: AppBar(
          title: Text('Raptor POS', style: titleTextDarkStyle),
          actions: [
            IconButton(
                icon: Icon(themeNotifier.isDark
                    ? Icons.nightlight_round
                    : Icons.wb_sunny),
                onPressed: () {
                  themeNotifier.isDark
                      ? themeNotifier.isDark = false
                      : themeNotifier.isDark = true;
                })
          ],
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 626.w,
              height: 424.h - AppBar().preferredSize.height,
              color:
                  themeNotifier.isDark ? backgroundDarkColor : backgroundColor,
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
    });
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
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
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
                      color: themeNotifier.isDark
                          ? backgroundDarkColor
                          : backgroundColor,
                      child: Text('Find',
                          style: themeNotifier.isDark
                              ? bodyTextDarkStyle
                              : bodyTextLightStyle),
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
    });
  }

  Widget filterGroup() {
    final double marginTop = 3.5.h;
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
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
                      style: themeNotifier.isDark
                          ? bodyTextDarkStyle
                          : bodyTextLightStyle),
                ],
              ),
              Row(
                children: <Widget>[
                  Radio(value: 0, groupValue: 0, onChanged: (int? value) {}),
                  Text('Selected Operator',
                      style: themeNotifier.isDark
                          ? bodyTextDarkStyle
                          : bodyTextLightStyle),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Radio(
                            value: 0,
                            groupValue: 0,
                            onChanged: (int? value) {}),
                        Text('RFID',
                            style: themeNotifier.isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
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
                      style: themeNotifier.isDark
                          ? bodyTextDarkStyle
                          : bodyTextLightStyle),
                ],
              ),
              Row(
                children: [
                  Checkbox(value: false, onChanged: (bool? value) {}),
                  Text('POSID',
                      style: themeNotifier.isDark
                          ? bodyTextDarkStyle
                          : bodyTextLightStyle),
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
    });
  }

  Widget buttonGroup() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
          itemCount: btnTexts.length,
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
                text: btnTexts[index],
                borderColor: Colors.green,
                fillColor: Colors.green);
          }),
    );
  }
}
