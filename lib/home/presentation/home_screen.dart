import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/repository/order/i_order_repository.dart';
import 'package:raptorpos/payment/repository/i_payment_repository.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../common/widgets/responsive.dart';
import './widgets/main_button_list.dart';
import './widgets/menu_item_list.dart';
import './widgets/menu_list.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/bill_button_list.dart';
import '../../common/widgets/checkout.dart';
import '../../common/widgets/numpad.dart';
import '../../constants/color_constant.dart';

class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _myController = TextEditingController();
  bool _showNumPad = false;

  @override
  void initState() {
    ref.read(orderProvoder.notifier).fetchOrderItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark ? backgroundDarkColor : backgroundColor,
      appBar: PreferredSize(
        child: AppBarWidget(false),
        preferredSize: Size.fromHeight(appBarHeight),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 5.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: CheckOut(428.h -
                          5.h -
                          10.h -
                          (Responsive.isMobile(context) ? 50.h : 40.h) -
                          appBarHeight -
                          ScreenUtil().bottomBarHeight -
                          ScreenUtil().statusBarHeight),
                    ),
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
                  width: 10.w,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            // const Header(
                            //     transID: 'POS001',
                            //     operator: 'EMENU',
                            //     mode: 'REG',
                            //     order: '4',
                            //     cover: '1',
                            //     rcp: 'A2200000082'),
                            SizedBox(
                              height: 5.h,
                            ),
                            SizedBox(
                              height:
                                  Responsive.isMobile(context) ? 50.h : 40.h,
                              child: MenuList(),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Container(
                              height: Responsive.isMobile(context)
                                  ? 428.h -
                                      5.h -
                                      10.h -
                                      10.h -
                                      (Responsive.isMobile(context)
                                          ? 50.h
                                          : 40.h) -
                                      50.h -
                                      appBarHeight -
                                      ScreenUtil().bottomBarHeight -
                                      ScreenUtil().statusBarHeight
                                  : 428.h -
                                      5.h -
                                      10.h -
                                      10.h -
                                      40.h -
                                      40.h -
                                      appBarHeight -
                                      ScreenUtil().bottomBarHeight -
                                      ScreenUtil().statusBarHeight,
                              width: 600.w,
                              child: MenuItemList(),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            MainButtonList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
