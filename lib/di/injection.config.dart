// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../auth/provider/auth_controller.dart' as _i30;
import '../auth/repository/i_operator_repository.dart' as _i10;
import '../auth/repository/operator_local_repository.dart' as _i11;
import '../common/global_config_repository.dart' as _i7;
import '../common/helper/db_helper.dart' as _i3;
import '../common/services/printer_manager.dart' as _i5;
import '../common/services/xprinter_service.dart' as _i29;
import '../floor_plan/provider/table_controller.dart' as _i27;
import '../floor_plan/repository/i_tablemangement_repository.dart' as _i20;
import '../floor_plan/repository/local_tablemanagement_repository.dart' as _i21;
import '../home/model/prep/prep_model.dart' as _i4;
import '../home/provider/order/order_state_notifier.dart' as _i22;
import '../home/provider/plu_details/plu_state_notifier.dart' as _i23;
import '../home/repository/menu/i_menu_repository.dart' as _i8;
import '../home/repository/menu/menu_local_repository.dart' as _i9;
import '../home/repository/order/i_order_repository.dart' as _i12;
import '../home/repository/order/order_local_repository.dart' as _i13;
import '../payment/provider/payment_state_notifier.dart' as _i24;
import '../payment/repository/i_payment_repository.dart' as _i14;
import '../payment/repository/payment_local_repository.dart' as _i15;
import '../print/provider/print_controller.dart' as _i25;
import '../print/repository/i_print_repository.dart' as _i16;
import '../print/repository/print_local_repository.dart' as _i17;
import '../printer/provider/printer_state_notifier.dart' as _i26;
import '../printer/repository/i_printer_repository.dart' as _i18;
import '../printer/repository/printer_local_repository.dart' as _i19;
import '../trans/application/kitchen_reprint_controller.dart' as _i31;
import '../trans/application/refund_controller.dart' as _i32;
import '../trans/application/trans_controller.dart' as _i33;
import '../trans/domain/trans_local_repository.dart' as _i28;
import '../zday_report/domain/report_local_repository.dart'
    as _i6; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.singleton<_i3.LocalDBHelper>(_i3.LocalDBHelper());
  gh.factory<_i4.PrepModel>(() => _i4.PrepModel(get<String>(), get<String>()));
  gh.singleton<_i5.PrinterManager>(_i5.PrinterManager());
  gh.factory<_i6.ReportLocalRepository>(
      () => _i6.ReportLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i7.GlobalConfigRepository>(
      () => _i7.GlobalConfigRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i8.IMenuRepository>(
      () => _i9.MenuLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i10.IOperatorRepository>(
      () => _i11.OperatorLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i12.IOrderRepository>(
      () => _i13.OrderLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i14.IPaymentRepository>(
      () => _i15.PaymentLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i16.IPrintRepository>(
      () => _i17.PrintLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i18.IPrinterRepository>(
      () => _i19.PrinterLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i20.ITableMangementRepository>(
      () => _i21.LocalTableManagementRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i22.OrderStateNotifier>(() => _i22.OrderStateNotifier(
      get<_i12.IOrderRepository>(), get<_i14.IPaymentRepository>()));
  gh.factory<_i23.PLUStateNotifier>(() => _i23.PLUStateNotifier(
      get<_i8.IMenuRepository>(), get<_i12.IOrderRepository>()));
  gh.factory<_i24.PaymentStateNotifer>(() => _i24.PaymentStateNotifer(
      get<_i14.IPaymentRepository>(), get<_i12.IOrderRepository>()));
  gh.factory<_i25.PrintController>(() => _i25.PrintController(
      get<_i16.IPrintRepository>(),
      get<_i14.IPaymentRepository>(),
      get<_i5.PrinterManager>()));
  gh.factory<_i26.PrinterStateNotifier>(() => _i26.PrinterStateNotifier(
      get<_i18.IPrinterRepository>(), get<_i5.PrinterManager>()));
  gh.factory<_i27.TableController>(() => _i27.TableController(
      get<_i20.ITableMangementRepository>(), get<_i12.IOrderRepository>()));
  gh.factory<_i28.TransLocalRepository>(() => _i28.TransLocalRepository(
      get<_i3.LocalDBHelper>(), get<_i20.ITableMangementRepository>()));
  gh.factory<_i29.XPrinterService>(() =>
      _i29.XPrinterService(paymentRepository: get<_i14.IPaymentRepository>()));
  gh.factory<_i30.AuthController>(
      () => _i30.AuthController(get<_i10.IOperatorRepository>()));
  gh.factoryParam<_i31.KitchenReprintController, _i25.PrintController, dynamic>(
      (printController, _) => _i31.KitchenReprintController(
          get<_i28.TransLocalRepository>(),
          printController: printController));
  gh.factoryParam<_i32.RefundController, _i25.PrintController, dynamic>(
      (printController, _) => _i32.RefundController(
          get<_i28.TransLocalRepository>(),
          printController: printController));
  gh.factory<_i33.TransController>(
      () => _i33.TransController(get<_i28.TransLocalRepository>()));
  return get;
}
