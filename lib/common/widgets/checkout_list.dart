import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/GlobalConfig.dart';

import 'package:raptorpos/common/extension/workable.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/presentation/widgets/menu_item_detail.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';

import 'package:raptorpos/theme/theme_state_notifier.dart';
import 'package:raptorpos/common/i18n/en.dart';

class CheckoutList extends ConsumerStatefulWidget {
  CheckoutList({this.callback, Key? key}) : super(key: key);

  final Function(OrderItemModel)? callback;

  @override
  _CheckoutListState createState() => _CheckoutListState();
}

class _CheckoutListState extends ConsumerState<CheckoutList> {
  bool isDark = false;
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);

    final OrderState state = ref.watch(orderProvoder);

    final bool isLoading = state.workable == Workable.loading ||
        state.workable == Workable.initial;
    final bool hasError =
        state.workable == Workable.failure && state.failure != null;

    if (isLoading) {
      return Container();
    } else if (hasError) {
      return Container();
    } else if (state.workable == Workable.ready) {
      GlobalConfig.checkItemOrder = state.orderItemTree?.length ?? 0;
      return Column(
        children: [
          ListTileTheme(
            contentPadding: EdgeInsets.zero,
            dense: true,
            child: ExpansionTile(
              title: Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10.w),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: Text(
                          kQty,
                          textAlign: TextAlign.left,
                          style: isDark
                              ? listItemTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : listItemTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: Text(
                          kDescription,
                          textAlign: TextAlign.left,
                          style: isDark
                              ? listItemTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : listItemTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Text(
                          kPrice,
                          textAlign: TextAlign.left,
                          style: isDark
                              ? listItemTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : listItemTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Text(
                          kSalesCategory,
                          textAlign: TextAlign.left,
                          style: isDark
                              ? listItemTextDarkStyle.copyWith(
                                  fontWeight: FontWeight.bold)
                              : listItemTextLightStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: SizedBox(width: 10.w),
            ),
          ),
          Expanded(
            child: ListView.separated(
                padding: EdgeInsets.zero,
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: state.orderItemTree!.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      if (widget.callback != null) {
                        widget.callback!(state.orderItemTree![index].orderItem);
                      }
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        selectedIndex = index;
                      });
                      showGeneralDialog(
                        context: context,
                        barrierColor: Colors.black38,
                        barrierLabel: 'Label',
                        barrierDismissible: true,
                        pageBuilder: (_, __, ___) => MenuItemDetail(
                          state.orderItemTree![index].orderItem.PLUNo ?? '',
                          state.orderItemTree![index].orderItem.SalesRef ?? 0,
                          true,
                          orderItem: state.orderItemTree![index].orderItem,
                        ),
                      );
                    },
                    child: state.orderItemTree![index].render(
                      context,
                      4,
                      isDark,
                      () {
                        setState(() {
                          ref.read(orderProvoder.notifier).voidOrderItem(
                              state.orderItemTree![index].orderItem);
                          // state.orderItemTree!.removeAt(index);
                        });
                      },
                      selected: selectedIndex == index,
                    ),
                  );
                }),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
