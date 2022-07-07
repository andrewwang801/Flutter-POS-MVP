import 'package:equatable/equatable.dart';

import '../model/media_data_model.dart';
import '../model/payment_details_data_model.dart';

enum PaymentStatus {
  PAID,
  SEND_RECEIPT,
  CLOSE_RECIPT,
  REPRINT,
  SHOW_ALERT,
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
      {required this.paid,
      required this.status,
      this.tenderArray,
      this.tenderDetail,
      this.paidValue});

  final bool paid;
  final PaymentStatus status;

  final List<MediaData>? tenderArray;
  final List<PaymentDetailsData>? tenderDetail;
  final double? paidValue;
  @override
  List<Object?> get props => [this.paid];
}

class PaymentErrorState extends PaymentState {
  PaymentErrorState({required this.msg});

  final String msg;
  @override
  List<Object?> get props => throw UnimplementedError();
}
