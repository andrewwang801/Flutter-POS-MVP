import 'package:injectable/injectable.dart';

import '../../common/helper/db_helper.dart';

@Injectable()
class ReportLocalRepository {
  ReportLocalRepository(this.dbHelper);

  final LocalDBHelper dbHelper;

  Future<void> transaction(String date1, String date2, String posID) async {}
}
