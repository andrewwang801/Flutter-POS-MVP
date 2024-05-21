import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../../common/keyboard/virtual_keyboard_2.dart';
import '../../common/utils/type_util.dart';
import '../../common/widgets/alert_dialog.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/checkout.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/header.dart';
import '../../common/widgets/numpad.dart';
import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../floor_plan/presentation/floor_plan_screen.dart';
import '../../home/provider/order/order_provider.dart';
import '../../print/provider/print_provider.dart';
import '../../theme/theme_state_notifier.dart';
import '../model/media_data_model.dart';
import '../model/payment_details_data_model.dart';
import '../provider/payment_provider.dart';
import '../provider/payment_state.dart';
import '../repository/i_payment_repository.dart';

List<MaterialColor> functionColors = <MaterialColor>[
  Colors.green,
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.pink,
  Colors.blue,
  Colors.grey,
  Colors.teal,
];

class FunctionModel {
  final String? label;
  final int color;

  FunctionModel(this.label, this.color);
}

final List<FunctionModel> cashMethods = [
  FunctionModel('CASH', 1),
  FunctionModel('CREDIT BCA', 1),
  FunctionModel('DEBIT LAIN', 1),
  FunctionModel('GO RESTO', 1),
  FunctionModel('GOPAY', 6),
  FunctionModel('GRAB', 6),
  FunctionModel('OVO', 6),
  FunctionModel('SHOPPE', 6),
  FunctionModel('SHOPPE FOOD', 6),
  FunctionModel('TRANSFER', 6),
  FunctionModel('VISA/MASTER', 7),
  FunctionModel('VOUCHER 100K', 7),
  FunctionModel('VOUCHER 50K', 7),
];

class TenderScreen extends ConsumerStatefulWidget {
  TenderScreen(
      {Key? key, required this.gTotal, required this.paymentRepository})
      : super(key: key);
  final double gTotal;
  final IPaymentRepository paymentRepository;

  @override
  _CashScreenState createState() => _CashScreenState();
}

class _CashScreenState extends ConsumerState<TenderScreen> with TypeUtil {
  bool isDark = true;
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

