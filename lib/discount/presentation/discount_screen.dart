import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/GlobalConfig.dart';
import 'package:raptorpos/common/extension/color_extension.dart';
import 'package:raptorpos/common/extension/workable.dart';
import 'package:raptorpos/common/widgets/alert_dialog.dart';
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
              // BillButtonList(
              //   paymentRepository: GetIt.I<IPaymentRepository>(),
              //   orderRepository: GetIt.I<IOrderRepository>(),
              // ),
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
                    child: SizedBox(
                      width: 600.w,
                      child: GridView.builder(
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
      ),
    );
  }
}
