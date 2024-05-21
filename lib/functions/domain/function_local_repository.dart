import 'package:injectable/injectable.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../common/helper/db_helper.dart';
import '../model/function_model.dart';

@Injectable()
class FunctionLocalRepository {
  FunctionLocalRepository(this.dbHelper);

  final LocalDBHelper dbHelper;

  Future<List<FunctionModel>> getFunctions() async {
    Database db = await dbHelper.database;
    const String query =
        'SELECT FunctionID, Title, SubFunctionID FROM SubFunction WHERE FunctionID NOT IN (24, 25, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 91, 92, 93, 94) AND FActive = 1 ORDER BY Title COLLATE NOCASE';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) => FunctionModel.fromJson(e)).toList();
  }
}
