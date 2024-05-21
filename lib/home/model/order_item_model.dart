import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_item_model.g.dart';

@JsonSerializable()
class OrderItemModel extends Equatable {
  final String? POSID;
  final int? OperatorNo;
  final int? Covers;
  final String? TableNo;
  final int? SalesNo;
  final int? SplitNo;
  final int? SalesRef;
  final int? PLUSalesRef;
  final int? ItemSeqNo;
  final String? PLUNo;
  final int? Department;
  final String? SDate;
  final String? STime;
  final int? Quantity;
  final String? ItemName;
  final String? ItemName_Chinese;
  final int? ItemAmount;
  final int? PaidAmount;
  final int? ChangeAmount;
  final int? Gratuity;
  final int? Tax0;
  final int? Tax1;
  final int? Tax2;
  final int? Tax3;
  final int? Tax4;
  final int? Tax5;
  final int? Tax6;
  final int? Tax7;
  final int? Tax8;
  final int? Tax9;
  final int? Adjustment;
  final String? DiscountType;
  final String? DiscountPercent;
  final int? Discount;
  final int? PromotionId;
  final String? PromotionType;
  final int? PromotionSaving;
  final String? TransMode;
  final int? RefundID;
  final String? TransStatus;
  final int? FunctionID;
  final int? SubFunctionID;
  final int? MembershipID;
  final String? LoyaltyCardNo;
  final String? CustomerID;
  final String? CardScheme;
  final String? CreditCardNo;
  final double? AvgCost;
  final int? RecipeId;
  final int? PriceShift;
  final int? CategoryId;
  final String? TransferredTable;
  final int? TransferredOp;
  final int? KitchenPrint1;
  final int? KitchenPrint2;
  final int? KitchenPrint3;
  final int? RedemptionItem;
  final int? PointsRedeemed;
  final int? ShiftID;
  final int? PrintFreePrep;
  final int? PrintPrepWithPrice;
  final int? Preparation;
  final int? FOCItem;
  final String? FOCType;
  final int? ApplyTax0;
  final int? ApplyTax1;
  final int? ApplyTax2;
  final int? ApplyTax3;
  final int? ApplyTax4;
  final int? ApplyTax5;
  final int? ApplyTax6;
  final int? ApplyTax7;
  final int? ApplyTax8;
  final int? ApplyTax9;
  final String? LnkTo;
  final int? BuyXfreeYapplied;
  final int? RndingAdjustments;
  final int? Setmenu;
  final int? SetMenuRef;
  final String? Instruction;
  final int? PostSendVoid;
  final int? TblHold;
  final int? DepositID;
  final int? TSalesRef;
  final int? TSalesNo;
  final int? TSplitNo;
  final int? RentalItem;
  final String? RentToDate;
  final String? RentToTime;
  final int? MinsRented;
  final int? SeatNo;
  final String? SalesAreaID;
  final String? BusinessDate;
  final int? ServerNo;
  final int? OperatorFOC;
  final int? OperatornoFirst;
  final String? cc_promo1;
  final String? cc_promo2;
  final int? Voucherseqno;
  final String? tbl_servedtime;
  final int? ServedStatus;
  final int? comments;
  final int? Switchid;
  final int? OperatorPromo;
  final int? Trackprep;
  final String? RentFromTime;
  final int? promptRentalWarning;
  final String? CPRVoucherNo;
  final int? ForeignPaidAmnt;
  final String? TaxTag;
  final String? CaptainOrderNo;
  final int? KDSPrint;

  OrderItemModel({
    this.POSID,
    this.OperatorNo,
    this.Covers,
    this.TableNo,
    this.SalesNo,
    this.SplitNo,
    this.SalesRef,
    this.PLUSalesRef,
    this.ItemSeqNo,
    this.PLUNo,
    this.Department,
    this.SDate,
    this.STime,
    this.Quantity,
    this.ItemName,
    this.ItemName_Chinese,
    this.ItemAmount,
    this.PaidAmount,
    this.ChangeAmount,
    this.Gratuity,
    this.Tax0,
    this.Tax1,
    this.Tax2,
    this.Tax3,
    this.Tax4,
    this.Tax5,
    this.Tax6,
    this.Tax7,
    this.Tax8,
    this.Tax9,
    this.Adjustment,
    this.DiscountType,
    this.DiscountPercent,
    this.Discount,
    this.PromotionId,
    this.PromotionType,
    this.PromotionSaving,
    this.TransMode,
    this.RefundID,
    this.TransStatus,
    this.FunctionID,
    this.SubFunctionID,
    this.MembershipID,
    this.LoyaltyCardNo,
    this.CustomerID,
    this.CardScheme,
    this.CreditCardNo,
    this.AvgCost,
    this.RecipeId,
    this.PriceShift,
    this.CategoryId,
    this.TransferredTable,
    this.TransferredOp,
    this.KitchenPrint1,
    this.KitchenPrint2,
    this.KitchenPrint3,
    this.RedemptionItem,
    this.PointsRedeemed,
    this.ShiftID,
    this.PrintFreePrep,
    this.PrintPrepWithPrice,
    this.Preparation,
    this.FOCItem,
    this.FOCType,
    this.ApplyTax0,
    this.ApplyTax1,
    this.ApplyTax2,
    this.ApplyTax3,
    this.ApplyTax4,
    this.ApplyTax5,
    this.ApplyTax6,
    this.ApplyTax7,
    this.ApplyTax8,
    this.ApplyTax9,
    this.LnkTo,
    this.BuyXfreeYapplied,
    this.RndingAdjustments,
    this.Setmenu,
    this.SetMenuRef,
    this.Instruction,
    this.PostSendVoid,
    this.TblHold,
    this.DepositID,
    this.TSalesRef,
    this.TSalesNo,
    this.TSplitNo,
    this.RentalItem,
    this.RentToDate,
    this.RentToTime,
    this.MinsRented,
    this.SeatNo,
    this.SalesAreaID,
    this.BusinessDate,
    this.ServerNo,
    this.OperatorFOC,
    this.OperatornoFirst,
    this.cc_promo1,
    this.cc_promo2,
    this.Voucherseqno,
    this.tbl_servedtime,
    this.ServedStatus,
    this.comments,
    this.Switchid,
    this.OperatorPromo,
    this.Trackprep,
    this.RentFromTime,
    this.promptRentalWarning,
    this.CPRVoucherNo,
    this.ForeignPaidAmnt,
    this.TaxTag,
    this.CaptainOrderNo,
    this.KDSPrint,
  }) : super();

  @override
  List<Object?> get props => [];

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);
}
