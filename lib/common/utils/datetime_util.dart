import 'package:intl/intl.dart';

mixin DateTimeUtil {
  String currentDateTime(String format) {
    final String date = DateFormat(format).format(DateTime.now());
    return date;
  }

  String dateToString(DateTime date, String format) {
    final String dateString = DateFormat(format).format(date);
    return dateString;
  }

  String convertFormat(String strDate1, String targetFormat) {
    final DateTime date1 = DateTime.parse(strDate1);
    return dateToString(date1, targetFormat);
  }

  DateTime parse(String timeValue) {
    String prefix = '0000-01-01T';
    return DateTime.parse(prefix + timeValue);
  }

  String format(DateTime value) {
    return '${value.hour}:${value.minute}:${value.second}.${value.millisecond}';
  }
}
