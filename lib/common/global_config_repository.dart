import 'package:injectable/injectable.dart';
import 'package:sqflite/sqlite_api.dart';

import 'helper/db_helper.dart';
import 'utils/type_util.dart';

@Injectable()
class GlobalConfigRepository with TypeUtil {
  GlobalConfigRepository(this.dbHelper);

  final LocalDBHelper dbHelper;

  Future<List<List<String>>> getPosDtls() async {
    final Database db = await dbHelper.database;

    const String query = "SELECT * FROM POSDtls WHERE POSID = 'POS001'";
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<List<List<String>>> getPOSDefault() async {
    final Database db = await dbHelper.database;

    const String query = 'SELECT * FROM POSDefaults';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return mapListToString2D(maps);
  }
}
