import 'menu_item_model.dart';

class MenuModel {
  final int color;
  final String? label;
  final List<MenuItemModel> menuItems;

  MenuModel(this.color, this.label, this.menuItems);
}

final List<MenuModel> menus = [
  MenuModel(
    6,
    'SIGNATURE CHICKEN',
    [
      MenuItemModel(0, '!SINGLE CHICKEN'),
      MenuItemModel(0, '!QUARTER CHICKEN'),
      MenuItemModel(0, '!HALF CHICKEN'),
      MenuItemModel(0, '!WHOLE CHICKEN'),
      MenuItemModel(0, '!ROASTED'),
      MenuItemModel(0, 'SOYA SAUCE'),
      MenuItemModel(1, '!STEAMED'),
      MenuItemModel(1, 'SET CHICK A HOT'),
      MenuItemModel(1, 'SET CHICK A ICED'),
      MenuItemModel(1, 'SET CHICK A WATER'),
      MenuItemModel(1, '!SINGLE CHICKEN'),
      MenuItemModel(1, '!QUARTER CHICKEN'),
      MenuItemModel(1, '!HALF CHICKEN'),
      MenuItemModel(1, '!WHOLE CHICKEN'),
      MenuItemModel(2, '!ROASTED'),
      MenuItemModel(2, 'SOYA SAUCE'),
      MenuItemModel(2, '!STEAMED'),
      MenuItemModel(2, 'SET CHICK A HOT'),
      MenuItemModel(2, 'SET CHICK A ICED'),
      MenuItemModel(2, 'SET CHICK A WATER'),
      MenuItemModel(2, 'SET CHICK A HOT'),
      MenuItemModel(2, 'SET CHICK A ICED'),
      MenuItemModel(2, 'SET CHICK A WATER'),
    ],
  ),
  MenuModel(
    6,
    'FRIED DELIGHTS',
    [
      MenuItemModel(0, '!SINGLE CHICKEN'),
      MenuItemModel(0, '!QUARTER CHICKEN'),
      MenuItemModel(0, '!HALF CHICKEN'),
      MenuItemModel(0, '!WHOLE CHICKEN'),
      MenuItemModel(1, '!ROASTED'),
      MenuItemModel(1, 'SOYA SAUCE'),
      MenuItemModel(1, '!STEAMED'),
      MenuItemModel(2, 'SET CHICK A HOT'),
      MenuItemModel(2, 'SET CHICK A ICED'),
      MenuItemModel(2, 'SET CHICK A WATER'),
    ],
  ),
  MenuModel(
    6,
    'SOUP',
    [
      MenuItemModel(0, '!SINGLE CHICKEN'),
      MenuItemModel(0, '!QUARTER CHICKEN'),
      MenuItemModel(0, '!HALF CHICKEN'),
      MenuItemModel(0, '!WHOLE CHICKEN'),
      MenuItemModel(1, '!ROASTED'),
      MenuItemModel(1, 'SOYA SAUCE'),
      MenuItemModel(1, '!STEAMED'),
      MenuItemModel(2, 'SET CHICK A HOT'),
      MenuItemModel(2, 'SET CHICK A ICED'),
      MenuItemModel(2, 'SET CHICK A WATER'),
    ],
  ),
  MenuModel(
    6,
    'BEAN CURD',
    [
      MenuItemModel(0, '!SINGLE CHICKEN'),
      MenuItemModel(0, '!QUARTER CHICKEN'),
      MenuItemModel(0, '!HALF CHICKEN'),
      MenuItemModel(0, '!WHOLE CHICKEN'),
      MenuItemModel(1, '!ROASTED'),
      MenuItemModel(1, 'SOYA SAUCE'),
      MenuItemModel(1, '!STEAMED'),
      MenuItemModel(2, 'SET CHICK A HOT'),
      MenuItemModel(2, 'SET CHICK A ICED'),
      MenuItemModel(2, 'SET CHICK A WATER'),
    ],
  ),
  MenuModel(
    6,
    'BEEF',
    [
      MenuItemModel(0, '!SINGLE CHICKEN'),
      MenuItemModel(0, '!QUARTER CHICKEN'),
      MenuItemModel(0, '!HALF CHICKEN'),
      MenuItemModel(0, '!WHOLE CHICKEN'),
      MenuItemModel(1, '!ROASTED'),
      MenuItemModel(1, 'SOYA SAUCE'),
      MenuItemModel(1, '!STEAMED'),
      MenuItemModel(2, 'SET CHICK A HOT'),
      MenuItemModel(2, 'SET CHICK A ICED'),
      MenuItemModel(2, 'SET CHICK A WATER'),
    ],
  ),
  MenuModel(
    6,
    'RICE',
    [
      MenuItemModel(0, '!SINGLE CHICKEN'),
      MenuItemModel(0, '!QUARTER CHICKEN'),
      MenuItemModel(0, '!HALF CHICKEN'),
      MenuItemModel(0, '!WHOLE CHICKEN'),
      MenuItemModel(1, '!ROASTED'),
      MenuItemModel(1, 'SOYA SAUCE'),
      MenuItemModel(1, '!STEAMED'),
      MenuItemModel(2, 'SET CHICK A HOT'),
      MenuItemModel(2, 'SET CHICK A ICED'),
      MenuItemModel(2, 'SET CHICK A WATER'),
    ],
  ),
];
