// ignore_for_file: prefer_relative_imports

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/extension/string_extension.dart';
import 'package:raptorpos/common/widgets/numpad.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/presentation/widgets/prep_list.dart';
import 'package:raptorpos/home/provider/order/order_provider.dart';
import 'package:raptorpos/home/provider/plu_details/plu_provider.dart';
import 'package:raptorpos/home/provider/plu_details/plu_state.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

class MenuItemDetail extends ConsumerStatefulWidget {
  final String pluNo;
  final int salesRef;
  final bool update;
  final OrderItemModel? orderItem;
  final Map<String, Map<String, String>>? prepSelect;
  MenuItemDetail(this.pluNo, this.salesRef, this.update,
      {this.orderItem, this.prepSelect, Key? key})
      : super(key: key);

  @override
  _MenuItemDetailState createState() => _MenuItemDetailState();
}

class _MenuItemDetailState extends ConsumerState<MenuItemDetail> {
  int qtyAdd = 0;
  double price = 0.0;
  double subTotal = 0.0;
  bool foc = false;
  late Map<String, Map<String, String>> _prepSelect;

  late PLUState pluState;
  late bool isDark;

  String userInputModifier = '';

  TextEditingController _modifierController = TextEditingController();
  TextEditingController _qtyController = TextEditingController();

  @override
  void initState() {
    ref
        .read(pluProvider.notifier)
        .fetchMenuDetail(widget.pluNo, widget.salesRef);
    _prepSelect = widget.prepSelect ?? {};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);
    pluState = ref.watch(pluProvider);

