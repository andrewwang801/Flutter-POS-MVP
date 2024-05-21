import 'package:equatable/equatable.dart';
import 'package:raptorpos/home/model/order_item_model.dart';

import '../../../common/extension/workable.dart';
import '../../../common/widgets/orderitem_widget.dart';
import '../../../sales_report/application/sales_report_state.dart';

class OrderState extends Equatable {
  final List<OrderItemModel>? orderItems;
  final List<double>? bills;
  final bool? paymentPermission;
  final List<ParentOrderItemWidget>? orderItemTree;
  final OPERATIONS? operation;
  final List<List<String>>? remarks;

  final Failure? failure;
  final Workable? workable;

  @override
  List<Object?> get props => [orderItems];

  OrderState(
      [this.orderItems,
      this.bills,
      this.failure,
      this.workable,
      this.paymentPermission,
      this.orderItemTree,
      this.operation = OPERATIONS.NONE,
      this.remarks]);

  OrderState copyWith({
    List<OrderItemModel>? orderItems,
    List<double>? bills,
    bool? paymentPermission,
    List<ParentOrderItemWidget>? orderItemTree,
    OPERATIONS? operation,
    List<List<String>>? remarks,
    Failure? failure,
    Workable? workable,
  }) {
    return OrderState(
      orderItems ?? this.orderItems,
      bills ?? this.bills,
      failure ?? this.failure,
      workable ?? this.workable,
      paymentPermission ?? this.paymentPermission,
      orderItemTree ?? this.orderItemTree,
      operation ?? this.operation,
      remarks ?? this.remarks,
    );
  }
}

enum OPERATIONS {
  NONE,
  NOTIFICATION,
  SHOW_REMARKS,
  SHOW_TABLE_NUM,
  SHOW_TABLE_MANAGEMENT,
  SHOW_KEYBOARD,
}
