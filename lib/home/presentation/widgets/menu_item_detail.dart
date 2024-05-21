import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/extension/color_extension.dart';
import 'package:raptorpos/common/extension/string_extension.dart';
import 'package:raptorpos/common/widgets/custom_button.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/home/presentation/widgets/prep_list.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/plu_details/plu_provider.dart';
import 'package:raptorpos/home/provider/plu_details/plu_state.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

class MenuItemDetail extends ConsumerStatefulWidget {
  final String pluNo;
  final int salesRef;
  final bool update;
  MenuItemDetail(this.pluNo, this.salesRef, this.update, {Key? key})
      : super(key: key);

  @override
  _MenuItemDetailState createState() => _MenuItemDetailState();
}

class _MenuItemDetailState extends ConsumerState<MenuItemDetail> {
  int qtyAdd = 0;
  double price = 0.0;
  double subTotal = 0.0;
  bool foc = false;
  Map<String, Map<String, String>> prepSelect = {};

  late PLUState pluState;
  TextEditingController _modifierController = TextEditingController();

  @override
  void initState() {
    ref
        .read(pluProvider.notifier)
        .fetchMenuDetail(widget.pluNo, widget.salesRef);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    pluState = ref.watch(pluProvider);

    return Center(
      child: Container(
        width: 320.w,
        height: 350.h,
        child: pluState is PLUSuccessState ? _shoppingItem(1) : Container(),
      ),
    );
  }

  Widget _shoppingItem(int itemIndex) {
    bool isDark = ref.watch(themeProvider);
    PLUSuccessState state = pluState as PLUSuccessState;

    price = state.pluDetails[1].toDouble() * 1.0;
    int qty = (state.orderSelect?.Quantity ?? 1) + qtyAdd;
    subTotal = state.pluDetails[1].toDouble() * qty;
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
                  color: HexColor('49152').withOpacity(1),
                  border: Border.all(
                    color: isDark ? backgroundDarkColor : Colors.green.shade100,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                  child: Text('${state.pluDetails[0]}',
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
            TextFormField(
              controller: _modifierController,
              decoration: const InputDecoration(
                hintText: 'Custome Modifer',
                hintStyle: TextStyle(fontStyle: FontStyle.italic),
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            SizedBox(
              height: 20.h,
            ),
            FractionallySizedBox(
              widthFactor: 0.7,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FOC Item',
                        style: bodyTextDarkStyle,
                      ),
                      Checkbox(
                          value: foc,
                          onChanged: (value) {
                            setState(() {
                              foc = value!;
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sub Total ', style: bodyTextDarkStyle),
                      Text((foc ? '0.0' : '$subTotal').currencyString('\$'),
                          style: bodyTextDarkStyle),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Price ', style: bodyTextDarkStyle),
                      Text((foc ? '0.0' : '$price').currencyString('\$'),
                          style: bodyTextDarkStyle),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            if (state.preps.isNotEmpty)
              CustomButton(
                callback: () {
                  showGeneralDialog(
                    context: context,
                    barrierColor: Colors.black38,
                    barrierLabel: 'Label',
                    barrierDismissible: true,
                    pageBuilder: (_, __, ___) => PreListWidget(
                      state.preps,
                      widget.update ? state.prepSelect : {},
                      callback,
                    ),
                  );
                },
                text: 'Prep Item',
                borderColor: primaryDarkColor,
                fillColor: primaryDarkColor,
                width: 200.w,
                height: 25.h,
              ),
            SizedBox(
              height: 5.h,
            ),
            CustomButton(
              callback: () {
                // create order item && modifier
                ref.read(orderProvoder.notifier).createOrderItem(widget.pluNo,
                    _modifierController.text, qty, foc, prepSelect);
                // foc item
                Get.back();
              },
              text: 'ORDER',
              borderColor: primaryDarkColor,
              fillColor: primaryDarkColor,
              width: 200.w,
              height: 25.h,
            ),
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
              qtyAdd--;
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
            qtyAdd++;
          });
        },
      ),
    );
  }

  void callback(Map<String, Map<String, String>> value) {
    prepSelect = value;
  }
}
