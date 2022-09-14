import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../print/provider/print_provider.dart';
import 'zday_report_controller.dart';
import 'zday_report_state.dart';

final StateNotifierProvider<ZDayReportController, ZDayReportState>
    zDayReportProvider =
    StateNotifierProvider<ZDayReportController, ZDayReportState>(
  (ref) {
    return GetIt.I<ZDayReportController>(
        param1: ref.read(printProvider.notifier));
  },
);
