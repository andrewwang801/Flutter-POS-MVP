import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../common/widgets/alert_dialog.dart';
import '../../common/widgets/custom_button.dart';
import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../application/trans_provider.dart';
import '../application/trans_state.dart';
import '../data/trans_sales_data_model.dart';
import 'trans_detail_screen.dart';
import 'widgets/kitchen_reprint_widget.dart';
import 'widgets/refund_widget.dart';

const List<String> btns = <String>[
  'Open',
  'View',
  'Refund',
  'Kitchen Re-Print',
  'Print Bill',
  'Close',
];

class ViewTransScreen extends ConsumerStatefulWidget {
  const ViewTransScreen({Key? key}) : super(key: key);

  @override
  _ViewTransScreenState createState() => _ViewTransScreenState();
}

class _ViewTransScreenState extends ConsumerState<ViewTransScreen> {
  final ScrollController _vScrollController = ScrollController();
  // final TransData transData = TransData();

  // Radio Group Value for Trans filter
  int filterGroupValue = 0;
  int rfidGroupValue = 0;

  // Multi Check Options for Trans filter
  bool tblOpenDate = false;
  bool posID = false;

  // theme
  late bool isDark;

  // Date Format, Start Date, End Date
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  DateFormat timeFormat = DateFormat('HH:mm:ss');
  DateTime startDate = DateTime.now(), endDate = DateTime.now();

  @override
  void initState() {
    // fetch trans data
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      ref.read(transProvider.notifier).fetchTransData(
          dateFormat.format(startDate),
          dateFormat.format(endDate),
          '00:00:00.0',
          '00:00:00.0');
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);

    ref.listen(
      transProvider,
      (previous, TransState next) {
        if (next.failiure != null) {
          showDialog(
              context: context,
              builder: (context) {
                return AppAlertDialog(
                  onConfirm: () {},
                  title: 'Error',
                  message: next.failiure?.errMsg ?? '',
                );
              });
        } else if (next.operation == Operation.KITCHEN_REPRINT) {
          showKitchenReprint();
        } else if (next.operation == Operation.REFUND) {
          showRefundWidget();
        }
      },
    );

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

  Widget transListView() {
    return Container();
  }

