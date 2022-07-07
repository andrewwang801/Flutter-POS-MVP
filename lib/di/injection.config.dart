// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../common/helper/db_helper.dart' as _i3;
import '../home/model/prep/prep_model.dart' as _i4;
import '../home/provider/order/order_state_notifier.dart' as _i13;
import '../home/provider/plu_details/plu_state_notifier.dart' as _i14;
import '../home/repository/menu/i_menu_repository.dart' as _i5;
import '../home/repository/menu/menu_local_repository.dart' as _i6;
import '../home/repository/order/i_order_repository.dart' as _i7;
import '../home/repository/order/order_local_repository.dart' as _i8;
import '../payment/provider/payment_state_notifier.dart' as _i15;
import '../payment/repository/i_payment_repository.dart' as _i9;
import '../payment/repository/payment_local_repository.dart' as _i10;
import '../printer/provider/printer_state_notifier.dart' as _i16;
import '../printer/repository/i_printer_repository.dart' as _i11;
import '../printer/repository/printer_local_repository.dart'
    as _i12; // ignore_for_file: unnecessary_lambdas

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
  gh.factory<_i9.IPaymentRepository>(
      () => _i10.PaymentLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i11.IPrinterRepository>(
      () => _i12.PrinterLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i13.OrderStateNotifier>(() => _i13.OrderStateNotifier(
      get<_i7.IOrderRepository>(), get<_i9.IPaymentRepository>()));
  gh.factory<_i14.PLUStateNotifier>(() => _i14.PLUStateNotifier(
      get<_i5.IMenuRepository>(), get<_i7.IOrderRepository>()));
  gh.factory<_i15.PaymentStateNotifer>(
      () => _i15.PaymentStateNotifer(get<_i9.IPaymentRepository>()));
  gh.factory<_i16.PrinterStateNotifier>(
      () => _i16.PrinterStateNotifier(get<_i11.IPrinterRepository>()));
  return get;
}
