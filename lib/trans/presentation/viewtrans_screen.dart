import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../common/GlobalConfig.dart';
import '../../common/widgets/alert_dialog.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/custom_button.dart';
import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../home/presentation/home_screen.dart';
import '../../print/provider/print_provider.dart';
import '../../print/provider/print_state.dart';
import '../../printer/presentation/widget/empty_printers_widget.dart';
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
    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
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

    ref.listen(printProvider, (Object? previous, PrintState next) {
      if (next is PrintErrorState) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                message: next.errMsg,
              );
            });
      }
    });

    ref.listen(
      transProvider,
      (Object? previous, TransState next) {
        if (next.failiure != null) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
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
        } else if (next.operation == Operation.OPEN) {
          Get.to(HomeScreen());
        }
      },
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark ? backgroundDarkColor : backgroundColor,
      appBar: PreferredSize(
        child: AppBarWidget(false),
        preferredSize: Size.fromHeight(AppBar().preferredSize.height),
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
            height: 380.h,
            child: operationSideBar(),
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
      if (transArray.isEmpty) {
        return EmptyPrintersWidget(
          message: 'There are no transactions',
          icon: Icons.search,
          isDark: isDark,
        );
      }
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Scrollbar(
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
                          label: Text('Rcptno',
                              style: isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle)),
                      DataColumn(
                          label: Text('Table',
                              style: isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle)),
                      DataColumn(
                          label: Text('First Op',
                              style: isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle)),
                      DataColumn(
                          label: Text('Total',
                              style: isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle)),
                      DataColumn(
                          label: Text('Open Date',
                              style: isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle)),
                      DataColumn(
                          label: Text('Open Time',
                              style: isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle)),
                      DataColumn(
                          label: Text('Close Date',
                              style: isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle)),
                      DataColumn(
                          label: Text('Close Time',
                              style: isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle)),
                      DataColumn(
                          label: Text('Trans Mode',
                              style: isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle)),
                      DataColumn(
                          label: Text('POS ID',
                              style: isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle)),
                      DataColumn(
                          label: Text('Sales No',
                              style: isDark
                                  ? bodyTextDarkStyle
                                  : bodyTextLightStyle)),
                    ],
                    rows: List.generate(transArray.length, (int index) {
                      return DataRow(
                          onSelectChanged: (bool? value) {
                            selectedTrans = transArray[index];
                            rcptNo = selectedTrans!.rcptNo ?? '';
                            salesNo = selectedTrans!.salesNo;
                            splitNo = selectedTrans!.splitNo;
                            covers = selectedTrans!.covers;
                            tableNo = selectedTrans!.tableNo;
                            setState(() {
                              selectedTransId = index;
                            });
                          },
                          color: MaterialStateProperty.resolveWith(
                              (Set<MaterialState> states) {
                            if (selectedTransId == index) {
                              return Colors.green;
                            } else if (index.isEven) {
                              return isDark
                                  ? primaryDarkColor
                                  : backgroundColor.withOpacity(0.7);
                            } else {
                              return isDark
                                  ? backgroundDarkColor
                                  : backgroundColor;
                            }
                          }),
                          cells: <DataCell>[
                            DataCell(Text(transArray[index].rcptNo ?? '',
                                style: isDark
                                    ? bodyTextDarkStyle
                                    : bodyTextLightStyle)),
                            DataCell(Text(transArray[index].tableNo,
                                style: isDark
                                    ? bodyTextDarkStyle
                                    : bodyTextLightStyle)),
                            DataCell(Text(transArray[index].firstOp,
                                style: isDark
                                    ? bodyTextDarkStyle
                                    : bodyTextLightStyle)),
                            DataCell(Text(transArray[index].total.toString(),
                                style: isDark
                                    ? bodyTextDarkStyle
                                    : bodyTextLightStyle)),
                            DataCell(Text(transArray[index].openDate,
                                style: isDark
                                    ? bodyTextDarkStyle
                                    : bodyTextLightStyle)),
                            DataCell(Text(transArray[index].openTime,
                                style: isDark
                                    ? bodyTextDarkStyle
                                    : bodyTextLightStyle)),
                            DataCell(Text(transArray[index].closeDate ?? '',
                                style: isDark
                                    ? bodyTextDarkStyle
                                    : bodyTextLightStyle)),
                            DataCell(Text(transArray[index].closeTime ?? '',
                                style: isDark
                                    ? bodyTextDarkStyle
                                    : bodyTextLightStyle)),
                            DataCell(Text(transArray[index].transMode,
                                style: isDark
                                    ? bodyTextDarkStyle
                                    : bodyTextLightStyle)),
                            DataCell(Text(transArray[index].posID,
                                style: isDark
                                    ? bodyTextDarkStyle
                                    : bodyTextLightStyle)),
                            DataCell(Text(transArray[index].salesNo.toString(),
                                style: isDark
                                    ? bodyTextDarkStyle
                                    : bodyTextLightStyle)),
                          ]);
                    }),
                    // source: transData,
                    // columnSpacing: 40,
                    // horizontalMargin: 10,
                    // rowsPerPage: 10,
                    showCheckboxColumn: false,
                  ),
                )),
          ),
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
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
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
            buttonGroup(),
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
        border: Border.all(color: primaryDarkColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            rfidWidget(),
            verticalSpaceSmall,
            operatorDropDown(),
            salesStatusDropDown(),
            verticalSpaceSmall,
            Row(
              children: [
                Checkbox(value: false, onChanged: (bool? value) {}),
                Text('TBL Open Date',
                    style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
              ],
            ),
            verticalSpaceSmall,
            startDateWidget(),
            endDateWidget(),
            // Row(
            //   children: [
            //     Checkbox(value: false, onChanged: (bool? value) {}),
            //     Text('POSID',
            //         style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
            //   ],
            // ),
            verticalSpaceMedium,
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CustomButton(
                      callback: () {},
                      text: 'Refresh',
                      borderColor:
                          isDark ? primaryDarkColor : primaryLightColor,
                      fillColor: isDark ? primaryDarkColor : primaryLightColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CustomButton(
                      callback: () {},
                      text: 'Copy Bill',
                      borderColor:
                          isDark ? primaryDarkColor : primaryLightColor,
                      fillColor: isDark ? primaryDarkColor : primaryLightColor,
                    ),
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
        Expanded(
            flex: 4,
            child: Text(
              'Operator',
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
            )),
        Expanded(
          flex: 6,
          child: Container(
            height: Responsive.isMobile(context) ? 35.h : 20.h,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: isDark ? primaryDarkColor : primaryLightColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButton<String>(
                underline: const SizedBox(),
                isExpanded: true,
                iconSize:
                    Responsive.isTablet(context) ? lgiconSize : smiconSize,
                style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
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
          Expanded(
              flex: 4,
              child: Text(
                'Sales Status',
                style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
              )),
          Expanded(
            flex: 6,
            child: Container(
              height: Responsive.isMobile(context) ? 35.h : 20.h,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
              decoration: BoxDecoration(
                color: isDark ? primaryDarkColor : primaryLightColor,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: DropdownButton<String>(
                  underline: const SizedBox(),
                  iconSize:
                      Responsive.isTablet(context) ? lgiconSize : smiconSize,
                  isExpanded: true,
                  style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
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
          Expanded(
              flex: 4,
              child: Text(
                'From Date',
                style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
              )),
          Expanded(
            flex: 6,
            child: GestureDetector(
              onTap: () {
                _selectStartDate();
              },
              child: Container(
                height: Responsive.isMobile(context) ? 35.h : 20.h,
                decoration: BoxDecoration(
                  color: isDark ? primaryDarkColor : secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                  child: Text(
                    dateFormat.format(startDate),
                    style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
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
          Expanded(
              flex: 4,
              child: Text(
                'To Date',
                style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
              )),
          Expanded(
            flex: 6,
            child: GestureDetector(
              onTap: () {
                _selectEndDate();
              },
              child: Container(
                height: Responsive.isMobile(context) ? 35.h : 20.h,
                decoration: BoxDecoration(
                  color: isDark ? primaryDarkColor : secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                  child: Text(
                    dateFormat.format(endDate),
                    style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
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
    return Wrap(
      children: <Widget>[
        Row(
          children: [
            Radio(value: 0, groupValue: 0, onChanged: (int? value) {}),
            Text('RFID',
                style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: Responsive.isMobile(context) ? 35.h : 20.h,
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
                  color: isDark ? primaryDarkColor : primaryLightColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                height: Responsive.isMobile(context) ? 35.h : 20.h,
                width: 40.w,
                child: const Icon(
                  Icons.folder_open,
                  color: backgroundColor,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // Bottom btn group
  Widget buttonGroup() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
          shrinkWrap: true,
          itemCount: btns.length,
          physics: const ScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: Responsive.isMobile(context) ? 35.h : 25.h,
            mainAxisSpacing: 5.h,
            crossAxisSpacing: 5.w,
          ),
          itemBuilder: (BuildContext context, int index) {
            return CustomButton(
              callback: () {
                switch (index) {
                  case 0:
                    openTrans();
                    break;
                  case 1:
                    viewTrans();
                    break;
                  case 2:
                    refundTrans();
                    break;
                  case 3:
                    kitchenReprint();
                    break;
                  case 4:
                    // print bill
                    reprintBill();
                    break;
                  case 5:
                  default:
                    Get.back();
                    break;
                }
              },
              text: btns[index],
              borderColor: isDark ? primaryDarkColor : primaryLightColor,
              fillColor: isDark ? primaryDarkColor : primaryLightColor,
            );
          }),
    );
  }

  int salesNo = 0;
  int splitNo = 0;
  String rcptNo = '';
  String tableNo = '';
  int covers = 0;

  openTrans() {
    if (selectedTrans == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AppAlertDialog(
              onConfirm: () {},
              title: 'Error',
              message: 'Select transaction',
            );
          });
      return;
    }
    if (transArray.isEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AppAlertDialog(
              onConfirm: () {},
              title: 'Error',
              message:
                  'Open transaction failed. There is no data to open transaction',
            );
          });
    } else {
      if (salesStatue == 'Closed Tables') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                message:
                    'Cannot open closed table. Click view to open closed table',
              );
            });
      } else if (tableNo == GlobalConfig.tableNo) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                message: 'Open Transaction failed. Table is already opened',
              );
            });
      } else {
        if (salesNo == 0) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AppAlertDialog(
                  onConfirm: () {},
                  title: 'Error',
                  message: 'No table found to open',
                );
              });
        } else {
          ref
              .read(transProvider.notifier)
              .openTrans(salesNo, splitNo, covers, tableNo, rcptNo);
        }
      }
    }
  }

  viewTrans() {
    if (selectedTrans == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AppAlertDialog(
              onConfirm: () {},
              title: 'Error',
              message: 'Select transaction',
            );
          });
      return;
    }
    if (transArray.isEmpty) {
      if (selectedTrans == null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                message: 'There is no transcations',
              );
            });
        return;
      }
    } else {
      if (selectedTrans != null) {
        Get.to(TransDetailScreen(
          salesNo: salesNo,
          splitNo: splitNo,
          tableNo: tableNo,
          rcptNo: rcptNo,
          tableStatus: salesStatue,
        ));
      } else {
        // show error
      }
    }
  }

  refundTrans() {
    if (selectedTrans == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AppAlertDialog(
              onConfirm: () {},
              title: 'Error',
              message: 'Select transaction',
            );
          });
    } else {
      ref.read(transProvider.notifier).refund(salesNo, splitNo, rcptNo);
    }
  }

  reprintBill() {
    if (selectedTrans == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AppAlertDialog(
              onConfirm: () {},
              title: 'Error',
              message: 'Select transaction',
            );
          });
      return;
    }
    if (transArray.isEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AppAlertDialog(
              onConfirm: () {},
              title: 'Error',
              message: 'Reprint Bill Failed! There is no date to reprint',
            );
          });
    } else {
      if (salesStatue == 'Opened Tables') {
        if (tableNo == GlobalConfig.tableNo) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AppAlertDialog(
                  onConfirm: () {},
                  title: 'Error',
                  message:
                      'Reprint Bill Failed! Table is already for transaction',
                );
              });
        }
      }
      ref
          .read(transProvider.notifier)
          .reprintBill(selectedTrans!.transMode, salesNo, salesStatue);
    }
  }

  kitchenReprint() {
    if (selectedTrans == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AppAlertDialog(
              onConfirm: () {},
              title: 'Error',
              message: 'Select transaction',
            );
          });
    } else {
      ref
          .read(transProvider.notifier)
          .kitchenReprint(transArray, salesNo, salesStatue, selectedTrans!);
    }
  }

  showKitchenReprint() {
    if (salesNo == 0 && selectedTrans != null) {
      rcptNo = selectedTrans!.rcptNo ?? '';
      salesNo = selectedTrans!.salesNo;
      splitNo = selectedTrans!.splitNo;
      covers = selectedTrans!.covers;
      tableNo = selectedTrans!.tableNo;
    }

    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
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
          builder: (BuildContext context) {
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
