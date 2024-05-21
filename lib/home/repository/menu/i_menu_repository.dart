import 'package:raptorpos/home/model/menu_item_model.dart';
import 'package:raptorpos/home/model/menu_model.dart';

abstract class IMenuRepository {
  Future<List<MenuModel>> getMenuHdr();
  Future<List<MenuItemModel>> getMenuItemByHdr(int menuid);
  Future<List<MenuItemModel>> getMenuByPLU();
  Future<List<String>> getPLUDetails();
}