  @override
  void initState() {
    ref.read(paymentProvider.notifier).fetchPaymentData(0, 0);

    _paymentRepository = widget.paymentRepository;
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

    ref.listen<PaymentState>(paymentProvider, (prev, next) async {
      if (next is PaymentSuccessState) {
        switch (next.status) {
          case PaymentStatus.PAID:
            await ref
                .read(printProvider.notifier)
                .doPrint(3, GlobalConfig.salesNo, '');
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
                    title: 'Cash Payment',
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
            break;
        }
      }
    });

    if (state is PaymentSuccessState)
      gtAmount = widget.gTotal - (state.paidValue ?? 0);

    return Scaffold(
      backgroundColor: isDark ? backgroundDarkColor : backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(AppBar().preferredSize.height),
        child: AppBarWidget(false),
      ),
      body: Row(
        children: [
          _leftSide(),
          SizedBox(
            width: 26.w,
          ),
          Expanded(child: _rightSide(state)),
        ],
      ),
    );
  }

  Widget _leftSide() {
    return CheckOut(428.h - AppBar().preferredSize.height);
    // SizedBox(
    //   height: 10.h,
    // ),
    // BillButtonList(
    //   paymentRepository: GetIt.I<IPaymentRepository>(),
    //   orderRepository: GetIt.I<IOrderRepository>(),
    // ),
  }

  Widget _rightSide(PaymentState state) {
    if (state is! PaymentSuccessState) {
      return Center(child: const Text('loading...'));
    } else {
      tenderArray = state.tenderArray!;
      tenderDetail = state.tenderDetail!;
      return Column(
        children: [
          SizedBox(
            height: 25.h,
            child: Center(
              child: Text(
                'Tender Modes',
                style: isDark
                    ? titleTextDarkStyle.copyWith(fontWeight: FontWeight.bold)
                    : titleTextLightStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: primaryDarkColor, width: 1.0)),
            padding: const EdgeInsets.all(0.0),
            width: 550.w,
            height: 100.h,
            child: GridView.builder(
              itemCount: tenderArray.length,
              itemBuilder: (BuildContext context, int index) {
                MediaData mediaData = tenderArray[index];
                return Container(
                  color:
                      mediaData.title == 'Back' ? Colors.red : primaryDarkColor,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        mediaSelect(mediaData);
                      },
                      child: Center(
                        child: Text(mediaData.title,
                            textAlign: TextAlign.center,
                            style: bodyTextDarkStyle),
                      ),
                    ),
                  ),
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 1,
                  mainAxisExtent: 49.h,
                  crossAxisSpacing: 1),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    color: primaryDarkColor.withOpacity(0.8),
                    width: 300.w,
                    height: 25.h,
                    child: ListTile(
                      leading: Text(
                        'Media Type',
                        style: bodyTextDarkStyle,
                      ),
                      trailing: Text(
                        'Amount',
                        style: bodyTextDarkStyle,
                      ),
                    ),
                  ),
                  Container(
                      color: primaryDarkColor.withOpacity(0.6),
                      width: 300.w,
                      height: 130.h,
                      child: ListView.builder(
                          itemCount: tenderDetail.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _payentDetailListItem(index);
                          })),
                  Container(
                    height: 30.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Amount Due: ${gtAmount.toStringAsFixed(2)}',
                          style: titleTextDarkStyle.copyWith(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        // Text(
                        //   'Change: ${change.toStringAsFixed(2)}',
                        //   style: titleTextDarkStyle,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 10.w,
              ),
              Column(
                children: [
                  Container(
                    width: 250.w,
                    height: 25.h,
                    decoration: BoxDecoration(
                      color: primaryDarkColor.withOpacity(0.8),
                    ),
                    child: Center(
                      child: Text(
                        '$payValue',
                        style: titleTextDarkStyle,
                      ),
                    ),
                  ),
                  Container(
                    width: 250.w,
                    height: 130.h,
                    color: Colors.transparent,
                    child: NumPad(
                        buttonWidth: 250.w / 4,
                        buttonHeight: 130.h / 4,
                        delete: () {},
                        onSubmit: () {},
                        controller: _controller),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          _rightBottomBtnGroup(),
        ],
      );
    }
  }

  Widget _payentDetailListItem(int index) {
    return Container(
      color:
          index.isEven ? primaryDarkColor : primaryDarkColor.withOpacity(0.6),
      child: ListTile(
        leading: Text(
          '${tenderDetail[index].name}',
          style: bodyTextDarkStyle,
        ),
        trailing: Text(
          '${tenderDetail[index].amount}',
          style: bodyTextDarkStyle,
        ),
      ),
    );
  }

  Widget _rightBottomBtnGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CustomButton(
          callback: () {},
          text: 'FOC',
          fillColor: isDark ? primaryDarkColor : Colors.white,
          borderColor: isDark ? primaryDarkColor : Colors.green,
          width: 125.w,
          height: 40.h,
        ),
        CustomButton(
          callback: () {},
          text: 'REMOVE PAYMENT',
          fillColor: isDark ? primaryDarkColor : Colors.white,
          borderColor: isDark ? primaryDarkColor : Colors.green,
          width: 125.w,
          height: 40.h,
        ),
        CustomButton(
          callback: () {
            Get.back();
          },
          text: 'BACK TO MAIN',
          fillColor: isDark ? primaryDarkColor : Colors.white,
          borderColor: isDark ? primaryDarkColor : Colors.green,
          width: 125.w,
          height: 40.h,
        )
      ],
    );
  }

  Widget _header() {
    return const Header(
        transID: 'POS001',
        operator: 'EMENU',
        mode: 'REG',
        order: '4',
        cover: '1',
        rcp: 'A2200000082');
  }

// Do partial Payment when tap Media
  Future<void> mediaSelect(MediaData list) async {
    funcID = list.funcID;
    if (payTag == 1) {
      // var _tenderArray = await _paymentRepository.getMediaByType(
      //     funcID, GlobalConfig.operatorNo);
      ref.read(paymentProvider.notifier).fetchPaymentData(payTag, funcID);
      payTag = 2;
    } else {
      String title = list.title;
      if (title == 'Back') {
        // setState(() {
        //   tenderArray = _state.tenderArray!;
        // });
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
                              callback: keyboardCallback,
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
                // payment notify
                ref
                    .read(paymentProvider.notifier)
                    .updatePaymentStatus(PaymentStatus.PAID);

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
                        onConfirm: () {
                          Get.back();
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
