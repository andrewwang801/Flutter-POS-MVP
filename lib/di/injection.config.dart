// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../auth/provider/auth_controller.dart' as _i35;
import '../auth/repository/i_operator_repository.dart' as _i15;
import '../auth/repository/operator_local_repository.dart' as _i16;
import '../common/global_config_repository.dart' as _i12;
import '../common/helper/db_helper.dart' as _i3;
import '../common/services/printer_manager.dart' as _i5;
import '../common/services/xprinter_service.dart' as _i34;
import '../discount/repository/discount_repository.dart' as _i10;
import '../floor_plan/provider/table_controller.dart' as _i32;
import '../floor_plan/repository/i_tablemangement_repository.dart' as _i25;
import '../floor_plan/repository/local_tablemanagement_repository.dart' as _i26;
import '../functions/application/function_controller.dart' as _i36;
import '../functions/domain/function_local_repository.dart' as _i11;
import '../home/model/prep/prep_model.dart' as _i4;
import '../home/provider/order/order_state_notifier.dart' as _i27;
import '../home/provider/plu_details/plu_state_notifier.dart' as _i28;
import '../home/repository/menu/i_menu_repository.dart' as _i13;
import '../home/repository/menu/menu_local_repository.dart' as _i14;
import '../home/repository/order/i_order_repository.dart' as _i17;
import '../home/repository/order/order_local_repository.dart' as _i18;
import '../payment/provider/payment_state_notifier.dart' as _i29;
import '../payment/repository/i_payment_repository.dart' as _i19;
import '../payment/repository/payment_local_repository.dart' as _i20;
import '../print/provider/print_controller.dart' as _i8;
import '../print/repository/i_print_repository.dart' as _i21;
import '../print/repository/print_local_repository.dart' as _i22;
import '../printer/provider/printer_state_notifier.dart' as _i30;
import '../printer/repository/i_printer_repository.dart' as _i23;
import '../printer/repository/printer_local_repository.dart' as _i24;
import '../promo/application/promo_controller.dart' as _i38;
import '../promo/domain/promotion_local_repository.dart' as _i31;
import '../sales_report/application/sales_report_controller.dart' as _i7;
import '../trans/application/kitchen_reprint_controller.dart' as _i37;
import '../trans/application/refund_controller.dart' as _i39;
import '../trans/application/trans_controller.dart' as _i40;
import '../trans/application/trans_detail_controller.dart' as _i41;
import '../trans/domain/trans_local_repository.dart' as _i33;
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
  gh.factory<_i10.DiscountRepository>(
      () => _i10.DiscountRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i11.FunctionLocalRepository>(
      () => _i11.FunctionLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i12.GlobalConfigRepository>(
      () => _i12.GlobalConfigRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i13.IMenuRepository>(
      () => _i14.MenuLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i15.IOperatorRepository>(
      () => _i16.OperatorLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i17.IOrderRepository>(
      () => _i18.OrderLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i19.IPaymentRepository>(
      () => _i20.PaymentLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i21.IPrintRepository>(
      () => _i22.PrintLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i23.IPrinterRepository>(
      () => _i24.PrinterLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i25.ITableMangementRepository>(
      () => _i26.LocalTableManagementRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i27.OrderStateNotifier>(() => _i27.OrderStateNotifier(
      get<_i17.IOrderRepository>(),
      get<_i19.IPaymentRepository>(),
      get<_i10.DiscountRepository>()));
  gh.factory<_i28.PLUStateNotifier>(() => _i28.PLUStateNotifier(
      get<_i13.IMenuRepository>(), get<_i17.IOrderRepository>()));
  gh.factory<_i29.PaymentStateNotifer>(() => _i29.PaymentStateNotifer(
      get<_i19.IPaymentRepository>(), get<_i17.IOrderRepository>()));
  gh.factory<_i8.PrintController>(() => _i8.PrintController(
      get<_i21.IPrintRepository>(),
      get<_i19.IPaymentRepository>(),
      get<_i5.PrinterManager>()));
  gh.factory<_i30.PrinterStateNotifier>(() => _i30.PrinterStateNotifier(
      get<_i23.IPrinterRepository>(), get<_i5.PrinterManager>()));
  gh.factory<_i31.PromotionLocalRepository>(() => _i31.PromotionLocalRepository(
      get<_i3.LocalDBHelper>(), get<_i17.IOrderRepository>()));
  gh.factory<_i32.TableController>(() => _i32.TableController(
      get<_i25.ITableMangementRepository>(), get<_i17.IOrderRepository>()));
  gh.factory<_i33.TransLocalRepository>(() => _i33.TransLocalRepository(
      get<_i3.LocalDBHelper>(), get<_i25.ITableMangementRepository>()));
  gh.factory<_i34.XPrinterService>(() =>
      _i34.XPrinterService(paymentRepository: get<_i19.IPaymentRepository>()));
  gh.factory<_i35.AuthController>(
      () => _i35.AuthController(get<_i15.IOperatorRepository>()));
  gh.factory<_i36.FunctionController>(
      () => _i36.FunctionController(get<_i11.FunctionLocalRepository>()));
  gh.factoryParam<_i37.KitchenReprintController, _i8.PrintController, dynamic>(
      (printController, _) => _i37.KitchenReprintController(
          get<_i33.TransLocalRepository>(),
          printController: printController));
  gh.factory<_i38.PromotController>(
      () => _i38.PromotController(get<_i31.PromotionLocalRepository>()));
  gh.factoryParam<_i39.RefundController, _i8.PrintController, dynamic>(
      (printController, _) => _i39.RefundController(
          get<_i33.TransLocalRepository>(),
          printController: printController));
  gh.factoryParam<_i40.TransController, _i8.PrintController, dynamic>(
      (printController, _) => _i40.TransController(
          get<_i33.TransLocalRepository>(),
          get<_i17.IOrderRepository>(),
          get<_i19.IPaymentRepository>(),
          printController: printController));
  gh.factory<_i41.TransDetailController>(
      () => _i41.TransDetailController(get<_i33.TransLocalRepository>()));
  return get;
}
