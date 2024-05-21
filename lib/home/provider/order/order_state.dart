import 'package:equatable/equatable.dart';
import 'package:raptorpos/home/model/order_item_model.dart';

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

  OrderSuccessState(this.orderItems, this.bills);
  @override
  List<Object?> get props => [orderItems];
}

class OrderErrorState extends OrderState {
  final String errMsg;

  OrderErrorState({required this.errMsg});
  @override
  List<Object?> get props => [errMsg];
}
