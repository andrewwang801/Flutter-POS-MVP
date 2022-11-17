import 'package:flutter/material.dart';

import '../../home/presentation/widgets/remark_dialog.dart';

class PresentationUtil {
  factory PresentationUtil() {
    return _instance;
  }

  PresentationUtil._internal();

  static final PresentationUtil _instance = PresentationUtil._internal();

// Show Remarks Dialog
  showRemarksDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RemarksDialog();
        });
  }
}
