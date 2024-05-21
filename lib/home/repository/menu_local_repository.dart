// import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:raptorpos/home/model/menu_model.dart';
import 'package:raptorpos/home/model/menu_item_model.dart';
import 'package:raptorpos/home/repository/i_menu_repository.dart';

import 'package:raptorpos/common/helper/db_helper.dart';

// @Named('menuLocalRepository')
// @Injectable(as: IMenuRepository)
class MenuLocalRepository implements IMenuRepository {
  final Future<Database> database;
  MenuLocalRepository({required this.database});

  @override
  Future<List<MenuItemModel>> getMenuByPLU() async {
    return <MenuItemModel>[];
  }

  @override
  Future<List<MenuModel>> getMenuHdr() async {
    final db = await database;
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
    final db = await database;
    // Query MenuHdr table for all menus
    final String query =
        'SELECT A.PLUNumber, ItemName, ItemName_Chinese, KPosition, RGBColour, Sell1, PLUsoldout, DisplayImage, imagename FROM Menu1 A INNER JOIN PLU B ON A.PLUNumber = B.PLUNumber WHERE MenuID = $menuid ORDER BY KPosition';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) {
      return MenuItemModel.fromJson(e);
    }).toList();
  }

  @override
  Future<List<String>> getPLUDetails() async {
    final db = await database;
    return <String>[];
  }
}

final repositoryProvider = Provider<MenuLocalRepository>((ref) {
  Future<Database> database = ref.read<Future<Database>>(databaseProvider);
  return MenuLocalRepository(database: database);
});
