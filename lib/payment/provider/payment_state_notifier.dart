import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/GlobalConfig.dart';
import '../../home/repository/order/i_order_repository.dart';
import '../model/media_data_model.dart';
import '../model/payment_details_data_model.dart';
import '../repository/i_payment_repository.dart';
import 'payment_state.dart';

@Injectable()
class PaymentStateNotifer extends StateNotifier<PaymentState> {
  final IPaymentRepository paymentLocalRepository;
  final IOrderRepository orderRepository;
  PaymentStateNotifer(this.paymentLocalRepository, this.orderRepository)
      : super(PaymentInitialState());

  Future<void> doPayment(int payType, double payment) async {
    try {
      await paymentLocalRepository.paymentItem(
          POSDtls.deviceNo,
          GlobalConfig.operatorNo,
          GlobalConfig.tableNo,
          GlobalConfig.salesNo,
          GlobalConfig.splitNo,
          payType,
          payment,
          '' /*customID */);
      state = PaymentSuccessState(paid: true, status: PaymentStatus.SHOW_ALERT);
    } on Exception catch (_, e) {
      state = PaymentErrorState(msg: e.toString());
    }
  }

  Future<void> updatePaymentStatus(PaymentStatus status) async {
    state = PaymentSuccessState(paid: true, status: PaymentStatus.PAID);
  }

  Future<void> fetchPaymentData(int payTag, int funcID) async {
    try {
      List<MediaData> tenderArray;
      if (payTag == 1)
        tenderArray = await paymentLocalRepository.getMediaByType(
            funcID, GlobalConfig.operatorNo);
      else
        tenderArray = await paymentLocalRepository.getMediaType();
      List<PaymentDetailsData> tenderDetail =
          await paymentLocalRepository.getPaymentDetails(
              GlobalConfig.salesNo, GlobalConfig.splitNo, GlobalConfig.tableNo);
      double paidValue = await paymentLocalRepository.getPaidAmount(
          GlobalConfig.salesNo, GlobalConfig.splitNo, GlobalConfig.tableNo);
      state = PaymentSuccessState(
          paid: false,
          status: PaymentStatus.NONE,
          tenderArray: tenderArray,
          tenderDetail: tenderDetail,
          paidValue: paidValue);
    } catch (e) {
      state = PaymentErrorState(msg: e.toString());
    }
  }

  Future<void> removePayment(PaymentDetailsData data) async {
    try {
      if (state is PaymentSuccessState) {
        PaymentSuccessState prevState = state as PaymentSuccessState;
        if (GlobalConfig.VoidPayments) {
          if (prevState.tenderDetail?.isNotEmpty ?? false) {
            double removePay =
                await paymentLocalRepository.getTotalRemoveAmount(
                    GlobalConfig.salesNo,
                    GlobalConfig.splitNo,
                    GlobalConfig.tableNo,
                    data.salesRef);
            await paymentLocalRepository.doRemovePayment(
              GlobalConfig.salesNo,
              GlobalConfig.splitNo,
              GlobalConfig.tableNo,
              data.salesRef,
            );
          }
          state = prevState.copyWith(status: PaymentStatus.PAYMENT_REMOVED);
        } else {
          state = prevState.copyWith(status: PaymentStatus.PERMISSION_ERROR);
        }
      }
    } catch (e) {
      state = PaymentErrorState(msg: e.toString());
    }
  }
}
