import 'package:flutter/material.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/home/provider/order/order_state.dart';

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
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    kSubTotal,
                    style: isDark
                        ? normalTextDarkStyle.copyWith(
                            fontWeight: FontWeight.bold)
                        : normalTextLightStyle.copyWith(
                            fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    kDiscount,
                    style: isDark
                        ? normalTextDarkStyle.copyWith(
                            fontWeight: FontWeight.bold)
                        : normalTextLightStyle.copyWith(
                            fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    kTax,
                    style: isDark
                        ? normalTextDarkStyle.copyWith(
                            fontWeight: FontWeight.bold)
                        : normalTextLightStyle.copyWith(
                            fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(kTotal,
                      style: isDark
                          ? normalTextDarkStyle.copyWith(
                              color: Colors.red, fontWeight: FontWeight.bold)
                          : normalTextLightStyle.copyWith(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    (state.bills?.isNotEmpty ?? false)
                        ? '\$ ${state.bills![2].toStringAsFixed(2)}'
                        : double.minPositive.currencyString('\$'),
                    style: isDark
                        ? normalTextDarkStyle.copyWith(
                            fontWeight: FontWeight.bold)
                        : normalTextLightStyle.copyWith(
                            fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    (state.bills?.isNotEmpty ?? false)
                        ? '\$ ${state.bills![3].toStringAsFixed(2)}'
                        : double.minPositive.currencyString('\$'),
                    style: isDark
                        ? normalTextDarkStyle.copyWith(
                            fontWeight: FontWeight.bold)
                        : normalTextLightStyle.copyWith(
                            fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    (state.bills?.isNotEmpty ?? false)
                        ? '\$ ${totalTax.toStringAsFixed(2)}'
                        : double.minPositive.currencyString('\$'),
                    style: isDark
                        ? normalTextDarkStyle.copyWith(
                            fontWeight: FontWeight.bold)
                        : normalTextLightStyle.copyWith(
                            fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                      (state.bills?.isNotEmpty ?? false)
                          ? '\$ ${state.bills![0].toStringAsFixed(2)}'
                          : double.minPositive.currencyString('\$'),
                      style: isDark
                          ? normalTextDarkStyle.copyWith(
                              color: Colors.red, fontWeight: FontWeight.bold)
                          : normalTextLightStyle.copyWith(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
