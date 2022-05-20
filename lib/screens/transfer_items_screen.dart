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

class TransferItemsScreen extends StatefulWidget {
  TransferItemsScreen({Key? key}) : super(key: key);

  @override
  State<TransferItemsScreen> createState() => _TransferItemsScreenState();
}

class _TransferItemsScreenState extends State<TransferItemsScreen> {
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
          title: Text('Transfer Items', style: titleTextDarkStyle),
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
          children: [
            Expanded(child: transTable()),
            SizedBox(
              width: 60.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    width: 50.w,
                    callback: () {},
                    text: '<<',
                    borderColor: themeNotifier.isDark
                        ? backgroundDarkColor
                        : backgroundColor,
                    fillColor: secondaryButtonColor,
                  ),
                  CustomButton(
                    width: 50.w,
                    callback: () {},
                    text: '<<',
                    borderColor: themeNotifier.isDark
                        ? backgroundDarkColor
                        : backgroundColor,
                    fillColor: secondaryButtonColor,
                  )
                ],
              ),
            ),
            Expanded(child: transTable()),
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
              rowsPerPage: 10,
              showCheckboxColumn: false,
            ),
          )),
    );
  }

  Widget buttonGroup() {
    return Container();
  }
}
