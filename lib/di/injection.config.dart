// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../auth/provider/auth_controller.dart' as _i32;
import '../auth/repository/i_operator_repository.dart' as _i11;
import '../auth/repository/operator_local_repository.dart' as _i12;
import '../common/global_config_repository.dart' as _i8;
import '../common/helper/db_helper.dart' as _i3;
import '../common/services/printer_manager.dart' as _i5;
import '../common/services/xprinter_service.dart' as _i31;
import '../floor_plan/provider/table_controller.dart' as _i29;
import '../floor_plan/repository/i_tablemangement_repository.dart' as _i21;
import '../floor_plan/repository/local_tablemanagement_repository.dart' as _i22;
import '../functions/application/function_controller.dart' as _i33;
import '../functions/domain/function_local_repository.dart' as _i7;
import '../home/model/prep/prep_model.dart' as _i4;
import '../home/provider/order/order_state_notifier.dart' as _i23;
import '../home/provider/plu_details/plu_state_notifier.dart' as _i24;
import '../home/repository/menu/i_menu_repository.dart' as _i9;
import '../home/repository/menu/menu_local_repository.dart' as _i10;
import '../home/repository/order/i_order_repository.dart' as _i13;
import '../home/repository/order/order_local_repository.dart' as _i14;
import '../payment/provider/payment_state_notifier.dart' as _i25;
import '../payment/repository/i_payment_repository.dart' as _i15;
import '../payment/repository/payment_local_repository.dart' as _i16;
import '../print/provider/print_controller.dart' as _i26;
import '../print/repository/i_print_repository.dart' as _i17;
import '../print/repository/print_local_repository.dart' as _i18;
import '../printer/provider/printer_state_notifier.dart' as _i27;
import '../printer/repository/i_printer_repository.dart' as _i19;
import '../printer/repository/printer_local_repository.dart' as _i20;
import '../promo/application/promo_controller.dart' as _i35;
import '../promo/domain/promotion_local_repository.dart' as _i28;
import '../trans/application/kitchen_reprint_controller.dart' as _i34;
import '../trans/application/refund_controller.dart' as _i36;
import '../trans/application/trans_controller.dart' as _i37;
import '../trans/application/trans_detail_controller.dart' as _i38;
import '../trans/domain/trans_local_repository.dart' as _i30;
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
  gh.factory<_i7.FunctionLocalRepository>(
      () => _i7.FunctionLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i8.GlobalConfigRepository>(
      () => _i8.GlobalConfigRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i9.IMenuRepository>(
      () => _i10.MenuLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i11.IOperatorRepository>(
      () => _i12.OperatorLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i13.IOrderRepository>(
      () => _i14.OrderLocalRepository(database: get<_i3.LocalDBHelper>()));
  gh.factory<_i15.IPaymentRepository>(
      () => _i16.PaymentLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i17.IPrintRepository>(
      () => _i18.PrintLocalRepository(dbHelper: get<_i3.LocalDBHelper>()));
  gh.factory<_i19.IPrinterRepository>(
      () => _i20.PrinterLocalRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i21.ITableMangementRepository>(
      () => _i22.LocalTableManagementRepository(get<_i3.LocalDBHelper>()));
  gh.factory<_i23.OrderStateNotifier>(() => _i23.OrderStateNotifier(
      get<_i13.IOrderRepository>(), get<_i15.IPaymentRepository>()));
  gh.factory<_i24.PLUStateNotifier>(() => _i24.PLUStateNotifier(
      get<_i9.IMenuRepository>(), get<_i13.IOrderRepository>()));
  gh.factory<_i25.PaymentStateNotifer>(() => _i25.PaymentStateNotifer(
      get<_i15.IPaymentRepository>(), get<_i13.IOrderRepository>()));
  gh.factory<_i26.PrintController>(() => _i26.PrintController(
      get<_i17.IPrintRepository>(),
      get<_i15.IPaymentRepository>(),
      get<_i5.PrinterManager>()));
  gh.factory<_i27.PrinterStateNotifier>(() => _i27.PrinterStateNotifier(
      get<_i19.IPrinterRepository>(), get<_i5.PrinterManager>()));
  gh.factory<_i28.PromotionLocalRepository>(() => _i28.PromotionLocalRepository(
      get<_i3.LocalDBHelper>(), get<_i13.IOrderRepository>()));
  gh.factory<_i29.TableController>(() => _i29.TableController(
      get<_i21.ITableMangementRepository>(), get<_i13.IOrderRepository>()));
  gh.factory<_i30.TransLocalRepository>(() => _i30.TransLocalRepository(
      get<_i3.LocalDBHelper>(), get<_i21.ITableMangementRepository>()));
  gh.factory<_i31.XPrinterService>(() =>
      _i31.XPrinterService(paymentRepository: get<_i15.IPaymentRepository>()));
  gh.factory<_i32.AuthController>(
      () => _i32.AuthController(get<_i11.IOperatorRepository>()));
  gh.factory<_i33.FunctionController>(
      () => _i33.FunctionController(get<_i7.FunctionLocalRepository>()));
  gh.factoryParam<_i34.KitchenReprintController, _i26.PrintController, dynamic>(
      (printController, _) => _i34.KitchenReprintController(
          get<_i30.TransLocalRepository>(),
          printController: printController));
  gh.factory<_i35.PromotController>(
      () => _i35.PromotController(get<_i28.PromotionLocalRepository>()));
  gh.factoryParam<_i36.RefundController, _i26.PrintController, dynamic>(
      (printController, _) => _i36.RefundController(
          get<_i30.TransLocalRepository>(),
          printController: printController));
  gh.factoryParam<_i37.TransController, _i26.PrintController, dynamic>(
      (printController, _) => _i37.TransController(
          get<_i30.TransLocalRepository>(),
          get<_i13.IOrderRepository>(),
          get<_i15.IPaymentRepository>(),
          printController: printController));
  gh.factory<_i38.TransDetailController>(
      () => _i38.TransDetailController(get<_i30.TransLocalRepository>()));
  return get;
}
