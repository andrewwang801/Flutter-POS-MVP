// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../common/helper/db_helper.dart' as _i3;
import '../home/model/prep/prep_model.dart' as _i4;
import '../home/provider/order/order_state_notifier.dart' as _i9;
import '../home/provider/plu_details/plu_state_notifier.dart' as _i10;
import '../home/repository/menu/i_menu_repository.dart' as _i5;
import '../home/repository/menu/menu_local_repository.dart' as _i6;
import '../home/repository/order/i_order_repository.dart' as _i7;
import '../home/repository/order/order_local_repository.dart'
    as _i8; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.singleton<_i3.LocalDBHelper>(_i3.LocalDBHelper());
  gh.factory<_i4.PrepModel>(() => _i4.PrepModel(get<String>(), get<String>()));
  gh.factory<_i5.IMenuRepository>(
      () => _i6.MenuLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i7.IOrderRepository>(
      () => _i8.OrderLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i9.OrderStateNotifier>(
      () => _i9.OrderStateNotifier(get<_i7.IOrderRepository>()));
  gh.factory<_i10.PLUStateNotifier>(() => _i10.PLUStateNotifier(
      get<_i5.IMenuRepository>(), get<_i7.IOrderRepository>()));
  return get;
}
