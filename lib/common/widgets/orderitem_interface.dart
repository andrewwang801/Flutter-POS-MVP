import 'package:flutter/cupertino.dart';

abstract class IOrderItem {
  IOrderItem? parent;
  Widget render(BuildContext context, int padding, bool isDark,
      {bool detail = false});
}
