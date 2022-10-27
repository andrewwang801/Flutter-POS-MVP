import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../../common/GlobalConfig.dart';
import '../../common/helper/db_helper.dart';
import '../../common/utils/datetime_util.dart';
import '../../common/utils/type_util.dart';
import '../model/operator_model.dart';
import 'i_operator_repository.dart';

@Injectable(as: IOperatorRepository)
class OperatorLocalRepository extends IOperatorRepository
    with DateTimeUtil, TypeUtil {
  OperatorLocalRepository(this.dbHelper);

  final LocalDBHelper dbHelper;

  @override
  Future<void> checkOpHistory() async {
    final String query =
        "SELECT OperatorNo FROM OpHistory WHERE LstLogin = 1 AND POSID = '${POSDtls.deviceNo}'";

    final Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      final int operatorNo = dynamicToInt(maps[0].values.elementAt(0));
      await updateOpHistory(operatorNo);
    }
  }

  @override
  Future<int> countOperatorTable() async {
    const String query = 'SELECT COUNT(*) FROM Operator';

    final Database db = await dbHelper.database;
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.length;
  }

  @override
  Future<OperatorModel?> getOperators(String pin) async {
    final Database db = await dbHelper.database;
    final String query =
        'SELECT * FROM OPERATOR WHERE opActiveYN = 1 AND PIN = "$pin"';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      return OperatorModel.fromJson(maps[0]);
    }
  }

  @override
  Future<OperatorModel?> getOperatorByOperatorNo(int operatorNo) async {
    final Database db = await dbHelper.database;
    final String query = 'SELECT * FROM OPERATOR WHERE PIN = $operatorNo';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      return OperatorModel.fromJson(maps[0]);
    }
  }

  @override
  Future<void> insertOpHistory(int operatorNo) async {
    final String dateIn = currentDateTime('yyyy-MM-dd');
    final String timeIn = currentDateTime('HH:mm:ss');

    String query =
        'INSERT INTO OpHistory(OperatorNo, DateIn, TimeIn, OpLogOut, LstLogin, POSID)';
    final String values =
        " VALUES ( $operatorNo, '$dateIn', '$timeIn', 0, 1, '${POSDtls.deviceNo}' )";
    query += values;

    final Database db = await dbHelper.database;
    await db.rawQuery(query);
  }

  @override
  Future<void> updateOpHistory(int operatorNo) async {
    final String dateOut = currentDateTime('yyyy-MM-dd');
    final String timeOut = currentDateTime('HH:mm:ss');
    final String query =
        "UPDATE OpHistory SET DateOut = '$dateOut', TimeOut = '$timeOut', OpLogOut = 1, LstLogin = 0 WHERE LstLogin = 1 AND POSID = '${POSDtls.deviceNo}' AND OperatorNo = $operatorNo";

    final Database db = await dbHelper.database;
    await db.rawQuery(query);
  }
}
