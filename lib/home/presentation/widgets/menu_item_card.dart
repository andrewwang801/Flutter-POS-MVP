import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/extension/workable.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/presentation/widgets/menu_item_detail.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../../constants/dimension_constant.dart';
import '../../model/menu_item_model.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/text_style_constant.dart';
import '../../provider/order/order_provider.dart';

List<MaterialColor> menuItemColors = <MaterialColor>[
  Colors.grey,
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.pink,
  Colors.blue,
  Colors.grey,
  Colors.teal,
];

class MenuItemCard extends ConsumerStatefulWidget {
  final MenuItemModel menuItem;
  final OrderItemModel? orderItem;

  MenuItemCard(this.orderItem, {required this.menuItem, Key? key})
      : super(key: key);

  @override
  _MenuItemCardState createState() => _MenuItemCardState();
}

class _MenuItemCardState extends ConsumerState<MenuItemCard> {
  TextEditingController _qtyController = TextEditingController();

  bool isDark = false;
  int qtyAdd = 0;
  bool isOrdered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDark = ref.watch(themeProvider);

    final OrderState orderState = ref.watch(orderProvoder);

    OrderItemModel? orderItem = null;
    if (orderState.workable == Workable.ready &&
        (orderState.orderItemTree?.isNotEmpty ?? false)) {
      orderItem = orderState.orderItems?.firstWhereOrNull(
        (element) {
          return element.PLUNo == widget.menuItem.pluNumber;
        },
      );
      if (orderItem != null) {
        isOrdered = true;

        if (qtyAdd == 0) {
          qtyAdd = orderItem.Quantity ?? 0;
          _qtyController.text = '$qtyAdd';
        }
      }
    }

    return InkWell(
      onTap: () {
        // create order item && modifier
        ref
            .read(orderProvoder.notifier)
            .createOrderItem(widget.menuItem.pluNumber ?? '', '', 1, false, {});
        // foc item
      },
      onLongPress: () {
        showGeneralDialog(
          context: context,
          barrierColor: Colors.black38,
          barrierLabel: 'Label',
          barrierDismissible: true,
          pageBuilder: (_, __, ___) => MenuItemDetail(
            widget.menuItem.pluNumber ?? '',
            0,
            false,
          ),
        );
      },
      child: Responsive(
        mobile: _moibleItemCard(),
        tablet: _tabletItemCard(),
        desktop: _tabletItemCard(),
      ),
    );
  }

  Widget menuItemImage(MenuItemModel menu) {
    if ((menu.pluImage ?? 0) == 0) {
      return Image.asset(
        "assets/images/placeholder.png",
        fit: BoxFit.cover,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: menu.imageName ?? '',
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

  Widget _tabletItemCard() {
    return Ink(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Spacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: backgroundColorVariant),
                borderRadius: BorderRadius.circular(Spacing.sm),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Spacing.sm),
                child: menuItemImage(widget.menuItem),
              ),
            ),
          ),
          verticalSpaceTiny,
          FittedBox(
            fit: BoxFit.cover,
            child: Text(
              widget.menuItem.itemName ?? '',
              textAlign: TextAlign.left,
              style: isDark
                  ? bodyTextDarkStyle
                  : bodyTextLightStyle.copyWith(color: Colors.black),
            ),
          ),
          verticalSpaceTiny,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${widget.menuItem.price ?? 0}',
                ),
              ),
              Container(
                padding: EdgeInsets.all(Spacing.xs),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Spacing.sm),
                  color: orange,
                ),
                child: Text(
                  'Add to cart',
                  style: bodyTextDarkStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moibleItemCard() {
    return Ink(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      width: 70,
      height: 70,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: backgroundColorVariant),
              borderRadius: BorderRadius.circular(Spacing.sm),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.sm),
              child: menuItemImage(widget.menuItem),
            ),
          ),
          horizontalSpaceTiny,
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: Text(
                  widget.menuItem.itemName ?? '',
                  textAlign: TextAlign.left,
                  style: isDark
                      ? bodyTextDarkStyle
                      : bodyTextLightStyle.copyWith(color: Colors.black),
                ),
              ),
              Text(
                '${widget.menuItem.price ?? 0}',
                textAlign: TextAlign.left,
              ),
            ],
          ),
          Spacer(),
          isOrdered
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _decrementButton(),
                    _qtyEdit(),
                    _incrementButton(),
                  ],
                )
              : Container(
                  padding: EdgeInsets.all(Spacing.xs),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Spacing.sm),
                    color: orange,
                  ),
                  child: Text(
                    'Add to cart',
                    style: bodyTextDarkStyle,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _decrementButton() {
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

  Widget _incrementButton() {
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
}
