import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/extension/color_extension.dart';
import 'package:raptorpos/common/widgets/custom_button.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/home/model/menu_item_model.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

class MenuItemDetail extends ConsumerStatefulWidget {
  final MenuItemModel menuItem;
  MenuItemDetail(this.menuItem, {Key? key}) : super(key: key);

  @override
  _MenuItemDetailState createState() => _MenuItemDetailState();
}

class _MenuItemDetailState extends ConsumerState<MenuItemDetail> {
  int qty = 1;
  double price = 0.0;
  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    return Center(
      child: Container(
        width: 280.w,
        height: 230.h,
        child: _shoppingItem(1),
      ),
    );
  }

  Widget _shoppingItem(int itemIndex) {
    bool isDark = ref.watch(themeProvider);
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: HexColor(widget.menuItem.color ?? 'ffffff')
                      .withOpacity(1),
                  border: Border.all(
                    color: isDark ? backgroundDarkColor : Colors.green.shade100,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                  child: Text(widget.menuItem.itemName ?? '',
                      textAlign: TextAlign.center,
                      style: isDark
                          ? bodyTextDarkStyle
                          : bodyTextLightStyle.copyWith(color: Colors.black)),
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            FractionallySizedBox(
              widthFactor: 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _decrementButton(itemIndex),
                  Text(
                    qty.toString(),
                    style: TextStyle(fontSize: 18.0),
                  ),
                  _incrementButton(itemIndex),
                ],
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            CustomButton(
              callback: () {
                ref.read(orderProvoder.notifier).addOrderItem('1', 1, '3', 1, 1,
                    widget.menuItem.pluNumber ?? '', 2, qty.toDouble(), 1);
                Get.back();
              },
              text: 'ORDER \$20',
              borderColor: primaryDarkColor,
              fillColor: primaryDarkColor,
              width: 200.w,
            )
          ],
        ),
      ),
    );
  }

  Widget _decrementButton(int index) {
    return SizedBox(
      width: 36.w,
      height: 36.w,
      child: FloatingActionButton(
          onPressed: () {
            setState(() {
              qty--;
            });
          },
          child: new Icon(Icons.remove, color: Colors.black),
          backgroundColor: Colors.white),
    );
  }

  Widget _incrementButton(int index) {
    return SizedBox(
      width: 36.w,
      height: 36.w,
      child: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.black87),
        backgroundColor: Colors.white,
        onPressed: () {
          setState(() {
            qty++;
            // price = qty * widget.menuItem.
          });
        },
      ),
    );
  }
}
