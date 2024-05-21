import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/payment/presentation/cash_screen.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/floor_plan/presentation/floor_plan_screen.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import 'package:raptorpos/trans/presentation/trans.dart';
import 'package:raptorpos/sales_category/sales_category_screen.dart';
import 'package:raptorpos/payment/presentation/tender_screen.dart';
import 'package:raptorpos/payment/repository/i_payment_repository.dart';
import 'package:raptorpos/common/GlobalConfig.dart';
import 'package:raptorpos/payment/repository/payment_local_repository.dart';
import 'package:raptorpos/home/repository/order/i_order_repository.dart';
import 'package:raptorpos/print/provider/print_provider.dart';
import 'package:raptorpos/payment/provider/payment_provider.dart';
import './custom_button.dart';
import 'alert_dialog.dart';

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
    'DISC',
    'Print Bill',
    'DINE-IN',
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
    _scrollController.animateTo(_scrollController.offset + 87.w,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  void scrollToPrev() {
    _scrollController.animateTo(_scrollController.offset - 87.w,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    final OrderState state = ref.watch(orderProvoder);
    final bool isDark = ref.read(themeProvider);
    return SizedBox(
      width: 300.w,
      height: 40.h,
      child: Row(
        children: [
          GestureDetector(
            child: const Icon(Icons.arrow_back_ios_rounded),
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
                      case 2:
                        break;
                      case 3:
                        Get.to(FloorPlanScreen());
                        break;
                      case 4:
                        Get.to(ViewTransScreen());
                        break;
                      case 5:
                        Get.to(SalesCategoryScreen());
                        break;
                      default:
                        Get.to(ViewTransScreen());
                        break;
                    }
                  },
                  text: billBtnTexts[index],
                  fillColor: isDark ? primaryDarkColor : Colors.white,
                  borderColor: isDark ? primaryDarkColor : Colors.green,
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisExtent: 84.w,
                mainAxisSpacing: 3.w,
              ),
            ),
          ),
          GestureDetector(
            child: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              scrollToNext();
            },
          ),
        ],
      ),
    );
  }

  Future<void> doCashPayment(OrderState state) async {
    if (state is OrderSuccessState) {
      if (state.paymentPermission ?? false) {
        final bool bTender = await _paymentRepository.checkTenderPayment(
            GlobalConfig.salesNo, GlobalConfig.splitNo, GlobalConfig.tableNo);

        final double sTotal = state.bills[2];
        final double gTotal = state.bills[0];
        // update order items in HeldItems table
        await _orderRepository.updateHoldItem(GlobalConfig.salesNo,
            GlobalConfig.splitNo, GlobalConfig.tableNo, sTotal, gTotal, 0);
        // fetch updated order items
        ref.read(orderProvoder.notifier).fetchOrderItems();

        // Print
        await ref.read(printProvider.notifier).kpPrint();
        // End of Print

        if (bTender) {
        } else {}
        Get.to(CashScreen());
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AppAlertDialog(
              content: Text('Not allowed to pay'),
            );
          });
    }
  }

  Future<void> doTenderPayment(OrderState state) async {
    if (state is OrderSuccessState) {
      if (state.paymentPermission ?? false) {
        final double sTotal = state.bills[2];
        final double gTotal = state.bills[0];
        // update order items in HeldItems table
        await _orderRepository.updateHoldItem(GlobalConfig.salesNo,
            GlobalConfig.splitNo, GlobalConfig.tableNo, sTotal, gTotal, 0);
        // fetch updated order items
        ref.read(orderProvoder.notifier).fetchOrderItems();

        // Print
        await ref.read(printProvider.notifier).kpPrint();
        // End of Print
        ref.read(paymentProvider.notifier).fetchPaymentData(0, 0);
        Get.to(TenderScreen(
          gTotal: gTotal,
          paymentRepository: GetIt.I<IPaymentRepository>(),
        ));
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AppAlertDialog(
                content: Text('Not allowed to pay'),
              );
            });
      }
    } else {}
  }
}
