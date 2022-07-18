import 'package:equatable/equatable.dart';
import 'package:raptorpos/home/model/order_item_model.dart';

import '../../../common/widgets/orderitem_widget.dart';

abstract class OrderState extends Equatable {}

class OrderInitialState extends OrderState {
  @override
  List<Object?> get props => [];
}

class OrderLoadingState extends OrderState {
  @override
  List<Object?> get props => [];
}

class OrderSuccessState extends OrderState {
  final List<OrderItemModel> orderItems;
  final List<double> bills;
  final bool? paymentPermission;
  final List<ParentOrderItemWidget>? orderItemTree;

  OrderSuccessState(this.orderItems, this.bills,
      [this.paymentPermission, this.orderItemTree]);
  @override
  List<Object?> get props => [orderItems];

  OrderSuccessState copyWith({
    List<OrderItemModel>? orderItems,
    List<double>? bills,
    bool? paymentPermission,
    List<ParentOrderItemWidget>? orderItemTree,
  }) {
    return OrderSuccessState(
      orderItems ?? this.orderItems,
      bills ?? this.bills,
      paymentPermission ?? this.paymentPermission,
      orderItemTree ?? this.orderItemTree,
    );
  }
}

class OrderErrorState extends OrderState {
  final String errMsg;

  OrderErrorState({required this.errMsg});
  @override
  List<Object?> get props => [errMsg];
}
