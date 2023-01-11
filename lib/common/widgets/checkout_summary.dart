import 'package:flutter/material.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';

import '../../constants/color_constant.dart';
import '../../constants/dimension_constant.dart';
import '../extension/string_extension.dart';

import 'package:raptorpos/common/i18n/en.dart';

class checkout_summary extends StatelessWidget {
  const checkout_summary({
    Key? key,
    required this.isDark,
    required this.state,
    required this.totalTax,
  }) : super(key: key);

  final bool isDark;
  final OrderState state;
  final double totalTax;

  @override
  Widget build(BuildContext context) {
    double gTotal = 0.0;
    if (state.bills?.isNotEmpty ?? false) {
      gTotal = state.bills![0].toDouble();
    }
    double discount = 0.0;
    if (state.bills?.isNotEmpty ?? false) {
      discount = state.bills![3].toDouble();
    }
    double stotal = 0.0;
    if (state.bills?.isNotEmpty ?? false) {
      stotal = state.bills![2].toDouble();
    }

    return Container(
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: isDark
            ? Responsive.isMobile(context)
                ? backgroundDarkColor
                : backgroundDarkColor
            : backgroundColorVariant,
        borderRadius: BorderRadius.circular(Spacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: isDark
                ? bodyTextDarkStyle.copyWith(fontWeight: FontWeight.bold)
                : bodyTextLightStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kSubTotal,
                style: isDark
                    ? bodyTextDarkStyle.copyWith(fontWeight: FontWeight.bold)
                    : bodyTextLightStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                stotal.currencyString('\$'),
                style: isDark
                    ? bodyTextDarkStyle.copyWith(fontWeight: FontWeight.bold)
                    : bodyTextLightStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kDiscount,
                style: isDark
                    ? bodyTextDarkStyle.copyWith(fontWeight: FontWeight.bold)
                    : bodyTextLightStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                discount.toStringAsFixed(2).currencyString('\$'),
                style: isDark
                    ? bodyTextDarkStyle.copyWith(fontWeight: FontWeight.bold)
                    : bodyTextLightStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kTax,
                style: isDark
                    ? bodyTextDarkStyle.copyWith(fontWeight: FontWeight.bold)
                    : bodyTextLightStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$ ${totalTax.toStringAsFixed(2)}',
                style: isDark
                    ? bodyTextDarkStyle.copyWith(fontWeight: FontWeight.bold)
                    : bodyTextLightStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(kTotal,
                  style: isDark
                      ? bodyTextDarkStyle.copyWith(
                          color: Colors.red, fontWeight: FontWeight.bold)
                      : bodyTextLightStyle.copyWith(
                          color: Colors.red, fontWeight: FontWeight.bold)),
              Text(gTotal.toStringAsFixed(2).currencyString('\$'),
                  style: isDark
                      ? bodyTextDarkStyle.copyWith(
                          color: Colors.red, fontWeight: FontWeight.bold)
                      : bodyTextLightStyle.copyWith(
                          color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
