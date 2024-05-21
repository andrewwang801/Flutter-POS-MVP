import 'package:equatable/equatable.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/model/prep/prep_model.dart';

abstract class PLUState extends Equatable {}

class PLUInitialState extends PLUState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class PLULoadingState extends PLUState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class PLUSuccessState extends PLUState {
  final Map<String, Map<String, String>> prepSelect;
  final List<String> pluDetails;
  final OrderItemModel? orderSelect;
  final OrderItemModel? modSelect;
  final List<OrderItemModel> prepOrderItems;
  final List<PrepModel> preps;

  PLUSuccessState(this.prepSelect, this.pluDetails, this.orderSelect,
      this.modSelect, this.prepOrderItems, this.preps);

  @override
  List<Object?> get props => [];
}

class PLUErrorState extends PLUState {
  final String errMsg;

  PLUErrorState(this.errMsg);

  @override
  List<Object?> get props => throw UnimplementedError();
}
