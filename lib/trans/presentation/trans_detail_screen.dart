import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/extension/string_extension.dart';
import '../../common/widgets/alert_dialog.dart';
import '../../common/widgets/custom_button.dart';
import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../floor_plan/presentation/widgets/area_widget.dart';
import '../../theme/theme_model.dart';
import '../../theme/theme_state_notifier.dart';
import '../application/trans_detail_provider.dart';
import '../application/trans_detail_state.dart';
import 'adapters/trans_detail_data.dart';

const List<String> btnTexts = <String>[
  'BILL ADJ',
  'TIP',
  'COVER',
  'CLOSE',
];

class TransDetailScreen extends ConsumerStatefulWidget {
  TransDetailScreen(
      {required this.salesNo,
      required this.splitNo,
      required this.tableNo,
      required this.rcptNo,
      required this.tableStatus,
      Key? key})
      : super(key: key);

  final int salesNo;
  final int splitNo;
  final String tableNo, rcptNo, tableStatus;

  @override
  _TransDetailScreenState createState() => _TransDetailScreenState();
}

class _TransDetailScreenState extends ConsumerState<TransDetailScreen> {
  ScrollController _vScrollController = ScrollController();

  //
  int sRef = 0, iSeqNo = 0, fFuncID = 0, funcID = 0, sFuncID = 0;
  String fMedia = '', medaiTitle = '';
  int tenderVal = 0;
  double amount = 0;

  int selectedIndex = -1, selectedMediaIndex = -1;
  bool showBillAdjust = false;

