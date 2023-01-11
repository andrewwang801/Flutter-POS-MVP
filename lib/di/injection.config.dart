// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../auth/provider/auth_controller.dart' as _i28;
import '../auth/repository/i_operator_repository.dart' as _i15;
import '../auth/repository/operator_local_repository.dart' as _i16;
import '../common/global_config_repository.dart' as _i12;
import '../common/helper/db_helper.dart' as _i3;
import '../common/services/printer_manager.dart' as _i5;
import '../common/services/xprinter_service.dart' as _i27;
import '../discount/application/discount_controller.dart' as _i29;
import '../discount/domain/discount_repository.dart' as _i10;
import '../floor_plan/provider/table_controller.dart' as _i39;
import '../floor_plan/repository/i_tablemangement_repository.dart' as _i23;
import '../floor_plan/repository/local_tablemanagement_repository.dart' as _i24;
import '../functions/application/function_controller.dart' as _i31;
import '../functions/domain/function_local_repository.dart' as _i11;
import '../home/model/prep/prep_model.dart' as _i4;
import '../home/provider/order/order_state_notifier.dart' as _i30;
import '../home/provider/plu_details/plu_state_notifier.dart' as _i35;
import '../home/repository/menu/i_menu_repository.dart' as _i13;
import '../home/repository/menu/menu_local_repository.dart' as _i14;
import '../home/repository/order/i_order_repository.dart' as _i32;
import '../home/repository/order/order_local_repository.dart' as _i33;
import '../payment/provider/payment_state_notifier.dart' as _i36;
import '../payment/repository/i_payment_repository.dart' as _i17;
import '../payment/repository/payment_local_repository.dart' as _i18;
import '../print/provider/print_controller.dart' as _i8;
import '../print/repository/i_print_repository.dart' as _i19;
import '../print/repository/print_local_repository.dart' as _i20;
import '../printer/provider/printer_state_notifier.dart' as _i25;
import '../printer/repository/i_printer_repository.dart' as _i21;
import '../printer/repository/printer_local_repository.dart' as _i22;
import '../promo/application/promo_controller.dart' as _i42;
import '../promo/domain/promotion_local_repository.dart' as _i37;
import '../sales_report/application/sales_report_controller.dart' as _i7;
import '../trans/application/kitchen_reprint_controller.dart' as _i34;
import '../trans/application/refund_controller.dart' as _i38;
import '../trans/application/trans_controller.dart' as _i40;
import '../trans/application/trans_detail_controller.dart' as _i41;
import '../trans/domain/trans_local_repository.dart' as _i26;
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
  gh.factory<_i17.IPaymentRepository>(
      () => _i18.PaymentLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i19.IPrintRepository>(
      () => _i20.PrintLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i21.IPrinterRepository>(
      () => _i22.PrinterLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i23.ITableMangementRepository>(
      () => _i24.LocalTableManagementRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i8.PrintController>(() => _i8.PrintController(
      get<_i19.IPrintRepository>(),
      get<_i17.IPaymentRepository>(),
      get<_i5.PrinterManager>()));
  gh.factory<_i25.PrinterStateNotifier>(() => _i25.PrinterStateNotifier(
      get<_i21.IPrinterRepository>(), get<_i5.PrinterManager>()));
  gh.factory<_i26.TransLocalRepository>(() => _i26.TransLocalRepository(
      get<_i3.LocalDBHelper>(), get<_i23.ITableMangementRepository>()));
  gh.factory<_i27.XPrinterService>(() =>
      _i27.XPrinterService(paymentRepository: get<_i17.IPaymentRepository>()));
  gh.factory<_i28.AuthController>(
      () => _i28.AuthController(get<_i15.IOperatorRepository>()));
  gh.factoryParam<_i29.DiscountController, _i30.OrderStateNotifier, dynamic>(
      (orderController, _) => _i29.DiscountController(
          get<_i10.DiscountRepository>(),
          orderController: orderController));
  gh.factoryParam<_i31.FunctionController, _i30.OrderStateNotifier, dynamic>(
      (orderController, _) => _i31.FunctionController(
          get<_i11.FunctionLocalRepository>(),
          orderController: orderController));
  gh.factory<_i32.IOrderRepository>(() => _i33.OrderLocalRepository(
      get<_i17.IPaymentRepository>(),
      database: get<_i3.LocalDBHelper>()));
  gh.factoryParam<_i34.KitchenReprintController, _i8.PrintController, dynamic>(
      (printController, _) => _i34.KitchenReprintController(
          get<_i26.TransLocalRepository>(),
          printController: printController));
  gh.factoryParam<_i30.OrderStateNotifier, _i8.PrintController, dynamic>(
      (printController, _) => _i30.OrderStateNotifier(
          get<_i32.IOrderRepository>(),
          get<_i17.IPaymentRepository>(),
          get<_i10.DiscountRepository>(),
          get<_i19.IPrintRepository>(),
          printController: printController));
  gh.factory<_i35.PLUStateNotifier>(() => _i35.PLUStateNotifier(
      get<_i13.IMenuRepository>(), get<_i32.IOrderRepository>()));
  gh.factory<_i36.PaymentStateNotifer>(() => _i36.PaymentStateNotifer(
      get<_i17.IPaymentRepository>(), get<_i32.IOrderRepository>()));
  gh.factory<_i37.PromotionLocalRepository>(() => _i37.PromotionLocalRepository(
      get<_i3.LocalDBHelper>(), get<_i32.IOrderRepository>()));
  gh.factoryParam<_i38.RefundController, _i8.PrintController, dynamic>(
      (printController, _) => _i38.RefundController(
          get<_i26.TransLocalRepository>(),
          printController: printController));
  gh.factoryParam<_i39.TableController, _i8.PrintController, dynamic>(
      (printController, _) => _i39.TableController(
          get<_i23.ITableMangementRepository>(),
          get<_i32.IOrderRepository>(),
          get<_i17.IPaymentRepository>(),
          get<_i19.IPrintRepository>(),
          printController: printController));
  gh.factoryParam<_i40.TransController, _i8.PrintController, dynamic>(
      (printController, _) => _i40.TransController(
          get<_i26.TransLocalRepository>(),
          get<_i32.IOrderRepository>(),
          get<_i17.IPaymentRepository>(),
          printController: printController));
  gh.factory<_i41.TransDetailController>(
      () => _i41.TransDetailController(get<_i26.TransLocalRepository>()));
  gh.factory<_i42.PromotController>(
      () => _i42.PromotController(get<_i37.PromotionLocalRepository>()));
  return get;
}