    return Center(
      child: Container(
        width: Responsive.isMobile(context) ? 400.w : 0.4.sw,
        height: Responsive.isMobile(context) ? 0.9.sh : 0.9.sh,
        child: pluState is PLUSuccessState ? _shoppingItem(1) : Container(),
      ),
    );
  }

  Widget _shoppingItem(int itemIndex) {
    bool isDark = ref.watch(themeProvider);
    PLUSuccessState state = pluState as PLUSuccessState;

    price = state.pluDetails[1].toDouble() * 1.0;
    final String itemName = state.pluDetails[0];
    int qty = (state.orderSelect?.Quantity ?? 1) + qtyAdd;
    subTotal = state.pluDetails[1].toDouble() * qty;
    _prepSelect = state.prepSelect;

    _qtyController.text = '$qty';

    String? originModifier = state.modSelect?.ItemName?.substring(2);
    if (userInputModifier.isNotEmpty)
      _modifierController.text = userInputModifier;
    else if (originModifier != null && originModifier.isNotEmpty)
      _modifierController.text = originModifier;

    return Center(
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.md)),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        leading: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.0, color: backgroundColorVariant),
                              borderRadius: BorderRadius.circular(Spacing.sm),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Spacing.sm),
                              child: pluImage(state.pluDetails),
                            ),
                          ),
                        ),
                        title: Text(itemName),
                        subtitle: Text('$price'),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _decrementButton(itemIndex),
                        _qtyEdit(),
                        _incrementButton(itemIndex),
                      ],
                    ),
                  ],
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FOC Item',
                          style:
                              isDark ? bodyTextDarkStyle : bodyTextLightStyle,
                        ),
                        Checkbox(
                            value: foc,
                            activeColor: Colors.white,
                            checkColor: orange,
                            shape: CircleBorder(),
                            side: MaterialStateBorderSide.resolveWith(
                              (states) {
                                return BorderSide(width: 1.5, color: orange);
                              },
                            ),
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
                        Text('Sub Total: ',
                            style: isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
                        Text((foc ? '0.0' : '$subTotal').currencyString('\$'),
                            style: isDark
                                ? bodyTextDarkStyle
                                : bodyTextLightStyle),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 320.w,
                height: ScreenUtil().orientation == Orientation.landscape
                    ? Responsive.isMobile(context)
                        ? 0.4.sh
                        : 0.3.sh
                    : Responsive.isMobile(context)
                        ? 0.25.sh
                        : 0.2.sh,
                child: NumPad(
                  isDark: isDark,
                  buttonColor: isDark ? primaryButtonDarkColor : Colors.white,
                  backgroundColor:
                      isDark ? Colors.transparent : backgroundColorVariant,
                  delete: () {},
                  onSubmit: () {},
                  controller: _qtyController,
                  onlyNum: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _modifierController,
                  onChanged: (String value) {
                    userInputModifier = value;
                  },
                  decoration: const InputDecoration(
                    label: Text('Custom Modifier'),
                    labelStyle: TextStyle(color: orange),
                    hintText: 'Custom Modifer',
                    hintStyle: TextStyle(fontStyle: FontStyle.italic),
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide(color: orange, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide(color: orange, width: 1.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide(color: orange, width: 1.0),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  ),
                  minLines: 1,
                  maxLines: 2,
                ),
              ),
              if (state.preps.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.sm)),
                      minimumSize: Size.fromHeight(
                          40), // fromHeight use double.infinity as width and 40 is the height
                    ),
                    onPressed: () {
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
                    child: Text('Add Prep Items'),
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Spacing.sm)),
                    minimumSize: Size.fromHeight(
                        40), // fromHeight use double.infinity as width and 40 is the height
                  ),
                  onPressed: () {
                    // create order item && modifier
                    if (widget.update) {
                      ref.read(orderProvoder.notifier).updateOrderItem(
                          widget.pluNo,
                          _modifierController.text,
                          qty,
                          foc,
                          _prepSelect,
                          widget.orderItem ?? OrderItemModel());
                    } else {
                      ref.read(orderProvoder.notifier).createOrderItem(
                          widget.pluNo,
                          _modifierController.text,
                          qty,
                          foc,
                          _prepSelect);
                      // foc item
                    }
                    Get.back();
                  },
                  child: Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _decrementButton(int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: red),
        borderRadius: BorderRadius.circular(Spacing.xs),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        onPressed: () {
          if (qtyAdd > 0) {
            setState(() {
              qtyAdd--;
              _qtyController.text = '$qtyAdd';
            });
          }
        },
        icon: Icon(
          Icons.remove,
          color: red,
          size: Spacing.md,
        ),
      ),
    );
  }

  Widget _incrementButton(int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: greenVariant1),
        borderRadius: BorderRadius.circular(Spacing.xs),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        onPressed: () {
          setState(() {
            qtyAdd++;
            _qtyController.text = '$qtyAdd';
          });
        },
        icon: Icon(
          Icons.add,
          color: greenVariant1,
          size: Spacing.md,
        ),
      ),
    );
  }

  Widget _qtyEdit() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
      width: Responsive.isMobile(context) ? 60.w : 40.w,
      child: TextFormField(
        controller: _qtyController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          focusColor: red,
          hoverColor: red,
          contentPadding: EdgeInsets.symmetric(
              vertical: Spacing.xs, horizontal: Spacing.xs),
          border: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: red),
            borderRadius: BorderRadius.circular(Spacing.xs),
          ),
        ),
      ),
    );
  }

  Widget pluImage(List<String> pluDetails) {
    if (!pluDetails[3].toBool()) {
      return Image.asset(
        "assets/images/placeholder.png",
        fit: BoxFit.cover,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: pluDetails[4],
        errorWidget: (_, __, ___) {
          return Image.asset(
            "assets/images/placeholder.png",
            fit: BoxFit.cover,
          );
        },
        fit: BoxFit.cover,
        placeholder: (_, __) {
          return Image.asset(
            "assets/images/placeholder.png",
            fit: BoxFit.cover,
          );
        },
      );
    }
  }

  void callback(Map<String, Map<String, String>> value) {
    _prepSelect = value;
  }
}
