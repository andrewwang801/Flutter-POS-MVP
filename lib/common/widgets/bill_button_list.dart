// ignore_for_file: prefer_relative_imports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/GlobalConfig.dart';
import 'package:raptorpos/common/extension/workable.dart';
import 'package:raptorpos/common/widgets/custom_button.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/discount/presentation/discount_screen.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/home/repository/order/i_order_repository.dart';
import 'package:raptorpos/payment/presentation/cash_screen.dart';
import 'package:raptorpos/payment/presentation/tender_screen.dart';
import 'package:raptorpos/payment/repository/i_payment_repository.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';
import 'package:raptorpos/trans/presentation/trans.dart';

import 'alert_dialog.dart';
import 'responsive.dart';

class BillButtonList extends ConsumerStatefulWidget {
  final IPaymentRepository paymentRepository;
  final IOrderRepository orderRepository;
  BillButtonList(
      {Key? key,
      required this.paymentRepository,
      required this.orderRepository})
      : super(key: key);

  @override
  _BillButtonListState createState() => _BillButtonListState();
}

class _BillButtonListState extends ConsumerState<BillButtonList> {
  final List<String> billBtnTexts = [
    'CASH',
    'PAYMENT',
    'DINE-IN',
    'DISC',
    'PROMO',
  ];

  late IPaymentRepository _paymentRepository;
  late IOrderRepository _orderRepository;
  @override
  void initState() {
    _paymentRepository = widget.paymentRepository;
    _orderRepository = widget.orderRepository;
    super.initState();
  }

  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0,
    keepScrollOffset: true,
  );

  void scrollToNext() {
    _scrollController.animateTo(
        _scrollController.offset + (300.w - 24.0 * 2 - 6.w) / 3 + 3.w,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease);
  }

  void scrollToPrev() {
    _scrollController.animateTo(
        _scrollController.offset - (300.w - 24.0 * 2 - 6.w) / 3 - 3.w,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    final OrderState state = ref.watch(orderProvoder);
    final bool isDark = ref.read(themeProvider);
    return SizedBox(
      width: 300.w,
      height: Responsive.isMobile(context) ? 50.h : 40.h,
      child: Row(
        children: [
          GestureDetector(
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: iconSize,
            ),
            onTap: () {
              scrollToPrev();
            },
          ),
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              itemCount: billBtnTexts.length,
              itemBuilder: (BuildContext context, int index) {
                return CustomButton(
                  callback: () async {
                    switch (index) {
                      case 0:
                        await doCashPayment(state);
                        break;
                      case 1:
                        await doTenderPayment(state);
                        break;
                      // Sales Category
                      case 2:
                        setState(() {
                          if (POSDtls.categoryID == 1) {
                            POSDtls.categoryID = 3;
                          } else if (POSDtls.categoryID == 3) {
                            POSDtls.categoryID = 1;
                          }
                        });
                        break;
                      case 3:
                        Get.to(() => DiscountScreen());
                        break;
                      case 4:
                        break;
                      default:
                        Get.to(ViewTransScreen());
                        break;
                    }
                  },
                  text: index == 2 ? categoryType() : billBtnTexts[index],
                  fillColor: isDark ? primaryDarkColor : Colors.white,
                  borderColor: isDark ? primaryDarkColor : Colors.green,
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisExtent: (300.w - 24.0 * 2 - 6.w) / 3,
                mainAxisSpacing: 3.w,
              ),
            ),
          ),
          GestureDetector(
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: iconSize,
            ),
            onTap: () {
              scrollToNext();
            },
          ),
        ],
      ),
    );
  }

  Future<void> doCashPayment(OrderState state) async {
    if (state.workable == Workable.ready) {
      if (state.bills?.isEmpty ?? false) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                title: 'Error',
                message: 'Order is empty!',
                onConfirm: () {},
              );
            });
        return;
      }
      if (state.paymentPermission ?? false) {
        final bool bTender = await _paymentRepository.checkTenderPayment(
            GlobalConfig.salesNo, GlobalConfig.splitNo, GlobalConfig.tableNo);

        final double sTotal = state.bills![2];
        final double gTotal = state.bills![0];
        // update order items in HeldItems table
        await ref.read(orderProvoder.notifier).updateHeldItem(sTotal, gTotal);
        // fetch updated order items
        ref.read(orderProvoder.notifier).fetchOrderItems();

        // TODO: complete below block
        if (bTender) {
        } else {}
        Get.to(CashScreen());
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AppAlertDialog(
              title: 'Error',
              message: 'Not allowed to pay!',
              onConfirm: () {},
            );
          });
    }
  }

  Future<void> doTenderPayment(OrderState state) async {
    if (state.workable == Workable.ready) {
      if (state.bills?.isEmpty ?? false) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                title: 'Error',
                message: 'Order is empty!',
                onConfirm: () {},
              );
            });
        return;
      }
      if (state.paymentPermission ?? false) {
        final double sTotal = state.bills![2];
        final double gTotal = state.bills![0];
        // update order items in HeldItems table
        await ref.read(orderProvoder.notifier).updateHeldItem(sTotal, gTotal);
        // fetch updated order items
        ref.read(orderProvoder.notifier).fetchOrderItems();
        // Print
        Get.to(TenderScreen(
          gTotal: gTotal,
        ));
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                title: 'Error',
                message: 'Not allowed to pay!',
                onConfirm: () {},
              );
            });
      }
    } else {}
  }

  String categoryType() {
    if (POSDtls.categoryID == 1) {
      return 'Take Away';
    } else if (POSDtls.categoryID == 3) {
      return 'DINE IN';
    } else {
      return 'Delivery';
    }
  }
}