  // trans array
  List<TransSalesData> transArray = <TransSalesData>[];
  TransSalesData? selectedTrans;
  int selectedTransId = -1;
  Widget transTable() {
    TransState state = ref.watch(transProvider);

    if (state.workable == Workable.loading) {
      return const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(),
        ),
      );
    } else if (state.workable == Workable.ready) {
      TransData? data = state.transData;
      if (data != null) {
        transArray.clear();
        if (salesStatue == 'Open Tables') {
          transArray.addAll(data.transArrayOpened);
        } else if (salesStatue == 'Closed Tables') {
          transArray.addAll(data.transArrayClosed);
        } else if (salesStatue == 'All') {
          transArray.addAll(data.transArrayOpened);
          transArray.addAll(data.transArrayClosed);
        }
      }
      return Scrollbar(
        controller: _vScrollController,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _vScrollController,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                child: DataTable(
                  columns: <DataColumn>[
                    DataColumn(
                        label: Text('Rcptno', style: bodyTextLightStyle)),
                    DataColumn(label: Text('POSID', style: bodyTextLightStyle)),
                    DataColumn(label: Text('Table', style: bodyTextLightStyle)),
                    DataColumn(
                        label: Text('Remarks', style: bodyTextLightStyle)),
                    DataColumn(
                        label: Text('First Op', style: bodyTextLightStyle)),
                    DataColumn(label: Text('Total', style: bodyTextLightStyle)),
                    DataColumn(
                        label: Text('OpenDate', style: bodyTextLightStyle)),
                    DataColumn(label: Text('Time', style: bodyTextLightStyle)),
                    DataColumn(label: Text('Split', style: bodyTextLightStyle)),
                    DataColumn(label: Text('OP No', style: bodyTextLightStyle)),
                    DataColumn(
                        label: Text('Table Status', style: bodyTextLightStyle)),
                    DataColumn(label: Text('Mode', style: bodyTextLightStyle)),
                  ],
                  rows: List.generate(transArray.length, (index) {
                    return DataRow(
                        onSelectChanged: (bool? value) {
                          selectedTrans = transArray[index];
                          rcptNo = selectedTrans!.rcptNo;
                          salesNo = selectedTrans!.salesNo;
                          splitNo = selectedTrans!.splitNo;
                          tableNo = selectedTrans!.tableNo;
                          setState(() {
                            selectedTransId = index;
                          });
                        },
                        color: MaterialStateProperty.resolveWith((states) {
                          if (selectedTransId == index) {
                            return Colors.green;
                          } else if (index.isEven) {
                            return primaryDarkColor;
                          } else {
                            return backgroundDarkColor;
                          }
                        }),
                        cells: <DataCell>[
                          DataCell(Text(transArray[index].rcptNo)),
                          DataCell(Text(transArray[index].posID)),
                          DataCell(Text(transArray[index].tableNo)),
                          DataCell(Text(transArray[index].firstOp)),
                          DataCell(Text(transArray[index].total.toString())),
                          DataCell(Text(transArray[index].openDate)),
                          DataCell(Text(transArray[index].openTime)),
                          DataCell(Text(transArray[index].closeDate ?? '')),
                          DataCell(Text(transArray[index].closeTime ?? '')),
                          DataCell(Text(transArray[index].splitNo.toString())),
                          DataCell(Text(transArray[index].transMode)),
                          DataCell(Text(transArray[index].salesNo.toString())),
                        ]);
                  }),
                  // source: transData,
                  // columnSpacing: 40,
                  // horizontalMargin: 10,
                  // rowsPerPage: 10,
                  // showCheckboxColumn: false,
                ),
              )),
        ),
      );
    } else if (state.workable == Workable.failure) {
      return Center(
        child: Text(state.failiure?.errMsg ?? ''),
      );
    } else {
      return Container();
    }
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
            rfidWidget(),
            operatorDropDown(),
            salesStatusDropDown(),
            Row(
              children: [
                Checkbox(value: false, onChanged: (bool? value) {}),
                Text('TBL Open Date',
                    style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
              ],
            ),
            startDateWidget(),
            endDateWidget(),
            // Row(
            //   children: [
            //     Checkbox(value: false, onChanged: (bool? value) {}),
            //     Text('POSID',
            //         style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
            //   ],
            // ),
            verticalSpaceTiny,
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CustomButton(
                        callback: () {},
                        text: 'Refresh',
                        borderColor: Colors.green,
                        fillColor: Colors.green),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
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

  // Operator Drop Down
  String operator = 'All';
  Widget operatorDropDown() {
    List<String> operators = <String>['All', 'Cashier'];
    final List<DropdownMenuItem<String>> dropDownMenuItems = List.generate(
        operators.length,
        (int index) => DropdownMenuItem<String>(
            value: operators[index], child: Text(operators[index])));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Expanded(flex: 4, child: Text('Operator')),
        Expanded(
          flex: 6,
          child: Container(
            height: 20.h,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: primaryDarkColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButton<String>(
                underline: const SizedBox(),
                isExpanded: true,
                iconSize: iconSize,
                value: operator,
                items: dropDownMenuItems,
                onChanged: (String? value) {
                  setState(() {
                    operator = value!;
                  });
                }),
          ),
        ),
      ]),
    );
  }

  // Sales Status Drop Down
  String salesStatue = 'Open Tables';
  Widget salesStatusDropDown() {
    List<String> status = <String>['Open Tables', 'Closed Tables', 'All'];
    final List<DropdownMenuItem<String>> dropDownMenuItems = List.generate(
        status.length,
        (int index) => DropdownMenuItem<String>(
            value: status[index], child: Text(status[index])));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Expanded(flex: 4, child: Text('Sales Status')),
          Expanded(
            flex: 6,
            child: Container(
              height: 20.h,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
              decoration: BoxDecoration(
                color: primaryDarkColor,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: DropdownButton<String>(
                  underline: const SizedBox(),
                  iconSize: iconSize,
                  isExpanded: true,
                  value: salesStatue,
                  items: dropDownMenuItems,
                  onChanged: (String? value) {
                    setState(() {
                      salesStatue = value!;
                    });
                  }),
            ),
          ),
        ],
      ),
    );
  }

  // show Date Picker and select start date
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime(2022, 12));

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = DateTime.parse(dateFormat.format(picked));
        ref.read(transProvider.notifier).fetchTransData(
            dateFormat.format(startDate),
            dateFormat.format(endDate),
            '00:00:00.0',
            '00:00:00.0');
      });
    }
  }

  // show Date Picker and select end date
  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime(2022, 12));

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = DateTime.parse(dateFormat.format(picked));
        ref.read(transProvider.notifier).fetchTransData(
            dateFormat.format(startDate),
            dateFormat.format(endDate),
            '00:00:00.0',
            '00:00:00.0');
      });
    }
  }

  // Start Date Widget
  Widget startDateWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Expanded(flex: 4, child: Text('From Date')),
          Expanded(
            flex: 6,
            child: GestureDetector(
              onTap: () {
                _selectStartDate();
              },
              child: Container(
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                  child: Text(
                    dateFormat.format(startDate),
                    style: bodyTextLightStyle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // End date widget
  Widget endDateWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Expanded(flex: 4, child: Text('To Date')),
          Expanded(
            flex: 6,
            child: GestureDetector(
              onTap: () {
                _selectEndDate();
              },
              child: Container(
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                  child: Text(
                    dateFormat.format(endDate),
                    style: bodyTextLightStyle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Rfid wdiget
  Widget rfidWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Row(
            children: [
              Radio(value: 0, groupValue: 0, onChanged: (int? value) {}),
              Text('RFID',
                  style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
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
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
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
        )
      ],
    );
  }

  // Bottom btn group
  Widget buttonGroup() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
          itemCount: btns.length,
          physics: const ScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 25.h,
            mainAxisSpacing: 5.h,
            crossAxisSpacing: 5.w,
          ),
          itemBuilder: (BuildContext context, int index) {
            return CustomButton(
                callback: () {
                  switch (index) {
                    case 1:
                      Get.to(TransDetailScreen());
                      break;
                    case 2:
                      if (selectedTrans != null) {
                        ref
                            .read(transProvider.notifier)
                            .refund(salesNo, splitNo, rcptNo);
                      }
                      break;
                    case 3:
                      if (selectedTrans != null) {
                        ref.read(transProvider.notifier).kitchenReprint(
                            transArray, salesNo, salesStatue, selectedTrans!);
                      }
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

  int salesNo = 0;
  int splitNo = 0;
  String rcptNo = '';
  String tableNo = '';

  showKitchenReprint() {
    if (salesNo == 0 && selectedTrans != null) {
      rcptNo = selectedTrans!.rcptNo;
      salesNo = selectedTrans!.salesNo;
      splitNo = selectedTrans!.splitNo;
      tableNo = selectedTrans!.tableNo;
    }

    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return Dialog(
            child: KitchenReprint(
              salesNo: salesNo,
              splitNo: splitNo,
              tableNo: tableNo,
            ),
          );
        });
  }

  showRefundWidget() {
    if (selectedTrans != null) {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: RefundWidget(
                salesNo: salesNo,
                splitNo: splitNo,
                rcptNo: rcptNo,
              ),
            );
          });
    }
  }
}