  late bool isDark;
  TransDetailState state = TransDetailState();

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      ref.read(transDetailProvier.notifier).fetchData(
          widget.salesNo, widget.splitNo, widget.tableNo, widget.tableStatus);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(transDetailProvier, (previous, TransDetailState next) {
      if (next.failiure != null) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                message: next.failiure!.errMsg,
              );
            });
      } else if (next.failiure == null) {
        if (next.operation == Operation.BILL_ADJUST) {
          setState(() {
            showBillAdjust = false;
          });
        } else if (next.operation == Operation.CHECK_BILL) {
          if (iSeqNo == 101) {
            setState(() {
              showBillAdjust = true;
            });
          } else {
            showDialog(
                context: context,
                builder: (context) {
                  return AppAlertDialog(
                    onConfirm: () {},
                    title: 'Error',
                    message: 'You did not selected any media.',
                  );
                });
          }
        }
      }
    });

    state = ref.watch(transDetailProvier);

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
      body: Column(
        children: [
          Expanded(child: transTable()),
          SizedBox(
              height: 150.h,
              child: Row(
                children: [
                  Expanded(
                    child: showBillAdjust
                        ? Column(children: [
                            Expanded(child: mediaListView()),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return primaryButtonDarkColor
                                        .withOpacity(0.6);
                                  } else if (states
                                      .contains(MaterialState.hovered)) {
                                    return Colors.red;
                                  } else {
                                    return primaryButtonDarkColor;
                                  }
                                }),
                                fixedSize:
                                    MaterialStateProperty.resolveWith((states) {
                                  return Size(100.w, 25.h);
                                }),
                                textStyle: MaterialStateProperty.resolveWith(
                                    (states) => bodyTextDarkStyle),
                              ),
                              onPressed: () {
                                ref
                                    .read(transDetailProvier.notifier)
                                    .doBillAdjust(
                                        medaiTitle,
                                        funcID,
                                        sFuncID,
                                        widget.salesNo,
                                        widget.splitNo,
                                        sRef,
                                        fMedia,
                                        widget.rcptNo,
                                        amount);
                              },
                              child: Text('Select'),
                            ),
                          ])
                        : Container(),
                  ),
                  transFunctions(),
                ],
              )),
        ],
      ),
    );
  }

  Widget mediaListView() {
    if (state.workable == Workable.ready) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            itemCount: state.transData!.billAdjArray.length,
            itemBuilder: (context, index) {
              List<String> item = state.transData!.billAdjArray[index];
              return Container(
                color: (selectedMediaIndex == index)
                    ? Colors.green
                    : index.isEven
                        ? primaryDarkColor
                        : backgroundDarkColor,
                child: ListTile(
                  onTap: () {
                    medaiTitle = item[0];
                    funcID = item[1].toInt();
                    sFuncID = item[2].toInt();
                    tenderVal = item[3].toInt();
                    setState(() {
                      selectedMediaIndex = index;
                    });
                  },
                  dense: true,
                  title: Text(item[0]),
                ),
              );
            }),
      );
    } else {
      return Container();
    }
  }

  void doBillAdjust() {
    if (medaiTitle.isEmpty) {
      // show Error msg
      showDialog(
          context: context,
          builder: (context) {
            return AppAlertDialog(
              onConfirm: () {},
              title: 'Error',
              message: 'Plesase select a Media before.',
            );
          });
    } else {
      if (tenderVal > 0 && tenderVal < amount) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                message:
                    'Bill Adjust Failed. Tender value of the selected media is $tenderVal',
              );
            });
      } else {
        if (fFuncID == 7) {
          showDialog(
              context: context,
              builder: (context) {
                return AppAlertDialog(
                  onConfirm: () {},
                  title: 'Error',
                  message:
                      'Bill adjust failed. You did not select any Media. Only Payment/Media is allowed to edit',
                );
              });
        } else if (funcID == 7) {
          showDialog(
              context: context,
              builder: (context) {
                return AppAlertDialog(
                  onConfirm: () {},
                  title: 'Error',
                  message:
                      'Bill Adjust Failed. Bill adjustment is not allowed from NON FOC media to FOC',
                );
              });
        } else {
          // ref.read(transDetailProvier.notifier).();
        }
      }
    }
  }

  Widget transTable() {
    List<DataRow> rows = [];
    if (state.workable == Workable.ready) {
      rows = List.generate(state.transData!.transDetail.length, (index) {
        List<String> e = state.transData!.transDetail[index];
        double amount = e[2].toDouble();
        double disc = e[4].toDouble();
        int funcID = e[12].toInt();

        return DataRow(
          cells: <DataCell>[
            DataCell(Text(e[0])),
            DataCell(Text(e[1])),
            if (funcID == 24 || funcID == 25 || funcID == 33)
              DataCell(Text('- $amount'))
            else
              DataCell(Text('$amount')),
            DataCell(Text(e[3])),
            DataCell(Text('$disc')),
            DataCell(Text(e[5])),
            DataCell(Text(e[6])),
            DataCell(Text(e[7])),
            DataCell(Text(e[8])),
            DataCell(Text(e[9])),
            DataCell(Text(e[10])),
            DataCell(Text(e[11])),
          ],
          onSelectChanged: (bool? value) {
            setState(() {
              iSeqNo = e[13].toInt();
              amount = e[2].toDouble();
              sRef = e[14].toInt();
              fFuncID = e[12].toInt();
              fMedia = e[1];
              selectedIndex = index;
            });
          },
          color: MaterialStateProperty.resolveWith((states) {
            if (selectedIndex == index) {
              return Colors.green;
            } else if (index.isEven) {
              return primaryDarkColor;
            } else {
              return backgroundDarkColor;
            }
          }),
        );
      });
    } else if (state.workable == Workable.loading) {}

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _vScrollController,
      child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _vScrollController,
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            child: DataTable(
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
              ],
              columnSpacing: 40,
              horizontalMargin: 10,
              showCheckboxColumn: false,
              rows: rows,
            ),
          )),
    );
  }

  Widget transFunctions() {
    final double marginTop = 3.5.h;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          children: [
            Container(
              width: 300.w,
              padding: EdgeInsets.all(25.0),
              margin: EdgeInsets.only(top: marginTop),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: <Widget>[
                      const Expanded(
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
                                    border: OutlineInputBorder(),
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
                      const Expanded(
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
                                    border: OutlineInputBorder(),
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
            Positioned(
              child: Container(
                color: isDark ? backgroundDarkColor : backgroundColor,
                child: Text('Table Details',
                    style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
              ),
            ),
          ],
        ),
        buttonGroup(),
      ],
    );
  }

  Widget buttonGroup() {
    return Container(
      width: 300.w,
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
          itemCount: btnTexts.length,
          physics: const ScrollPhysics(),
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
                    case 0:
                      if (sRef == 0) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AppAlertDialog(
                                onConfirm: () {},
                                title: 'Error',
                                message:
                                    'Bill Adjust Failed. Please select an item',
                              );
                            });
                      } else {
                        ref.read(transDetailProvier.notifier).checkBillAdj();
                      }
                      break;
                    case 1:
                      break;
                    case 2:
                      break;
                    case 3:
                    default:
                      Get.back();
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
