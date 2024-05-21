// import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:raptorpos/home/model/prep/prep_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:raptorpos/home/model/menu_model.dart';
import 'package:raptorpos/home/model/menu_item_model.dart';
import 'package:raptorpos/home/repository/menu/i_menu_repository.dart';

import 'package:raptorpos/common/helper/db_helper.dart';

@Injectable(as: IMenuRepository)
class MenuLocalRepository implements IMenuRepository {
  // final Future<Database> database;
  LocalDBHelper database;
  MenuLocalRepository({required this.database});

  @override
  Future<List<MenuItemModel>> getMenuByPLU() async {
    return <MenuItemModel>[];
  }

  @override
  Future<List<MenuModel>> getMenuHdr() async {
    final db = await database.database;
    // Query MenuHdr table for all menus
    final String query =
        'SELECT MenuID, MenuName, MenuName_Chinese, RGBColour, KPosition FROM MenuHdr1 WHERE MActive = 1 AND KPosition <> 0 ORDER BY KPosition';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) {
      return MenuModel.fromJson(e);
    }).toList();
  }

  @override
  Future<List<MenuItemModel>> getMenuItemByHdr(int menuid) async {
    final db = await database.database;
    // Query MenuHdr table for all menus
    final String query =
        // 'SELECT A.MenuID, A.PLUNumber, ItemName, ItemName_Chinese, KPosition, RGBColour, Sell1, PLUsoldout, DisplayImage, imagename FROM Menu1 A INNER JOIN PLU B ON A.PLUNumber = B.PLUNumber WHERE MenuID = $menuid ORDER BY KPosition';
        'SELECT A.MenuID, A.PLUNumber, ItemName, ItemName_Chinese, KPosition, RGBColour, Sell1, PLUsoldout, DisplayImage, imagename FROM Menu1 A INNER JOIN PLU B ON A.PLUNumber = B.PLUNumber ORDER BY KPosition';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) {
      return MenuItemModel.fromJson(e);
    }).toList();
  }

  @override
  Future<List<String>> getPLUDetails(String pluNo) async {
    final db = await database.database;
    String query =
        'SELECT PLUName, Sell1, Description, DisplayImage, imagename, PLUOpen, LinkMenu, LinkMenuNo FROM PLU WHERE PLUNumber = \'$pluNo\'';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.length > 0) {
      return maps[0].entries.map((e) {
        return e.value.toString();
      }).toList();
    }
    return <String>[];
  }

  @override
  Future<List<PrepModel>> getPrepData(int menuId) async {
    final Database db = await database.database;
    String query =
        "SELECT m.PLUNumber as number, ItemName as name FROM Menu1 m INNER JOIN PLU p ON m.PLUNumber = p.PLUNumber WHERE p.Preparation = 1 AND m.MenuID = $menuId";
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) {
      return PrepModel.fromJson(e);
    }).toList();
  }
}

final repositoryProvider = Provider<IMenuRepository>((ref) {
  // Future<Database> database = ref.read<Future<Database>>(databaseProvider);
  // return MenuLocalRepository(database: database);
  return GetIt.I<IMenuRepository>();
});
