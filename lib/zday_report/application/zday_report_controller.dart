import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../domain/report_local_repository.dart';
import 'zday_report_state.dart';

@Injectable()
class ZDayReportController extends StateNotifier<ZDayReportState> {
  ZDayReportController(this.reportLocalRepository) : super(ZDayReportState());

  final ReportLocalRepository reportLocalRepository;
}
