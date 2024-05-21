import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/GlobalConfig.dart';
import 'package:raptorpos/common/extension/color_extension.dart';
import 'package:raptorpos/common/extension/workable.dart';
import 'package:raptorpos/common/widgets/alert_dialog.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/discount/application/discount_provider.dart';
import 'package:raptorpos/discount/application/discount_state.dart';
import 'package:raptorpos/discount/model/discount_model.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/checkout.dart';

import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';

class DiscountScreen extends ConsumerStatefulWidget {
  DiscountScreen({Key? key}) : super(key: key);

  @override
  _DiscountScreenState createState() => _DiscountScreenState();
}

class _DiscountScreenState extends ConsumerState<DiscountScreen> {
  bool isDark = false;
  int? salesRef;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      ref.read(discProvider.notifier).fetchDiscs();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);
    DiscountState state = ref.watch(discProvider);
    int? salesRef;

    ref.listen(discProvider, (previous, DiscountState next) {
      if (next.failiure != null) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                onConfirm: () {},
                isDark: isDark,
                title: 'Error',
                message: next.failiure!.errMsg,
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

  Widget portrait(DiscountState state) {
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
                      'Discounts',
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
                      itemCount: state.data!.discs.length,
                      itemBuilder: (BuildContext context, int index) {
                        DiscountModel disc = state.data!.discs[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(3.0),
                          onTap: () {
                            ref.read(discProvider.notifier).disc(
                                POSDtls.deviceNo,
                                GlobalConfig.operatorNo,
                                GlobalConfig.tableNo,
                                GlobalConfig.salesNo,
                                GlobalConfig.splitNo,
                                salesRef ?? 0,
                                disc.subFnID,
                                disc.discTitle,
                                0);
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                                color: HexColor(disc.color ?? 'ffffff')
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
                              child: Text(disc.discTitle,
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

  Widget landscape(DiscountState state) {
    return Row(
      children: [
        Column(
          children: [
            Expanded(
              child: SizedBox(
                width: Responsive.isMobile(context) ? 400.w : 0.37.sw,
                child: CheckOut(Callback: (OrderItemModel orderItem) {
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
                      'Discounts',
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
                      itemCount: state.data!.discs.length,
                      itemBuilder: (BuildContext context, int index) {
                        DiscountModel disc = state.data!.discs[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(3.0),
                          onTap: () {
                            ref.read(discProvider.notifier).disc(
                                POSDtls.deviceNo,
                                GlobalConfig.operatorNo,
                                GlobalConfig.tableNo,
                                GlobalConfig.salesNo,
                                GlobalConfig.splitNo,
                                salesRef ?? 0,
                                disc.subFnID,
                                disc.discTitle,
                                0);
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                                color: HexColor(disc.color ?? 'ffffff')
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
                              child: Text(disc.discTitle,
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
