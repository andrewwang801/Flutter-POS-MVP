import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:raptorpos/common/GlobalConfig.dart';
import 'package:raptorpos/common/extension/workable.dart';
import 'package:raptorpos/common/widgets/alert_dialog.dart';
import 'package:raptorpos/common/widgets/drawer.dart';
import 'package:raptorpos/common/widgets/mobile/mobile_checkout.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/floor_plan/presentation/floor_plan_screen.dart';
import 'package:raptorpos/functions/application/function_provider.dart';
import 'package:raptorpos/functions/application/function_state.dart';
import 'package:raptorpos/home/model/menu_model.dart';
import 'package:raptorpos/home/provider/menu/menu_provider.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/print/provider/print_provider.dart';
import 'package:raptorpos/print/provider/print_state.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import './widgets/menu_item_list.dart';
import './widgets/menu_list.dart';
import '../../common/widgets/checkout.dart';
import '../../common/widgets/responsive.dart';
import '../../constants/color_constant.dart';

class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _myController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showNumPad = false;
  bool isDark = false;
  bool _isMenuExpand = false;

  MenuModel? _selectedMenu;
  int cntItem = 0;
  double billTotal = 0.0;

  late AnimationController _menuController;
  late Animation<double> _animation;

  @override
  void initState() {
    ref.read(orderProvoder.notifier).fetchOrderItems();

    _menuController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1),
    );
    _animation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeIn,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);

    final OrderState orderState = ref.watch(orderProvoder);
    if (orderState.workable == Workable.ready) {
      cntItem = orderState.orderItemTree?.length ?? 0;
      if (orderState.bills?.isNotEmpty ?? false) {
        billTotal = orderState.bills?[0] ?? 0.0;
      }
    }

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

    return Responsive(mobile: _mobile(), tablet: _tablet(), desktop: _tablet());
  }

  Widget _tablet() {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
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
              onPressed: () {
                Get.to(FloorPlanScreen());
              },
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
      body: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: Responsive.isMobile(context) ? 400.w : 320.w,
              child: Column(
                children: [
                  Expanded(child: CheckOut()),
                  Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).padding.bottom,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(Spacing.sm),
                        color: Colors.white,
                        child: MenuList(),
                      ),
                      Expanded(
                        child: Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: Spacing.sm),
                            child: MenuItemList()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: SideBarDrawer(),
    );
  }

  Widget _mobile() {
    final menuHdr = ref.watch(menuHdrProvider);
    List<MenuModel> menus = [];

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark ? backgroundDarkColor : backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Container(
          color: isDark ? primaryDarkColor : backgroundColor,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(Spacing.sm),
                child: Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // IconButton(
                        //     icon: Icon(
                        //         isDark ? Icons.nightlight_round : Icons.wb_sunny),
                        //     onPressed: () {
                        //       isDark ? isDark = false : isDark = true;
                        //       ref.read(themeProvider.notifier).setTheme(isDark);
                        //     }),
                        GestureDetector(
                          onTap: (() {
                            Get.to(FloorPlanScreen());
                          }),
                          child: Container(
                            width: 25.h,
                            height: 25.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2,
                                  color: isDark
                                      ? backgroundColor
                                      : primaryDarkColor),
                              borderRadius: BorderRadius.circular(Spacing.xs),
                            ),
                            child: Icon(
                              Icons.close,
                              color:
                                  isDark ? backgroundColor : primaryDarkColor,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    horizontalSpaceSmall,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${GlobalConfig.TransMode}',
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                          textAlign: TextAlign.left,
                        ),
                        verticalSpaceTiny,
                        Text(
                          'Table ${GlobalConfig.tableNo}',
                          style: isDark
                              ? normalTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : normalTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        '${GlobalConfig.rcptNo}',
                        style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                        textAlign: TextAlign.right,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(Spacing.sm),
                color: Colors.white,
                child: _searchBar(),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
                  child: MenuItemList(),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(Spacing.sm),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(Spacing.sm),
                      height: 50.h,
                      color: red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.menu_book_sharp,
                                color: backgroundColor,
                              ),
                              horizontalSpaceTiny,
                              Text(
                                _selectedMenu?.MenuName ?? 'All Menu',
                                style: isDark
                                    ? bodyTextDarkStyle
                                    : bodyTextLightStyle.copyWith(
                                        color: Colors.white),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMenuExpand = !_isMenuExpand;
                                _menuController.duration =
                                    Duration(milliseconds: 300);
                                _isMenuExpand
                                    ? _menuController.forward(from: 0)
                                    : _menuController.reverse(from: 0.3);
                              });
                            },
                            child: Icon(
                              _isMenuExpand
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              color: backgroundColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizeTransition(
                      sizeFactor: _animation,
                      child: menuHdr.when(
                        data: (data) {
                          menus.addAll(data);
                          menus.insert(0, MenuModel(0, 'All Menu', 'All Menu'));
                          return Container(
                            height: 300,
                            color:
                                isDark ? backgroundDarkColor : backgroundColor,
                            child: ListView.separated(
                                physics: ClampingScrollPhysics(),
                                itemCount: menus.length,
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Divider();
                                },
                                itemBuilder: ((context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedMenu = menus[index];
                                      });
                                      ref.read(menuIDProvider.notifier).state =
                                          menus[index].MenuID;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(Spacing.sm),
                                      child: Text(menus[index].MenuName ?? ''),
                                    ),
                                  );
                                })),
                          );
                        },
                        error: (error, e) {
                          return Container();
                        },
                        loading: () {
                          return Container();
                        },
                      ),
                    ),
                    Container(
                      height: 100.h,
                      padding: EdgeInsets.all(Spacing.sm),
                      color: backgroundColorVariant,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${cntItem} Items',
                                style: isDark
                                    ? titleTextDarkStyle
                                    : titleTextLightStyle,
                              ),
                              Text('${billTotal} \$'),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.to(MobileCheckout());
                            },
                            style: ElevatedButton.styleFrom(
                                primary: orange,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(Spacing.sm))),
                            child: Text('Detail'),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: SideBarDrawer(),
    );
  }

  final TextEditingController _searchController = TextEditingController();
  String searchKeyword = '';
  Widget _searchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Spacing.sm),
        border: Border.all(width: 1, color: backgroundColorVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Empty',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (String value) {
                ref.read(menuIDSearchProvider.notifier).state = value;
                searchKeyword = value;
              },
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () {
              ref.read(menuIDSearchProvider.notifier).state = searchKeyword;
            },
            icon: Icon(
              Icons.search,
            ),
          ),
        ],
      ),
    );
  }
}
