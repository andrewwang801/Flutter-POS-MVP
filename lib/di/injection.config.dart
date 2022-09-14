// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../auth/provider/auth_controller.dart' as _i34;
import '../auth/repository/i_operator_repository.dart' as _i14;
import '../auth/repository/operator_local_repository.dart' as _i15;
import '../common/global_config_repository.dart' as _i11;
import '../common/helper/db_helper.dart' as _i3;
import '../common/services/printer_manager.dart' as _i5;
import '../common/services/xprinter_service.dart' as _i33;
import '../floor_plan/provider/table_controller.dart' as _i31;
import '../floor_plan/repository/i_tablemangement_repository.dart' as _i24;
import '../floor_plan/repository/local_tablemanagement_repository.dart' as _i25;
import '../functions/application/function_controller.dart' as _i35;
import '../functions/domain/function_local_repository.dart' as _i10;
import '../home/model/prep/prep_model.dart' as _i4;
import '../home/provider/order/order_state_notifier.dart' as _i26;
import '../home/provider/plu_details/plu_state_notifier.dart' as _i27;
import '../home/repository/menu/i_menu_repository.dart' as _i12;
import '../home/repository/menu/menu_local_repository.dart' as _i13;
import '../home/repository/order/i_order_repository.dart' as _i16;
import '../home/repository/order/order_local_repository.dart' as _i17;
import '../payment/provider/payment_state_notifier.dart' as _i28;
import '../payment/repository/i_payment_repository.dart' as _i18;
import '../payment/repository/payment_local_repository.dart' as _i19;
import '../print/provider/print_controller.dart' as _i8;
import '../print/repository/i_print_repository.dart' as _i20;
import '../print/repository/print_local_repository.dart' as _i21;
import '../printer/provider/printer_state_notifier.dart' as _i29;
import '../printer/repository/i_printer_repository.dart' as _i22;
import '../printer/repository/printer_local_repository.dart' as _i23;
import '../promo/application/promo_controller.dart' as _i37;
import '../promo/domain/promotion_local_repository.dart' as _i30;
import '../sales_report/application/sales_report_controller.dart' as _i7;
import '../trans/application/kitchen_reprint_controller.dart' as _i36;
import '../trans/application/refund_controller.dart' as _i38;
import '../trans/application/trans_controller.dart' as _i39;
import '../trans/application/trans_detail_controller.dart' as _i40;
import '../trans/domain/trans_local_repository.dart' as _i32;
import '../zday_report/application/zday_report_controller.dart' as _i9;
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
  gh.factoryParam<_i7.SalesReportController, _i8.PrintController, dynamic>(
      (printController, _) => _i7.SalesReportController(
          get<_i6.ReportLocalRepository>(),
          printController: printController));
  gh.factoryParam<_i9.ZDayReportController, _i8.PrintController, dynamic>(
      (printController, _) => _i9.ZDayReportController(
          get<_i6.ReportLocalRepository>(),
          printController: printController));
  gh.factory<_i10.FunctionLocalRepository>(
      () => _i10.FunctionLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i11.GlobalConfigRepository>(
      () => _i11.GlobalConfigRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i12.IMenuRepository>(
      () => _i13.MenuLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i14.IOperatorRepository>(
      () => _i15.OperatorLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i16.IOrderRepository>(
      () => _i17.OrderLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i18.IPaymentRepository>(
      () => _i19.PaymentLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i20.IPrintRepository>(
      () => _i21.PrintLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i22.IPrinterRepository>(
      () => _i23.PrinterLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i24.ITableMangementRepository>(
      () => _i25.LocalTableManagementRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i26.OrderStateNotifier>(() => _i26.OrderStateNotifier(
      get<_i16.IOrderRepository>(), get<_i18.IPaymentRepository>()));
  gh.factory<_i27.PLUStateNotifier>(() => _i27.PLUStateNotifier(
      get<_i12.IMenuRepository>(), get<_i16.IOrderRepository>()));
  gh.factory<_i28.PaymentStateNotifer>(() => _i28.PaymentStateNotifer(
      get<_i18.IPaymentRepository>(), get<_i16.IOrderRepository>()));
  gh.factory<_i8.PrintController>(() => _i8.PrintController(
      get<_i20.IPrintRepository>(),
      get<_i18.IPaymentRepository>(),
      get<_i5.PrinterManager>()));
  gh.factory<_i29.PrinterStateNotifier>(() => _i29.PrinterStateNotifier(
      get<_i22.IPrinterRepository>(), get<_i5.PrinterManager>()));
  gh.factory<_i30.PromotionLocalRepository>(() => _i30.PromotionLocalRepository(
      get<_i3.LocalDBHelper>(), get<_i16.IOrderRepository>()));
  gh.factory<_i31.TableController>(() => _i31.TableController(
      get<_i24.ITableMangementRepository>(), get<_i16.IOrderRepository>()));
  gh.factory<_i32.TransLocalRepository>(() => _i32.TransLocalRepository(
      get<_i3.LocalDBHelper>(), get<_i24.ITableMangementRepository>()));
  gh.factory<_i33.XPrinterService>(() =>
      _i33.XPrinterService(paymentRepository: get<_i18.IPaymentRepository>()));
  gh.factory<_i34.AuthController>(
      () => _i34.AuthController(get<_i14.IOperatorRepository>()));
  gh.factory<_i35.FunctionController>(
      () => _i35.FunctionController(get<_i10.FunctionLocalRepository>()));
  gh.factoryParam<_i36.KitchenReprintController, _i8.PrintController, dynamic>(
      (printController, _) => _i36.KitchenReprintController(
          get<_i32.TransLocalRepository>(),
          printController: printController));
  gh.factory<_i37.PromotController>(
      () => _i37.PromotController(get<_i30.PromotionLocalRepository>()));
  gh.factoryParam<_i38.RefundController, _i8.PrintController, dynamic>(
      (printController, _) => _i38.RefundController(
          get<_i32.TransLocalRepository>(),
          printController: printController));
  gh.factoryParam<_i39.TransController, _i8.PrintController, dynamic>(
      (printController, _) => _i39.TransController(
          get<_i32.TransLocalRepository>(),
          get<_i16.IOrderRepository>(),
          get<_i18.IPaymentRepository>(),
          printController: printController));
  gh.factory<_i40.TransDetailController>(
      () => _i40.TransDetailController(get<_i32.TransLocalRepository>()));
  return get;
}
