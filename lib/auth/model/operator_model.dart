// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'operator_model.g.dart';

@JsonSerializable()
class OperatorModel {
  OperatorModel(
      this.OperatorNo,
      this.OperatorName,
      this.PIN,
      this.MultiOp,
      this.MaxVoids,
      this.MaxVoidsPerSale,
      this.SelectableVoids,
      this.VoidLastItem,
      this.AllVoid,
      this.VoidPayments,
      this.DiscItemPer,
      this.DiscItemAmt,
      this.RepeatBillDisc,
      this.FreeOfCharge,
      this.SuspendBill,
      this.ExemptTax,
      this.StayTaxEmptOn,
      this.RecallBill,
      this.AdjustBill,
      this.ReprintReceipt,
      this.PriceShift,
      this.OpenPriceShift,
      this.XReport,
      this.ZReport,
      this.TransferSale,
      this.TransferTable,
      this.Refunds,
      this.RedeemPoints,
      this.ZeroSales,
      this.CardNo,
      this.Manager,
      this.ForceCashDeclare,
      this.OpenAnyTable,
      this.TBLReservation,
      this.MembershipNum,
      this.ActivePromotion,
      this.PromotionEnds,
      this.ClearAndStore,
      this.EditSysSetup,
      this.PreSettlementRcpt,
      this.LogoutAfterSale,
      this.LogoutOnTableHold,
      this.EditKitchenMessage,
      this.OPLogMode,
      this.PostSendVoids,
      this.BillSettlement,
      this.EditAttendance,
      this.TransferItem,
      this.Deposits,
      this.ItemFOC,
      this.OpenPrice,
      this.OpenItems,
      this.SwitchWindow,
      this.AutoCheck,
      this.AdjustPrice,
      this.DefaultFunction,
      this.Defaultsectionname,
      this.Tablemanagement,
      this.ReprintClosedReceipt,
      this.Viewtrans,
      this.Memsearch,
      this.Edittableno,
      this.viewopentable,
      this.autoholdprintbill,
      this.VoidPromotion,
      this.opLanguage,
      this.op_promotion,
      this.opFiPo,
      this.opActiveYN,
      this.opSendSMS,
      this.previewbill,
      this.viewTransAll,
      this.opBottleManagement,
      this.SmartCardNo,
      this.opFingerprintID,
      this.opTopUpRefund,
      this.opTopUp,
      this.opMember,
      this.opMembership,
      this.opTopUpTransfer,
      this.opSplitBill,
      this.opPartialTopUpRefund,
      this.opBottleExpiry,
      this.opReprintKitchenReceipt,
      this.XZEntitlement,
      this.opWriteTicket,
      this.opReprintTopUp,
      this.opEditDeposit,
      this.opVoidDeposit,
      this.opConnectXPA,
      this.opBlitzBalance,
      this.OpUpdateHeld,
      this.ProcessKDS,
      this.ServedKDS,
      this.DisableSearchByMemId,
      this.CashTopUpMemberSearch,
      this.XZPeriod,
      this.ByTemplate,
      this.opSoldOut,
      this.opVoidMember,
      this.opViewSales,
      this.opReprintAll,
      this.ENCRYPTED,
      this.OpReopenbill,
      this.Quota,
      this.opChangeSalesCtg,
      this.opReopenBillToday,
      this.SettingKDS,
      this.opPointAdjust,
      this.DiscTotalPts,
      this.opRefundDeposit,
      this.opChangeDrawer,
      this.opCombineBill,
      this.OpMaxPrintBill,
      this.DiscTotalCashless,
      this.opPrinterSetting);

  final int OperatorNo;
  final String OperatorName;
  final String PIN;
  final int MultiOp;
  final int MaxVoids;
  final int MaxVoidsPerSale;
  final int SelectableVoids;
  final int VoidLastItem;
  final int AllVoid;
  final int VoidPayments;
  final int DiscItemPer;
  final int DiscItemAmt;
  final int RepeatBillDisc;
  final int FreeOfCharge;
  final int SuspendBill;
  final int ExemptTax;
  final int StayTaxEmptOn;
  final int RecallBill;
  final int AdjustBill;
  final int ReprintReceipt;
  final int PriceShift;
  final int OpenPriceShift;
  final int XReport;
  final int ZReport;
  final int TransferSale;
  final int TransferTable;
  final int Refunds;
  final int RedeemPoints;
  final int ZeroSales;
  final String CardNo;
  final int Manager;
  final int ForceCashDeclare;
  final int OpenAnyTable;
  final int TBLReservation;
  final int MembershipNum;
  final int ActivePromotion;
  final String PromotionEnds;
  final int ClearAndStore;
  final int EditSysSetup;
  final int PreSettlementRcpt;
  final int LogoutAfterSale;
  final int LogoutOnTableHold;
  final int EditKitchenMessage;
  final String OPLogMode;
  final int PostSendVoids;
  final int BillSettlement;
  final int EditAttendance;
  final int TransferItem;
  final int Deposits;
  final int ItemFOC;
  final int OpenPrice;
  final int OpenItems;
  final int SwitchWindow;
  final int AutoCheck;
  final int AdjustPrice;
  final int DefaultFunction;
  final String Defaultsectionname;
  final int Tablemanagement;
  final int ReprintClosedReceipt;
  final int Viewtrans;
  final int Memsearch;
  final int Edittableno;
  final int viewopentable;
  final int autoholdprintbill;
  final int VoidPromotion;
  final String opLanguage;
  final int op_promotion;
  final int opFiPo;
  final int opActiveYN;
  final int opSendSMS;
  final int previewbill;
  final int viewTransAll;
  final int opBottleManagement;
  final String SmartCardNo;
  final int opFingerprintID;
  final int opTopUpRefund;
  final int opTopUp;
  final int opMember;
  final int opMembership;
  final int opTopUpTransfer;
  final int opSplitBill;
  final int opPartialTopUpRefund;
  final int opBottleExpiry;
  final int opReprintKitchenReceipt;
  final String XZEntitlement;
  final int opWriteTicket;
  final int opReprintTopUp;
  final int opEditDeposit;
  final int opVoidDeposit;
  final int opConnectXPA;
  final int opBlitzBalance;
  final int OpUpdateHeld;
  final int ProcessKDS;
  final int ServedKDS;
  final int DisableSearchByMemId;
  final int CashTopUpMemberSearch;
  final int XZPeriod;
  final int ByTemplate;
  final int opSoldOut;
  final int opVoidMember;
  final int opViewSales;
  final int opReprintAll;
  final int ENCRYPTED;
  final int OpReopenbill;
  final double Quota;
  final int opChangeSalesCtg;
  final int opReopenBillToday;
  final int SettingKDS;
  final int opPointAdjust;
  final int DiscTotalPts;
  final int opRefundDeposit;
  final int opChangeDrawer;
  final int opCombineBill;
  final int OpMaxPrintBill;
  final int DiscTotalCashless;
  final int opPrinterSetting;

  factory OperatorModel.fromJson(Map<String, dynamic> json) =>
      _$OperatorModelFromJson(json);
  Map<String, dynamic> toJson() => _$OperatorModelToJson(this);
}
