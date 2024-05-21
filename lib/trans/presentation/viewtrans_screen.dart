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

  final TextEditingController _searchController = TextEditingController();
  String searchKeyword = '';
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
                isDark: isDark,
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
                  isDark: isDark,
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
      backgroundColor: isDark ? backgroundDarkColor : backgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back),
          color: isDark ? primaryDarkColor : primaryDarkColor,
        ),
        title: Text(
          'All Transaction',
          style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              showFilterBottomSheet();
            },
            icon: Icon(
              Icons.filter_list,
              color: red,
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            _searchBar(),
            verticalSpaceRegular,
            Expanded(
              child: transTable(),
            ),
          ],
        ),
      ),
    );
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

      List<TransSalesData> filteredTransArray = [];
      filteredTransArray = transArray.where((trans) {
        String strTrans =
            '${trans.rcptNo}${trans.tableNo}${trans.firstOp}${trans.total}${trans.openDate}${trans.closeDate}${trans.openTime}${trans.closeTime}${trans.transMode}${trans.posID}${trans.salesNo}';
        return strTrans.contains(searchKeyword);
      }).toList();
      return ListView.separated(
          physics: ClampingScrollPhysics(),
          separatorBuilder: ((context, index) => verticalSpaceSmall),
          itemCount: filteredTransArray.length,
          itemBuilder: ((context, index) {
            TransSalesData trans = filteredTransArray[index];
            return transCard((trans) {
              showActionBottomSheet(trans);
            }, trans);
          }));
    } else if (state.workable == Workable.failure) {
      return Center(
        child: Text(state.failiure?.errMsg ?? ''),
      );
    } else {
      return Container();
    }
  }

  Widget transCard(
      void Function(TransSalesData trans)? callback, TransSalesData trans) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.sm)),
      child: InkWell(
        borderRadius: BorderRadius.circular(Spacing.sm),
        onTap: () {
          if (callback != null) {
            callback(trans);
          }
        },
        child: Ink(
          padding: EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(
            color: isDark ? primaryDarkColor : backgroundColorVariant,
            border: Border.all(
                width: 1,
                color: isDark ? primaryDarkColor : backgroundColorVariant),
            borderRadius: BorderRadius.circular(Spacing.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text('${trans.openDate} ${trans.openTime}'),
                  Spacer(),
                  Text('${trans.closeDate} ${trans.closeTime}'),
                ],
              ),
              verticalSpaceSmall,
              Row(
                children: [
                  Text('${trans.posID}'),
                  Spacer(),
                  Text('${trans.covers}'),
                ],
              ),
              verticalSpaceSmall,
              Row(
                children: [
                  Text('${trans.rcptNo}'),
                  Spacer(),
                  Text('${trans.transMode}'),
                ],
              ),
              verticalSpaceRegular,
              Text(
                '${trans.total}',
                style: isDark ? titleTextDarkStyle : titleTextLightStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showFilterBottomSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.sm)),
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    operatorDropDown(),
                    verticalSpaceSmall,
                    salesStatusDropDown(),
                    verticalSpaceSmall,
                    startDateWidget(),
                    verticalSpaceSmall,
                    endDateWidget(),
                  ],
                ),
              ),
            ],
          );
        });
  }

  void showActionBottomSheet(TransSalesData trans) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.sm),
        ),
        builder: (BuildContext context) {
          return Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    transCard(null, trans),
                    ElevatedButton(
                      onPressed: () {
                        openTrans();
                      },
                      child: Text('Open'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(40.h),
                        primary: red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.sm),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        viewTrans();
                      },
                      child: Text('View'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(40.h),
                        primary: red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.sm),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        refundTrans();
                      },
                      child: Text('Refund'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(40.h),
                        primary: red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.sm),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        kitchenReprint();
                      },
                      child: Text('Kitchen Reprint'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(40.h),
                        primary: red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.sm),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        reprintBill();
                      },
                      child: Text(
                        'Reprint',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(40.h),
                        primary: red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.sm),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _searchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Spacing.sm),
        border: Border.all(width: 1, color: backgroundColorVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Empty',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (String value) {
                setState(() {
                  searchKeyword = value;
                });
              },
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () {},
            icon: Icon(
              Icons.search,
            ),
          ),
        ],
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
        value: operators[index],
        child: Text(operators[index]),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Operator: ',
          style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
        ),
        Container(
          width: 250.w,
          padding: const EdgeInsets.symmetric(
              horizontal: 12.0, vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: isDark ? primaryDarkColor : Colors.white,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(width: 1, color: orange),
          ),
          child: DropdownButton<String>(
              borderRadius: BorderRadius.circular(Spacing.sm),
              isDense: true,
              isExpanded: true,
              underline: const SizedBox(),
              iconSize: Responsive.isTablet(context) ? lgiconSize : smiconSize,
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
              value: operator,
              items: dropDownMenuItems,
              onChanged: (String? value) {
                setState(() {
                  operator = value!;
                });
              }),
        ),
      ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Status: ',
          style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
        ),
        Container(
          width: 250.w,
          padding: const EdgeInsets.symmetric(
              horizontal: 12.0, vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: isDark ? primaryDarkColor : Colors.white,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(width: 1, color: orange),
          ),
          child: DropdownButton<String>(
              borderRadius: BorderRadius.circular(Spacing.sm),
              underline: const SizedBox(),
              isDense: true,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: orange,
              ),
              iconSize: Responsive.isTablet(context) ? lgiconSize : smiconSize,
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
              value: salesStatue,
              items: dropDownMenuItems,
              onChanged: (String? value) {
                setState(() {
                  salesStatue = value!;
                });
              }),
        ),
      ],
    );
  }

  // show Date Picker and select start date
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime(2029, 12, 31));

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
        lastDate: DateTime(2029, 12, 31));

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'From: ',
          style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
        ),
        Container(
          width: 250.w,
          child: ElevatedButton(
            onPressed: () {
              _selectStartDate();
            },
            child: Text(
              dateFormat.format(startDate),
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
            ),
            style: ElevatedButton.styleFrom(
              primary: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.xs),
                side: BorderSide(width: 1.0, color: red),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // End date widget
  Widget endDateWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'To: ',
          style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
        ),
        Container(
          width: 250.w,
          child: ElevatedButton(
            onPressed: () {
              _selectEndDate();
            },
            child: Text(
              dateFormat.format(endDate),
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
            ),
            style: ElevatedButton.styleFrom(
              primary: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.xs),
                side: BorderSide(width: 1.0, color: red),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Rfid wdiget
  Widget rfidWidget() {
    return Row(
      children: <Widget>[
        Radio(value: 0, groupValue: 0, onChanged: (int? value) {}),
        Text('RFID', style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
      ],
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
              isDark: isDark,
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
              isDark: isDark,
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
                isDark: isDark,
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
                isDark: isDark,
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
                  isDark: isDark,
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
              isDark: isDark,
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
                isDark: isDark,
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
              isDark: isDark,
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
              isDark: isDark,
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
              isDark: isDark,
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
                  isDark: isDark,
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
              isDark: isDark,
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
