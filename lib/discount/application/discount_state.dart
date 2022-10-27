// common part
import 'package:equatable/equatable.dart';
import 'package:raptorpos/discount/model/discount_model.dart';

import '../../common/extension/workable.dart';

class Failiure {
  Failiure({required this.errMsg});

  final String errMsg;
}
//end of common part

// data class
class DiscountData {
  DiscountData(this.discs);

  final List<DiscountModel> discs;
}

// state
class DiscountState extends Equatable {
  DiscountState({this.failiure, this.workable, this.data});

  final DiscountData? data;
  final Failiure? failiure;
  final Workable? workable;

  @override
  List<Object?> get props => [workable, failiure];

  DiscountState copyWith(
      {Failiure? failiure, Workable? workable, DiscountData? data}) {
    return DiscountState(
        failiure: failiure ?? this.failiure,
        workable: workable ?? this.workable,
        data: data ?? this.data);
  }
}
