import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/common/GlobalConfig.dart';
import 'package:raptorpos/common/extension/color_extension.dart';
import 'package:raptorpos/common/extension/workable.dart';
import 'package:raptorpos/common/widgets/alert_dialog.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
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
    // int? salesRef;

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
                Get.back();
              },
              child: const Icon(
                Icons.arrow_back,
                size: smiconSize,
              )),
        ),
        title: Text(
          'Table: ${GlobalConfig.tableNo}   Cover: ${GlobalConfig.cover}   Mode: ${GlobalConfig.TransMode}   Rcp: ${GlobalConfig.rcptNo}',
          style: isDark ? listItemTextDarkStyle : listItemTextLightStyle,
          textAlign: TextAlign.left,
        ),
      ),
      body: SafeArea(
        child: Responsive.isMobile(context)
            ? (ScreenUtil().orientation == Orientation.landscape
                ? landscape(state)
                : portrait(state))
            : (ScreenUtil().orientation == Orientation.landscape
                ? landscape(state)
                : portrait(state)),
      ),
    );
  }

  Widget landscape(PromoState state) {
    int? salesRef;
    return Row(
      children: [
        Column(
          children: [
            Expanded(
              child: SizedBox(
                width: Responsive.isMobile(context) ? 400.w : 0.37.sw,
                child: CheckOut(
                    showCheckoutBtns: false,
                    Callback: (OrderItemModel orderItem) {
                      salesRef = orderItem.SalesRef;
                    }),
              ),
            ),
            // BillButtonList(
            //   paymentRepository: GetIt.I<IPaymentRepository>(),
            //   orderRepository: GetIt.I<IOrderRepository>(),
            // ),
          ],
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
                  child: Container(
                    width: 600.w,
                    padding: EdgeInsets.all(Spacing.sm),
                    child: GridView.builder(
                      physics: ClampingScrollPhysics(),
                      itemCount: state.data!.promos.length,
                      itemBuilder: (BuildContext context, int index) {
                        PromotionModel promo = state.data!.promos[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(3.0),
                          onTap: () {
                            // Apply Promotion
                            ref.read(promoProvider.notifier).applyPromo(
                                promo.id, promo.name, GlobalConfig.operatorNo);
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                                color: HexColor(promo.color ?? 'ffffff')
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
    );
  }

  Widget portrait(PromoState state) {
    int? salesRef;
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: CheckOut(
              showCheckoutBtns: false,
              Callback: (OrderItemModel orderItem) {
                salesRef = orderItem.SalesRef;
              }),
        ),
        if (state.workable == Workable.ready)
          Expanded(
            flex: 1,
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
                  child: Container(
                    width: 600.w,
                    padding: EdgeInsets.all(Spacing.sm),
                    child: GridView.builder(
                      physics: ClampingScrollPhysics(),
                      itemCount: state.data!.promos.length,
                      itemBuilder: (BuildContext context, int index) {
                        PromotionModel promo = state.data!.promos[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(3.0),
                          onTap: () {
                            // Apply Promotion
                            ref.read(promoProvider.notifier).applyPromo(
                                promo.id, promo.name, GlobalConfig.operatorNo);
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                                color: (isDark
                                        ? primaryDarkColor
                                        : backgroundColorVariant)
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
    );
  }
}
