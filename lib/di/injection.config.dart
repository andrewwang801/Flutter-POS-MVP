// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../common/helper/db_helper.dart' as _i3;
import '../common/services/printer_manager.dart' as _i5;
import '../common/services/xprinter_service.dart' as _i24;
import '../floor_plan/provider/table_controller.dart' as _i23;
import '../floor_plan/repository/i_tablemangement_repository.dart' as _i16;
import '../floor_plan/repository/local_tablemanagement_repository.dart' as _i17;
import '../home/model/prep/prep_model.dart' as _i4;
import '../home/provider/order/order_state_notifier.dart' as _i18;
import '../home/provider/plu_details/plu_state_notifier.dart' as _i19;
import '../home/repository/menu/i_menu_repository.dart' as _i6;
import '../home/repository/menu/menu_local_repository.dart' as _i7;
import '../home/repository/order/i_order_repository.dart' as _i8;
import '../home/repository/order/order_local_repository.dart' as _i9;
import '../payment/provider/payment_state_notifier.dart' as _i20;
import '../payment/repository/i_payment_repository.dart' as _i10;
import '../payment/repository/payment_local_repository.dart' as _i11;
import '../print/provider/print_controller.dart' as _i21;
import '../print/repository/i_print_repository.dart' as _i12;
import '../print/repository/print_local_repository.dart' as _i13;
import '../printer/provider/printer_state_notifier.dart' as _i22;
import '../printer/repository/i_printer_repository.dart' as _i14;
import '../printer/repository/printer_local_repository.dart'
    as _i15; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.singleton<_i3.LocalDBHelper>(_i3.LocalDBHelper());
  gh.factory<_i4.PrepModel>(() => _i4.PrepModel(get<String>(), get<String>()));
  gh.singleton<_i5.PrinterManager>(_i5.PrinterManager());
  gh.factory<_i6.IMenuRepository>(
      () => _i7.MenuLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i8.IOrderRepository>(
      () => _i9.OrderLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i10.IPaymentRepository>(
      () => _i11.PaymentLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i12.IPrintRepository>(
      () => _i13.PrintLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i14.IPrinterRepository>(
      () => _i15.PrinterLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i16.ITableMangementRepository>(
      () => _i17.LocalTableManagementRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i18.OrderStateNotifier>(() => _i18.OrderStateNotifier(
      get<_i8.IOrderRepository>(), get<_i10.IPaymentRepository>()));
  gh.factory<_i19.PLUStateNotifier>(() => _i19.PLUStateNotifier(
      get<_i6.IMenuRepository>(), get<_i8.IOrderRepository>()));
  gh.factory<_i20.PaymentStateNotifer>(
      () => _i20.PaymentStateNotifer(get<_i10.IPaymentRepository>()));
  gh.factory<_i21.PrintController>(() => _i21.PrintController(
      get<_i12.IPrintRepository>(),
      get<_i10.IPaymentRepository>(),
      get<_i5.PrinterManager>()));
  gh.factory<_i22.PrinterStateNotifier>(() => _i22.PrinterStateNotifier(
      get<_i14.IPrinterRepository>(), get<_i5.PrinterManager>()));
  gh.factory<_i23.TableController>(() => _i23.TableController(
      get<_i16.ITableMangementRepository>(), get<_i8.IOrderRepository>()));
  gh.factory<_i24.XPrinterService>(() =>
      _i24.XPrinterService(paymentRepository: get<_i10.IPaymentRepository>()));
  return get;
}
