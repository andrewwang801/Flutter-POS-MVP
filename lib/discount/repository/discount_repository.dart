import 'package:injectable/injectable.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../common/helper/db_helper.dart';
import '../../common/utils/type_util.dart';

@Injectable()
class DiscountRepository with TypeUtil {
  DiscountRepository({required this.dbHelper});

  final LocalDBHelper dbHelper;

  Future<bool> CheckDiscBill(int SalesNo, int SplitNo) async {
    String query =
        'SELECT COUNT(*) FROM HeldItems WHERE FunctionID = 25 AND TransStatus = " " AND SalesNo = $SalesNo AND SplitNo = $SplitNo';

    Database database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    bool isDiscBill = false;

    if (dynamicToInt(data[0].get(0)) > 0) {
      isDiscBill = true;
    }

    return isDiscBill;
  }
}
