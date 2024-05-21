import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/common/GlobalConfig.dart';
import 'package:raptorpos/common/extension/workable.dart';
import 'package:raptorpos/common/widgets/alert_dialog.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/repository/order/i_order_repository.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/bill_button_list.dart';
import '../../common/widgets/checkout.dart';

import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../payment/repository/i_payment_repository.dart';
import '../application/promo_provider.dart';
import '../application/promo_state.dart';
import '../model/promotion_model.dart';

class PromotionScreen extends ConsumerStatefulWidget {
  PromotionScreen({Key? key}) : super(key: key);

  @override
  _PromotionScreenState createState() => _PromotionScreenState();
}

class _PromotionScreenState extends ConsumerState<PromotionScreen> {
  bool isDark = true;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      ref.read(promoProvider.notifier).fetchPromotions();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);
    PromoState state = ref.watch(promoProvider);
    int? salesRef;

    ref.listen(promoProvider, (previous, PromoState next) {
      if (next.failiure != null) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                onConfirm: () {},
                title: 'Error',
                message: next.failiure!.errMsg,
                isDark: isDark,
              );
            });
      }
    });

    return Scaffold(
      backgroundColor: isDark ? backgroundDarkColor : backgroundColor,
      appBar: PreferredSize(
        child: AppBarWidget(true),
        preferredSize: Size.fromHeight(AppBar().preferredSize.height),
      ),
      body: Row(
        children: [
          Column(
            children: [
              SizedBox(
                height: 5.h,
              ),
              CheckOut(Callback: (OrderItemModel orderItem) {
                salesRef = orderItem.SalesRef;
              }),
              SizedBox(
                height: 10.h,
              ),
              BillButtonList(
                paymentRepository: GetIt.I<IPaymentRepository>(),
                orderRepository: GetIt.I<IOrderRepository>(),
              ),
            ],
          ),
          SizedBox(
            width: 26.w,
          ),
          if (state.workable == Workable.ready)
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 40.h,
                    child: Center(
                      child: Text(
                        'Promotions',
                        style: isDark
                            ? titleTextDarkStyle.copyWith(
                                fontWeight: FontWeight.bold)
                            : titleTextLightStyle.copyWith(
                                fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 600.w,
                      child: GridView.builder(
                        itemCount: state.data!.promos.length,
                        itemBuilder: (BuildContext context, int index) {
                          PromotionModel promo = state.data!.promos[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(3.0),
                            onTap: () {
                              // Apply Promotion
                              ref.read(promoProvider.notifier).applyPromo(
                                  promo.id,
                                  promo.name,
                                  GlobalConfig.operatorNo);
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                  color: (isDark
                                          ? primaryDarkColor
                                          : primaryLightColor)
                                      .withOpacity(0.9),
                                  border: Border.all(
                                    color: isDark
                                        ? primaryDarkColor.withOpacity(0.7)
                                        : primaryLightColor,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(3.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? backgroundDarkColor
                                          : Colors.white,
                                      spreadRadius: 1.0,
                                      blurRadius: 1.0,
                                    )
                                  ]),
                              child: Center(
                                child: Text(promo.name,
                                    textAlign: TextAlign.center,
                                    style: isDark
                                        ? bodyTextDarkStyle
                                        : bodyTextLightStyle),
                              ),
                            ),
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 1,
                            mainAxisExtent: 60.h,
                            crossAxisSpacing: 1),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                ],
              ),
            )
          else if (state.workable == Workable.loading)
            Container()
          else if (state.workable == Workable.failure)
            Container()
        ],
      ),
    );
  }
}
