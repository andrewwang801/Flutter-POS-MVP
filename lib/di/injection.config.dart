// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../auth/provider/auth_controller.dart' as _i27;
import '../auth/repository/i_operator_repository.dart' as _i8;
import '../auth/repository/operator_local_repository.dart' as _i9;
import '../common/helper/db_helper.dart' as _i3;
import '../common/services/printer_manager.dart' as _i5;
import '../common/services/xprinter_service.dart' as _i26;
import '../floor_plan/provider/table_controller.dart' as _i25;
import '../floor_plan/repository/i_tablemangement_repository.dart' as _i18;
import '../floor_plan/repository/local_tablemanagement_repository.dart' as _i19;
import '../home/model/prep/prep_model.dart' as _i4;
import '../home/provider/order/order_state_notifier.dart' as _i20;
import '../home/provider/plu_details/plu_state_notifier.dart' as _i21;
import '../home/repository/menu/i_menu_repository.dart' as _i6;
import '../home/repository/menu/menu_local_repository.dart' as _i7;
import '../home/repository/order/i_order_repository.dart' as _i10;
import '../home/repository/order/order_local_repository.dart' as _i11;
import '../payment/provider/payment_state_notifier.dart' as _i22;
import '../payment/repository/i_payment_repository.dart' as _i12;
import '../payment/repository/payment_local_repository.dart' as _i13;
import '../print/provider/print_controller.dart' as _i23;
import '../print/repository/i_print_repository.dart' as _i14;
import '../print/repository/print_local_repository.dart' as _i15;
import '../printer/provider/printer_state_notifier.dart' as _i24;
import '../printer/repository/i_printer_repository.dart' as _i16;
import '../printer/repository/printer_local_repository.dart'
    as _i17; // ignore_for_file: unnecessary_lambdas

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
  gh.factory<_i8.IOperatorRepository>(
      () => _i9.OperatorLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i10.IOrderRepository>(
      () => _i11.OrderLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i12.IPaymentRepository>(
      () => _i13.PaymentLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i14.IPrintRepository>(
      () => _i15.PrintLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i16.IPrinterRepository>(
      () => _i17.PrinterLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i18.ITableMangementRepository>(
      () => _i19.LocalTableManagementRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i20.OrderStateNotifier>(() => _i20.OrderStateNotifier(
      get<_i10.IOrderRepository>(), get<_i12.IPaymentRepository>()));
  gh.factory<_i21.PLUStateNotifier>(() => _i21.PLUStateNotifier(
      get<_i6.IMenuRepository>(), get<_i10.IOrderRepository>()));
  gh.factory<_i22.PaymentStateNotifer>(() => _i22.PaymentStateNotifer(
      get<_i12.IPaymentRepository>(), get<_i10.IOrderRepository>()));
  gh.factory<_i23.PrintController>(() => _i23.PrintController(
      get<_i14.IPrintRepository>(),
      get<_i12.IPaymentRepository>(),
      get<_i5.PrinterManager>()));
  gh.factory<_i24.PrinterStateNotifier>(() => _i24.PrinterStateNotifier(
      get<_i16.IPrinterRepository>(), get<_i5.PrinterManager>()));
  gh.factory<_i25.TableController>(() => _i25.TableController(
      get<_i18.ITableMangementRepository>(), get<_i10.IOrderRepository>()));
  gh.factory<_i26.XPrinterService>(() =>
      _i26.XPrinterService(paymentRepository: get<_i12.IPaymentRepository>()));
  gh.factory<_i27.AuthController>(
      () => _i27.AuthController(get<_i8.IOperatorRepository>()));
  return get;
}
