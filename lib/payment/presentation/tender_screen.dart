import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/common/extension/workable.dart';
import 'package:raptorpos/common/widgets/checkout_list.dart';
import 'package:raptorpos/common/widgets/checkout_summary.dart';
import 'package:raptorpos/common/widgets/drawer.dart';
import 'package:raptorpos/common/widgets/order_header.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/functions/application/function_provider.dart';
import 'package:raptorpos/functions/application/function_state.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../../common/keyboard/virtual_keyboard_2.dart';
import '../../common/utils/type_util.dart';
import '../../common/widgets/alert_dialog.dart';
import '../../common/widgets/numpad.dart';
import '../../constants/color_constant.dart';
import '../../constants/dimension_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../floor_plan/presentation/floor_plan_screen.dart';
import '../../home/provider/order/order_provider.dart';
import '../../print/provider/print_provider.dart';
import '../../print/provider/print_state.dart';
import '../../theme/theme_state_notifier.dart';
import '../model/media_data_model.dart';
import '../model/payment_details_data_model.dart';
import '../provider/payment_provider.dart';
import '../provider/payment_state.dart';
import '../repository/i_payment_repository.dart';

class TenderScreen extends ConsumerStatefulWidget {
  TenderScreen({Key? key, required this.gTotal}) : super(key: key);
  final double gTotal;

  @override
  _CashScreenState createState() => _CashScreenState();
}

class _CashScreenState extends ConsumerState<TenderScreen> with TypeUtil {
  late IPaymentRepository paymentRepository;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isDark = false;
  // Total Remaining
  double gtAmount = 0;
  // Partial Payment Value
  double payValue = 0;
  // Change Amount
  double change = 0;

  int? payType;
  int salesRef = 0;
  int payTag = 1;

  String customID = '';
  int funcID = 0;

  List<MediaData> tenderArray = <MediaData>[];
  List<PaymentDetailsData> tenderDetail = <PaymentDetailsData>[];

  TextEditingController _controller = TextEditingController();
  TextEditingController _alphaNumericController = TextEditingController();

  late IPaymentRepository _paymentRepository;

  int? selectedPayment;

