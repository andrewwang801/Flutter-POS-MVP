import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../print/provider/print_provider.dart';
import 'sales_report_controller.dart';
import 'sales_report_state.dart';

final StateNotifierProvider<SalesReportController, SalesReportState>
    salesReportProvider =
    StateNotifierProvider<SalesReportController, SalesReportState>(
  (ref) {
    return GetIt.I<SalesReportController>(
        param1: ref.read(printProvider.notifier));
  },
);
