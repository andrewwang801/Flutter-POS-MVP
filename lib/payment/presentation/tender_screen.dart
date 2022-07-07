import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import 'package:raptorpos/common/widgets/appbar.dart';
import 'package:raptorpos/common/widgets/bill_button_list.dart';
import 'package:raptorpos/common/widgets/checkout.dart';
import 'package:raptorpos/common/widgets/header.dart';
import 'package:raptorpos/common/widgets/numpad.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/home/repository/order/i_order_repository.dart';
import 'package:raptorpos/payment/provider/payment_state.dart';
import 'package:raptorpos/payment/repository/i_payment_repository.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../../common/widgets/alert_dialog.dart';
import '../../common/widgets/custom_button.dart';
import '../../home/provider/order/order_provider.dart';
import '../model/media_data_model.dart';
import '../model/payment_details_data_model.dart';
import '../provider/payment_provider.dart';

List<MaterialColor> functionColors = [
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

class _CashScreenState extends ConsumerState<TenderScreen> {
  bool isDark = true;
  double gtAmount = 0, payValue = 0;
  double change = 0;

  int? payType;
  int salesRef = 0;
  int payTag = 1;

  List<MediaData> tenderArray = <MediaData>[];
  List<PaymentDetailsData> tenderDetail = <PaymentDetailsData>[];

  TextEditingController _controller = TextEditingController();

  late IPaymentRepository _paymentRepository;

  @override
  void initState() {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);

    PaymentState state = ref.watch(paymentProvider);
    if (state is PaymentSuccessState)
      gtAmount = widget.gTotal - state.paidValue!;

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
    return Column(
      children: [
        CheckOut(320.h),
        SizedBox(
          height: 10.h,
        ),
        BillButtonList(
          paymentRepository: GetIt.I<IPaymentRepository>(),
          orderRepository: GetIt.I<IOrderRepository>(),
        ),
      ],
    );
  }

  Widget _rightSide(PaymentState state) {
    if (state is! PaymentSuccessState) {
      return Center(child: const Text('loading...'));
    } else {
      tenderArray = state.tenderArray!;
      tenderDetail = state.tenderDetail!;
      return Column(
        children: [
          Container(
            height: 30.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Amount Due: ${gtAmount.toStringAsFixed(2)}',
                  style: titleTextDarkStyle,
                ),
                // Text(
                //   'Change: ${change.toStringAsFixed(2)}',
                //   style: titleTextDarkStyle,
                // ),
              ],
            ),
          ),
          Row(
            children: [
              Column(
                children: [
                  Container(
                    color: Colors.green[900],
                    width: 300.w,
                    height: 25.h,
                    child: ListTile(
                      leading: Text('Media Type'),
                      trailing: Text('Amount'),
                    ),
                  ),
                  Container(
                      color: Colors.green,
                      width: 270.w,
                      height: 130.h,
                      child: ListView.builder(
                          itemCount: tenderDetail.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _payentDetailListItem(index);
                          })),
                ],
              ),
              SizedBox(
                width: 10.w,
              ),
              Column(
                children: [
                  Container(
                    width: 250.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: Colors.white38,
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
                    height: 125.h,
                    color: Colors.white,
                    child: NumPad(
                        buttonWidth: 250.w / 4,
                        buttonHeight: 125.h / 4,
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
          SizedBox(
            height: 25.h,
            child: Center(
              child: Text(
                'Tender Modes',
                style: titleTextDarkStyle.copyWith(fontWeight: FontWeight.bold),
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
          _rightBottomBtnGroup(),
        ],
      );
    }
  }

  Widget _payentDetailListItem(int index) {
    return Container(
      color: index.isEven ? Colors.green : Colors.green[800],
      child: ListTile(
        leading: Text('${tenderDetail[index].name}'),
        trailing: Text('${tenderDetail[index].amount}'),
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

  Future<void> mediaSelect(MediaData list) async {
    int funcID = list.funcID;
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
                  return AppAlertDialog(
                    title: 'Warning',
                    message: 'Input custom ID',
                    onConfirm: () {},
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
              // tenderDetail = await _paymentRepository.getPaymentDetails(
              //     GlobalConfig.salesNo,
              //     GlobalConfig.splitNo,
              //     GlobalConfig.tableNo);
              // setState(() {});

              ref
                  .read(paymentProvider.notifier)
                  .fetchPaymentData(payTag, funcID);
              payTag = 1;

              if (payValue >= gtAmount) {
                // payment notify
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
}