  @override
  void initState() {
    _paymentRepository = GetIt.I<IPaymentRepository>();
    ref.read(paymentProvider.notifier).fetchPaymentData(0, 0);

    // Print
    ref.read(printProvider.notifier).kpPrint();
    // End of Print

    _controller.addListener(() {
      setState(() {
        payValue = _controller.text.toDouble();
        if (gtAmount > widget.gTotal)
          change = gtAmount - widget.gTotal;
        else
          change = 0;
      });
    });

    _alphaNumericController.addListener(() {
      setState(() {
        customID = _alphaNumericController.text;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);
    PaymentState state = ref.watch(paymentProvider);

    OrderState orderState = ref.watch(orderProvoder);

    double totalTax = 0.0;
    if (orderState.workable == Workable.ready && orderState.bills != null) {
      for (var i = 4; i < orderState.bills!.length; i++) {
        totalTax += orderState.bills![i];
      }
    }

    ref.listen(functionProvider, (previous, FunctionState next) {
      if (next.failiure != null) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                isDark: isDark,
                message: next.failiure!.errMsg,
              );
            });
      }
    });
    ref.listen(printProvider, (previous, next) {
      if (next is PrintSuccessState) {
      } else if (next is PrintErrorState) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                insetPadding: EdgeInsets.all(20),
                title: 'Error',
                isDark: isDark,
                message: next.errMsg,
                onConfirm: () {},
              );
            });
      }
    });

    ref.listen<PaymentState>(paymentProvider, (prev, next) async {
      if (next is PaymentSuccessState) {
        switch (next.status) {
          case PaymentStatus.PAID:
            await ref
                .read(printProvider.notifier)
                .printBill(GlobalConfig.salesNo, 'Close Tables');
            Get.back();
            Get.to(FloorPlanScreen());
            break;
          case PaymentStatus.SEND_RECEIPT:
            break;
          case PaymentStatus.REPRINT:
            break;
          case PaymentStatus.CLOSE_RECIPT:
            break;
          case PaymentStatus.SHOW_ALERT:
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AppAlertDialog(
                    insetPadding: EdgeInsets.all(20),
                    title: 'Tender Payment',
                    isDark: isDark,
                    message:
                        'Payment: $payValue, Total Bill: $gtAmount, Change: ${change.toStringAsFixed(2)}',
                    onCancel: () {},
                    onConfirm: () {
                      ref
                          .read(paymentProvider.notifier)
                          .updatePaymentStatus(PaymentStatus.PAID);
                    },
                  );
                });
            break;
          case PaymentStatus.NONE:
          case null:
            break;
          case PaymentStatus.PERMISSION_ERROR:
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AppAlertDialog(
                    insetPadding: EdgeInsets.all(20),
                    title: 'Remove Payment',
                    isDark: isDark,
                    message: 'Not Enough Permission to Remove Payment',
                    onConfirm: () {},
                  );
                });
            break;
          case PaymentStatus.PAYMENT_REMOVED:
            ref.read(paymentProvider.notifier).fetchPaymentData(payTag, funcID);
            break;
        }
      } else if (next is PaymentErrorState) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                insetPadding: EdgeInsets.all(20),
                title: 'Error',
                isDark: isDark,
                message: next.msg,
                onConfirm: () {},
              );
            });
      }
    });

    if (state is PaymentSuccessState)
      gtAmount = widget.gTotal - (state.paidValue ?? 0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? backgroundDarkColor : backgroundColorVariant,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        leading: Container(
          padding: EdgeInsets.all(Spacing.sm),
          child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: CircleBorder(),
              ),
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              child: const Icon(
                Icons.menu,
                size: smiconSize,
              )),
        ),
        title: Text(
          'Table: ${GlobalConfig.tableNo}   Cover: ${GlobalConfig.cover}   Mode: ${GlobalConfig.TransMode}   Rcp: ${GlobalConfig.rcptNo}',
          style: isDark ? listItemTextDarkStyle : listItemTextLightStyle,
          textAlign: TextAlign.left,
        ),
        actions: [
          Container(
            padding: EdgeInsets.all(Spacing.sm),
            child: ElevatedButton(
              onPressed: () {},
              child: Text('close'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(lightRed),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Spacing.sm)),
                ),
              ),
            ),
          ),
          // IconButton(
          //     icon: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
          //     onPressed: () {
          //       isDark ? isDark = false : isDark = true;
          //       ref.read(themeProvider.notifier).setTheme(isDark);
          //     })
        ],
      ),
      body: Row(
        children: [
          SizedBox(
              width: Responsive.isMobile(context) ? 400.w : 320.w,
              child: Container(
                padding: EdgeInsets.all(Spacing.xs),
                color: isDark
                    ? primaryDarkColor.withOpacity(0.9)
                    : Colors.white.withOpacity(1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Order(),
                    OrderHeader(),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? primaryDarkColor : Colors.white,
                        ),
                        child: CheckoutList(),
                      ),
                    ),
                    verticalSpaceSmall,
                    checkout_summary(
                        isDark: isDark, state: orderState, totalTax: totalTax),
                    _paymentEdit(),
                    NumPad(
                      buttonColor:
                          isDark ? primaryButtonDarkColor : Colors.white,
                      delete: () {},
                      onSubmit: () {},
                      controller: _controller,
                      onlyNum: true,
                    ),
                  ],
                ),
              )),
          Expanded(child: _rightSide(state)),
        ],
      ),
      drawer: SideBarDrawer(),
    );
  }

  Widget _rightSide(PaymentState state) {
    if (state is! PaymentSuccessState) {
      return Center(child: const Text('loading...'));
    } else {
      tenderArray = state.tenderArray ?? [];
      tenderDetail = state.tenderDetail ?? [];
      return Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(Spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tender Modes',
                    style: isDark ? titleTextDarkStyle : titleTextLightStyle,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Expanded(
                    // height: 200.h,
                    child: GridView.builder(
                      physics: ClampingScrollPhysics(),
                      itemCount: tenderArray.length,
                      itemBuilder: (BuildContext context, int index) {
                        MediaData mediaData = tenderArray[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(Spacing.sm),
                            onTap: () {
                              mediaSelect(mediaData);
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Spacing.sm),
                                color: mediaData.title == 'Back'
                                    ? Colors.red
                                    : isDark
                                        ? primaryDarkColor
                                        : Colors.white,
                              ),
                              child: Center(
                                child: Text(mediaData.title,
                                    textAlign: TextAlign.center,
                                    style: isDark
                                        ? listItemTextDarkStyle
                                        : listItemTextLightStyle),
                              ),
                            ),
                          ),
                        );
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisExtent: 50.h - 10,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(Spacing.sm),
              color: Colors.white,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Spacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  color: backgroundColorVariant,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Detail'),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Spacing.sm),
                            child: Column(
                              children: [
                                Container(
                                  color: isDark
                                      ? primaryDarkColor.withOpacity(0.8)
                                      : orange.withOpacity(0.8),
                                  child: ListTile(
                                    tileColor: red,
                                    dense: true,
                                    title: Text(
                                      'Media Type',
                                      style: isDark
                                          ? bodyTextDarkStyle
                                          : bodyTextLightStyle,
                                    ),
                                    trailing: Text(
                                      'Amount',
                                      style: isDark
                                          ? bodyTextDarkStyle
                                          : bodyTextLightStyle,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                      color: isDark
                                          ? primaryDarkColor.withOpacity(0.6)
                                          : Colors.white.withOpacity(0.6),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount: tenderDetail.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return _payentDetailListItem(
                                                      index);
                                                }),
                                          ),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Text(
                              'Amount Due: ',
                              style: isDark
                                  ? normalTextDarkStyle
                                  : normalTextLightStyle,
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(Spacing.sm),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(Spacing.sm),
                                  border: Border.all(width: 1.0, color: orange),
                                ),
                                child: Text(
                                  '${gtAmount.toStringAsFixed(2)}',
                                  style: isDark
                                      ? normalTextDarkStyle
                                      : normalTextLightStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _rightBottomBtnGroup(),
        ],
      );
    }
  }

  Widget _paymentEdit() {
    return Container(
      padding: EdgeInsets.all(Spacing.sm),
      margin: EdgeInsets.only(bottom: Spacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? primaryDarkColor.withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(Spacing.xs),
        border: Border.all(width: 1, color: orange),
      ),
      child: Center(
        child: Text(
          '$payValue',
          style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
        ),
      ),
    );
  }

  Widget _payentDetailListItem(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: (selectedPayment != null && selectedPayment == index)
              ? Border.all(width: 1, color: orange)
              : Border.all(width: 0, color: Colors.transparent),
        ),
        child: ListTile(
          dense: true,
          title: Text(
            '${tenderDetail[index].name}',
            style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
          ),
          trailing: Text(
            '${tenderDetail[index].amount}',
            style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
          ),
        ),
      ),
    );
  }

  Widget _rightBottomBtnGroup() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: () {
              ref
                  .read(printProvider.notifier)
                  .printBill(GlobalConfig.salesNo, '');
            },
            child: Text('Print Bill'),
            style: ElevatedButton.styleFrom(
              primary: orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.sm),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('FOC Payment'),
            style: ElevatedButton.styleFrom(
              primary: red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.sm),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedPayment != null)
                ref
                    .read(paymentProvider.notifier)
                    .removePayment(tenderDetail[selectedPayment!]);
            },
            child: Text('Remove Payment'),
            style: ElevatedButton.styleFrom(
              primary: red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.sm),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: Text('BACK TO MAIN'),
            style: ElevatedButton.styleFrom(
              primary: red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.sm),
              ),
            ),
          )
        ],
      ),
    );
  }

