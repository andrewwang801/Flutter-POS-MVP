// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../common/helper/db_helper.dart' as _i3;
import '../home/provider/order/order_state_notifier.dart' as _i8;
import '../home/repository/menu/i_menu_repository.dart' as _i4;
import '../home/repository/menu/menu_local_repository.dart' as _i5;
import '../home/repository/order/i_order_repository.dart' as _i6;
import '../home/repository/order/order_local_repository.dart'
    as _i7; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.singleton<_i3.LocalDBHelper>(_i3.LocalDBHelper());
  gh.factory<_i4.IMenuRepository>(
      () => _i5.MenuLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i6.IOrderRepository>(
      () => _i7.OrderLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i8.OrderStateNotifier>(
      () => _i8.OrderStateNotifier(get<_i6.IOrderRepository>()));
  return get;
}
