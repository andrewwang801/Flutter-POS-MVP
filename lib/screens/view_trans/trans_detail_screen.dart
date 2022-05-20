import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../data_source/trans_detail_data.dart';
import '../../model/theme_model.dart';
import '../../widgets/common/custom_button.dart';

const List<String> btnTexts = <String>[
  'BILL ADJ',
  'TIP',
  'COVER',
  'CLOSE',
];

class TransDetailScreen extends StatefulWidget {
  TransDetailScreen({Key? key}) : super(key: key);

  @override
  State<TransDetailScreen> createState() => _TransDetailScreenState();
}

class _TransDetailScreenState extends State<TransDetailScreen> {
  TransDetailData transDetailData = TransDetailData();
  ScrollController _vScrollController = ScrollController();

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
        body: Column(
          children: [
            transTable(),
            Expanded(child: transFunctions()),
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
                DataColumn(label: Text('QTY', style: bodyTextLightStyle)),
                DataColumn(label: Text('ItemName', style: bodyTextLightStyle)),
                DataColumn(label: Text('Amount', style: bodyTextLightStyle)),
                DataColumn(label: Text('DiscType', style: bodyTextLightStyle)),
                DataColumn(label: Text('Disc', style: bodyTextLightStyle)),
                DataColumn(label: Text('Operator', style: bodyTextLightStyle)),
                DataColumn(label: Text('PrmnType', style: bodyTextLightStyle)),
                DataColumn(label: Text('Prmn', style: bodyTextLightStyle)),
                DataColumn(label: Text('Mode', style: bodyTextLightStyle)),
                DataColumn(label: Text('Status', style: bodyTextLightStyle)),
                DataColumn(label: Text('St No', style: bodyTextLightStyle)),
                DataColumn(label: Text('Mem ID', style: bodyTextLightStyle)),
                DataColumn(label: Text('Date', style: bodyTextLightStyle)),
                DataColumn(label: Text('Time', style: bodyTextLightStyle)),
                DataColumn(label: Text('Table No', style: bodyTextLightStyle)),
                DataColumn(label: Text('Op No', style: bodyTextLightStyle)),
                DataColumn(
                    label: Text('Trans OP NO', style: bodyTextLightStyle)),
                DataColumn(label: Text('Points', style: bodyTextLightStyle)),
                DataColumn(
                    label: Text('Deposit ID', style: bodyTextLightStyle)),
                DataColumn(
                    label: Text('Rental Item', style: bodyTextLightStyle)),
                DataColumn(label: Text('Foc Item', style: bodyTextLightStyle)),
                DataColumn(label: Text('Covers', style: bodyTextLightStyle)),
                DataColumn(label: Text('Gratuity', style: bodyTextLightStyle)),
                DataColumn(label: Text('Pos ID', style: bodyTextLightStyle)),
              ],
              source: transDetailData,
              columnSpacing: 40,
              horizontalMargin: 10,
              rowsPerPage: 8,
              showCheckboxColumn: false,
            ),
          )),
    );
  }

  Widget transFunctions() {
    final double marginTop = 3.5.h;
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            children: [
              Container(
                width: 300.w,
                padding: EdgeInsets.all(12.0),
                margin: EdgeInsets.only(top: marginTop),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Text('Cover'),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4.0)),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 2.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Text('Tip'),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4.0)),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 2.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: themeNotifier.isDark
                    ? backgroundDarkColor
                    : backgroundColor,
                child: Positioned(
                  child: Text('Table Details',
                      style: themeNotifier.isDark
                          ? bodyTextDarkStyle
                          : bodyTextLightStyle),
                ),
              ),
            ],
          ),
          buttonGroup(),
        ],
      );
    });
  }

  Widget buttonGroup() {
    return Container(
      width: 300.w,
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
