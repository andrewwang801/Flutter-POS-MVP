import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raptorpos/home/model/menu_item_model.dart';
import 'package:raptorpos/home/model/menu_model.dart';
import 'package:raptorpos/home/repository/menu/menu_local_repository.dart';

final menuHdrProvider = FutureProvider<List<MenuModel>>((ref) async {
  final repository = ref.read(repositoryProvider);
  return await repository.getMenuHdr();
});

final menuByHdrProvider =
    FutureProvider.family<List<MenuItemModel>, int>((ref, id) async {
  final repository = ref.read(repositoryProvider);
  return await repository.getMenuItemByHdr(id);
});

final menuByPLUProvider = FutureProvider<List<MenuItemModel>>((ref) async {
  final repository = ref.read(repositoryProvider);
  return await repository.getMenuByPLU();
});

final pluDetailsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.read(repositoryProvider);
  return await repository.getPLUDetails('');
});

final menuIDProvider = StateProvider<int>((ref) => 5);
