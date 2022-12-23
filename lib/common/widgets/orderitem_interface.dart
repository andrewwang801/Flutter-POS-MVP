import 'package:flutter/cupertino.dart';

abstract class IOrderItem {
  IOrderItem? parent;
  Widget render(BuildContext context, int padding, bool isDark,
      void Function() callback, void Function() editCallback,
      {bool detail = false});
}
