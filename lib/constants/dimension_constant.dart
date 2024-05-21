import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final double iconSize = 24;
final double paddingDimen = 12.0.w;
final double bodyFontSize = 14.0.sp;
final double modifierItemFontSize = 12.0.sp;
final double titleFontSize = 16.0.sp;

class Spacing {
  static const double screenHPadding = 17;

  static const double xs = 5;

  static const double sm = 10;

  static const double md = 20;

  static const double lg = 25;

  static const double xl = 30;
}

const Widget horizontalSpaceTiny = SizedBox(width: 5.0);
const Widget horizontalSpaceSmall = SizedBox(width: 10.0);
const Widget horizontalSpaceRegular = SizedBox(width: 18.0);
const Widget horizontalSpaceMedium = SizedBox(width: 25.0);
const Widget horizontalSpaceLarge = SizedBox(width: 50.0);

// Vertical Spacing
const Widget verticalSpaceTiny = SizedBox(height: 5.0);
const Widget verticalSpaceSmall = SizedBox(height: 10.0);
const Widget verticalSpaceRegular = SizedBox(height: 18.0);
const Widget verticalSpaceMedium = SizedBox(height: 25);
const Widget verticalSpaceLarge = SizedBox(height: 50.0);
const Widget verticalSpaceMassive = SizedBox(height: 120.0);