// Do partial Payment when tap Media
  Future<void> mediaSelect(MediaData list) async {
    funcID = list.funcID;
    if (payTag == 1) {
      ref.read(paymentProvider.notifier).fetchPaymentData(payTag, funcID);
      payTag = 2;
    } else {
      final String title = list.title;
      if (title == 'Back') {
        ref.read(paymentProvider.notifier).fetchPaymentData(payTag, funcID);
        payTag = 1;
      } else {
        bool promptCustID = list.propForCustID;
        double tenderValue = list.tenderValue;
        double minimum = list.minimum;
        double maxmimum = list.maximum;
        payType = list.subFuncID;

        if (minimum > gtAmount) {
          showDialog(
              context: context,
              builder: (context) {
                return AppAlertDialog(
                  title: 'Payment Not Appropriate',
                  isDark: isDark,
                  message:
                      'Min value required for ${list.title} payment is $minimum',
                  onConfirm: () {},
                );
              });
        } else if (maxmimum < gtAmount) {
          showDialog(
              context: context,
              builder: (context) {
                return AppAlertDialog(
                  title: 'Payment Not Appropriate',
                  isDark: isDark,
                  message:
                      'Max value required for ${list.title} payment is $maxmimum',
                  onConfirm: () {},
                );
              });
        } else if (tenderValue != 0 && tenderValue < gtAmount) {
          showDialog(
              context: context,
              builder: (context) {
                return AppAlertDialog(
                  title: 'Insufficent Amount',
                  isDark: isDark,
                  message: 'Paid amount is not enough to settle the Bill!',
                  onConfirm: () {},
                );
              });
        } else {
          if (funcID == 4) {
            payValue = gtAmount;
          } else {
            if (payValue == 0 && tenderValue == 0) {
              payValue = gtAmount;
            } else if (tenderValue > 0) {
              payValue = tenderValue;
            }
          }
          if (promptCustID) {
            GlobalConfig.CustomKeyboard = 3;
            // show custom keyboard
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Container(
                      height: 210.h,
                      child: Column(
                        children: [
                          Container(
                            height: 30.h,
                            decoration: BoxDecoration(
                              color: primaryDarkColor,
                            ),
                            child: Center(
                              child: Text(
                                customID,
                                style: titleTextDarkStyle,
                              ),
                            ),
                          ),
                          VirtualKeyboard(
                              height: 180.h,
                              textColor: Colors.white,
                              type: VirtualKeyboardType.Alphanumeric,
                              callback: (String text) {},
                              returnCallback: keyboardCallback,
                              textController: _alphaNumericController),
                        ],
                      ),
                    ),
                  );
                });
          } else {
            await _paymentRepository.paymentItem(
                POSDtls.deviceNo,
                GlobalConfig.operatorNo,
                GlobalConfig.tableNo,
                GlobalConfig.salesNo,
                GlobalConfig.splitNo,
                payType ?? 0,
                payValue,
                '');
            if (GlobalConfig.ErrMsg.isEmpty) {
              ref
                  .read(paymentProvider.notifier)
                  .fetchPaymentData(payTag, funcID);
              payTag = 1;

              if (payValue >= gtAmount) {
                Map<String, dynamic> paidDetails = await _paymentRepository
                    .getPopUpAmount(GlobalConfig.salesNo);
                double totalPaidAmount =
                    dynamicToDouble(paidDetails.values.first);
                double changesAmount =
                    dynamicToDouble(paidDetails.values.elementAt(1));
                double billTotalAmount =
                    dynamicToDouble(paidDetails.values.elementAt(2));
                showDialog(
                    context: context,
                    builder: (context) {
                      return AppAlertDialog(
                        message:
                            'Amount Due: $billTotalAmount,  Paid: $totalPaidAmount,  Change: $changesAmount',
                        title: 'Payment',
                        isDark: isDark,
                        onConfirm: () {
                          // payment notify
                          ref
                              .read(paymentProvider.notifier)
                              .updatePaymentStatus(PaymentStatus.PAID);
                        },
                      );
                    });

                gtAmount = 0;
              } else {
                setState(() {
                  gtAmount = gtAmount - payValue;
                });
              }
              payValue = 0;
              _controller.clear();
              await ref.read(orderProvoder.notifier).fetchOrderItems();
            } else {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AppAlertDialog(
                      title: 'Transaction Failed',
                      isDark: isDark,
                      message: GlobalConfig.ErrMsg,
                      onConfirm: () {},
                    );
                  });
            }
          }
        }
      }
    }
  }

  Future<void> keyboardCallback(String custID) async {
    await _paymentRepository.paymentItem(
        POSDtls.deviceNo,
        GlobalConfig.operatorNo,
        GlobalConfig.tableNo,
        GlobalConfig.salesNo,
        GlobalConfig.splitNo,
        payType ?? 0,
        payValue,
        custID);
    if (GlobalConfig.ErrMsg.isEmpty) {
      ref.read(paymentProvider.notifier).fetchPaymentData(payTag, funcID);

      if (payValue >= gtAmount) {
        ref
            .read(paymentProvider.notifier)
            .updatePaymentStatus(PaymentStatus.PAID);
      } else {
        setState(() {
          gtAmount = gtAmount - payValue;
        });
      }
    } else {
      GlobalConfig.ErrMsg = '';
      showDialog(
          context: context,
          builder: (context) {
            return AppAlertDialog(
              title: 'Error',
              isDark: isDark,
              message: 'Transaction Failed!',
              onConfirm: () {},
            );
          });
    }
    setState(() {
      payValue = 0;
    });
  }
}
