import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget mobileLandscape;
  final Widget tablet;
  final Widget tabletPortrait;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    required this.mobileLandscape,
    required this.tablet,
    required this.tabletPortrait,
    required this.desktop,
  }) : super(key: key);

// This size work fine on my design, maybe you need some customization depends on your design

  // This isMobile, isTablet, isDesktop helep us later
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide < 1100 &&
      MediaQuery.of(context).size.shortestSide >= 650;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // If our width is more than 1100 then we consider it a desktop
      builder: (context, constraints) {
        if (MediaQuery.of(context).size.shortestSide >= 1100) {
          return desktop;
        }
        // If width it less then 1100 and more then 650 we consider it as tablet
        else if (MediaQuery.of(context).size.shortestSide >= 650) {
          if (MediaQuery.of(context).orientation == Orientation.landscape) {
            return tablet;
          } else {
            return tabletPortrait;
          }
        }
        // Or less then that we called it mobile
        else {
          if (MediaQuery.of(context).orientation == Orientation.landscape) {
            return mobileLandscape;
          } else {
            return mobile;
          }
        }
      },
    );
  }
}
