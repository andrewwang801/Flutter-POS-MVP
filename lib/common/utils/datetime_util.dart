import 'package:intl/intl.dart';

mixin DateTimeUtil {
  String currentDateTime(String format) {
    final String date = DateFormat(format).format(DateTime.now());
    return date;
  }
}
