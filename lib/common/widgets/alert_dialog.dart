import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:raptorpos/constants/dimension_constant.dart';

import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';

class AppAlertDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? content;
  final EdgeInsets insetPadding;
  final bool isDark;

  const AppAlertDialog({
    Key? key,
    this.title,
    this.message,
    this.onConfirm,
    this.onCancel,
    this.content,
    required this.isDark,
    this.insetPadding =
        const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
  })  : assert(content == null ? title != null && onConfirm != null : true),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(0),
      scrollable: true,
      insetPadding: insetPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: red, width: 2),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 8, sigmaX: 8),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.screenHPadding, vertical: Spacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDark ? primaryDarkColor : backgroundColorVariant,
                ),
                child: content ??
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: isDark
                                ? titleTextDarkStyle.copyWith(height: 1.5)
                                : titleTextLightStyle.copyWith(height: 1.5),
                          ),
                        const SizedBox(height: 40),
                        if (message != null)
                          Text(
                            message!,
                            style: isDark
                                ? modalTextDarkStyle.copyWith(height: 1.5)
                                : modalTextLightStyle.copyWith(height: 1.5),
                          ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  if (onConfirm != null) {
                                    onConfirm!();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: orange,
                                ),
                                child: const Text('Ok'),
                              ),
                            ),
                            const SizedBox(width: Spacing.sm),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: onCancel ??
                                    () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  primary: orange,
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
