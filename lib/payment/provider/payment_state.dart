import 'package:equatable/equatable.dart';

import '../model/media_data_model.dart';
import '../model/payment_details_data_model.dart';

enum PaymentStatus {
  PAID,
  PAYMENT_REMOVED,
  SEND_RECEIPT,
  CLOSE_RECIPT,
  REPRINT,
  SHOW_ALERT,
  PERMISSION_ERROR,
  NONE
}

abstract class PaymentState extends Equatable {}

class PaymentInitialState extends PaymentState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class PaymentLoadingState extends PaymentState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class PaymentSuccessState extends PaymentState {
  PaymentSuccessState(
      {this.paid,
      this.status,
      this.tenderArray,
      this.tenderDetail,
      this.paidValue});

  final bool? paid;
  final PaymentStatus? status;

  final List<MediaData>? tenderArray;
  final List<PaymentDetailsData>? tenderDetail;
  final double? paidValue;
  @override
  List<Object?> get props => [this.paid];

  PaymentSuccessState copyWith(
      {bool? paid,
      PaymentStatus? status,
      List<MediaData>? tenderArray,
      List<PaymentDetailsData>? tenderDetail,
      double? paidValue}) {
    return PaymentSuccessState(
        paid: paid ?? this.paid,
        status: status ?? this.status,
        tenderArray: tenderArray ?? this.tenderArray,
        tenderDetail: tenderDetail ?? this.tenderDetail,
        paidValue: paidValue ?? this.paidValue);
  }
}

class PaymentErrorState extends PaymentState {
  PaymentErrorState({required this.msg});

  final String msg;
  @override
  List<Object?> get props => throw UnimplementedError();
}
