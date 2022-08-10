// ignore_for_file: non_constant_identifier_names, unnecessary_late

import 'dart:core';

import 'package:get_it/get_it.dart';

import '../auth/model/operator_model.dart';
import 'extension/string_extension.dart';
import 'global_config_repository.dart';
import 'utils/type_util.dart';

// ignore: avoid_classes_with_only_static_members
class GlobalConfig {
  static OperatorModel? operator;

  static String token = '';
  static String username = '';

  static String PLUNumber = '';
  static String PLUName = '';

  static late int salesNo = 0;
  static late int splitNo = 0;
  static late int cover = 0;
  static String tableNo = '';
  static String rcptNo = '';
  //static bool ShowFunc = false;
  //static bool ShowPromo = false;
  //static bool ShowBillFOC = false;
  //static bool ShowDisc = false;

  static String TransMode = 'REG';

  static int operatorNo = 1;
  static String operatorName = '';
  static int MaxVoids = 9999;
  static int MaxVoidsPerSale = 9999;
  static bool AllVoid = true;
  static bool BillFOC = true;
  static bool VoidPromotion = true;
  static bool opPromotion = true;
  static bool Manager = true;
  static bool XReport = true;
  static bool ZReport = true;
  static bool VoidPayments = true;
  static bool LogoutAfterSales = true;
  static bool ItemFOC = true;
  static bool OpPrinterSetting = true;

  static int TableNoInt = 0;
  static String ErrMsg = '';
  static String ErrMsg2 = '';

  static String CategoryName = '';
  static int checkTableOpen = 0;
  static int checkItemOrder = 0;
  static int PrinterLength = 0;

  static int CustomKeyboard =
      0; //1:All Void, 2:Item Void, 3:CustomerID, 33:CustomerIDFOCBill, 4:Remarks, 5:Comments FOC
  static int PinAuth =
      0; //1:FOC Bill, 2:FOC Item, 3:Customer Display, 4:Kitchen Display, 5:All Void, 6:Void Promotion
  static int SplitQuantity = 0; //1:Split Quantity, 2:Split Void Quantity
  static bool ClickMenu =
      true; //true: menu enabled click, false: menu disabled click
  static bool ButtonClick = true;
  static int ChangeLayout = 1; //1:Pay Layout, 2:FOC Bill Layout
  static int CoverView = 0; //1:Table Management, 2:Quick Service
  static bool IsPrintInit = false;
}

// ignore: avoid_classes_with_only_static_members
class POSDefault with TypeUtil {
  static late bool taxInclusive = false;
  static bool blnSplitQuantity = false;
  static bool blnSplitKPStatus = false;

  static String ExecFilePath = '';
  static bool FiPo = false;
  static double FiPoAmount = 0;
  static bool ForceZDay = false;
  static bool ForceZShift = false;
  static bool enableStock = false;
  static bool blnGraphicsButton = false;
  static bool RndingAdjUp = false;
  static bool RndingAdjDown = false;
  static bool PresettleRound = false;
  static bool blnRentalCalculation = false;
  static bool blnPrintBottleRcpt = false;
  static int tblCleaningTime = 0;
  static bool blnIntrounding = false;
  static double Denumeration = 0;
  static bool TrackFoodServed = false;
  static double MaxOrderAmount = 0;
  static double MaxOrderQty = 0;
  static bool TaxInclusive = false;
  static bool PLUNumbersOnly = false;
  static String temp_BusinessEndTime = '';
  static String temp_businessStartTime = '';
  static bool blnTableManagement = false;
  static bool Cpr = false;
  static bool LiberteCPR = false;
  static bool printlogo = false;
  static bool blnPostVoidReason = false;
  static bool blnEnableThumper = false;
  static String FingerprintLogo = '';
  static bool enablePGP = false;
  static bool blnEncryptdbPath = false;
  static String SectorLogonPwd = '';
  static bool EnableMemOffline = false;
  static bool blnReciptConsolidate = false;
  static bool blnRoundAllMedia = false;
  static bool prmnPOS = false;
  static String mycurrency = '';
  static bool printKPWhenHoldTable = false;
  static int minFPScore = 0;
  static double depositvalue = 0;
  static bool blnPrintKPRfnd = false;
  static String opXPALogin = '';
  static bool blnKDS = false;
  static double CP_UTF8 = 0;
  static int viewTransOrderBy = 0;
  static bool LoginConfirmation = false;
  static double ezBalanceDebitInterval = 0;
  static double EzSettlementInterval = 0;
  static bool blnForceZdayDaily = false;
  static bool blnSplitPrepItemQty = false;
  static bool blnPrinterRedirect = false;
  static bool blnAttndByShift = false;
  static bool blnUnBlockFOCBillValidation = false;
  static bool blnNTUCIfMemberPromo = false;
  static String strNTUCFirstLine = '';
  static String strNTUCSecondLine = '';
  static bool blnPartialRcptConsolidate = false;
  static bool blnSetmenuIndividual = false;
  static bool blnShutdown = false;
  static bool blnMinimizeWin = false;
  static bool PhilippineTax = false;
  static double TScreenRefreshTime = 0;
  static double IntScroll = 0;
  static bool RfndPrompt4RcptNo = false;
  static bool blnPrintUnluckyVoucher = false;
  static bool blnPrintBarcode = false;
  static bool BlnLastVoid = false;
  static bool GenerateReceiptNoEnd = false;
  static bool blnLockCashlessState = false;
  static bool PrintKPWhenVoid = false;
  static bool BlockPLUSoldOut = false;
  static bool ForcePLUCoverQty = false;
  static int MaxNarrative = 0;
  static bool g_blnEnableAevitas = false;
  static String g_strFolderAevitas = '';
  static int g_intFormatAevitas = 0;
  static bool g_blnOrderItemCashlessCheck = false;
  static bool OffMemTrans = false;
  static String StrBusinessDate = '';
  static bool PLUImageDB = false;

  /// TODO: Create POSDefault Model
  /// REMOVE: finger clone code
  static Future<void> initPOSDefaults() async {
    GlobalConfigRepository configRepository = GetIt.I<GlobalConfigRepository>();
    List<List<String>> posDefaults = await configRepository.getPOSDefault();
    if (posDefaults.isNotEmpty) {
      List<String> posDefault = posDefaults[0];
      POSDefault.blnSplitQuantity = false;
      POSDefault.blnSplitKPStatus = false;

      POSDefault.TaxInclusive = posDefault[1].toBool();
      POSDefault.PLUNumbersOnly = posDefault[2].toBool();
      POSDefault.RndingAdjUp = posDefault[3].toBool();
      POSDefault.RndingAdjDown = posDefault[4].toBool();
      POSDefault.temp_businessStartTime = posDefault[12];
      POSDefault.temp_BusinessEndTime = posDefault[3];
      POSDefault.blnReciptConsolidate = posDefault[5].toBool();
      POSDefault.blnTableManagement = posDefault[23].toBool();
      POSDefault.tblCleaningTime = posDefault[24].toInt();
      ;
      POSDefault.Cpr = posDefault[26].toBool();
      POSDefault.blnPostVoidReason = posDefault[27].toBool();
      POSDefault.printlogo = posDefault[28].toBool();
      POSDefault.LiberteCPR = posDefault[29].toBool();
      POSDefault.PresettleRound = posDefault[30].toBool();
      POSDefault.ExecFilePath = posDefault[32];
      POSDefault.FiPo = posDefault[33].toBool();
      POSDefault.FiPoAmount = posDefault[34].toDouble();
      POSDefault.ForceZShift = posDefault[35].toBool();
      POSDefault.ForceZDay = posDefault[36].toBool();
      POSDefault.enableStock = posDefault[37].toBool();
      POSDefault.TrackFoodServed = posDefault[40].toBool();
      POSDefault.blnIntrounding = posDefault[41].toBool();
      POSDefault.Denumeration = posDefault[42].toDouble();
      POSDefault.blnRentalCalculation = posDefault[43].toBool();
      POSDefault.blnPrintBottleRcpt = posDefault[46].toBool();
      POSDefault.blnRoundAllMedia = posDefault[47].toBool();
      POSDefault.blnGraphicsButton = posDefault[48].toBool();
      if (!POSDefault.blnGraphicsButton) {
        POSDefault.blnGraphicsButton = true;
      }

      POSDefault.MaxOrderAmount = posDefault[49].toDouble();
      POSDefault.blnEnableThumper = posDefault[50].toBool();
      POSDefault.FingerprintLogo = posDefault[51];
      POSDefault.prmnPOS = posDefault[52].toBool();
      POSDefault.mycurrency = posDefault[53];
      POSDefault.enablePGP = posDefault[54].toBool();
      POSDefault.printKPWhenHoldTable = posDefault[55].toBool();
      POSDefault.blnEncryptdbPath = posDefault[56].toBool();
      POSDefault.minFPScore = posDefault[57].toInt();
      ;
      POSDefault.depositvalue = posDefault[58].toDouble();
      POSDefault.opXPALogin = posDefault[59];
      POSDefault.blnPrintKPRfnd = posDefault[60].toBool();
      POSDefault.blnKDS = posDefault[61].toBool();
      POSDefault.CP_UTF8 = posDefault[62].toDouble();
      if (POSDefault.CP_UTF8 == 0) {
        POSDefault.CP_UTF8 = double.tryParse('936') ?? 0;
      }

      POSDefault.viewTransOrderBy = posDefault[63].toInt();
      ;
      POSDefault.LoginConfirmation = posDefault[64].toBool();
      POSDefault.ezBalanceDebitInterval = posDefault[66].toDouble();
      POSDefault.EzSettlementInterval = posDefault[67].toDouble();
      POSDefault.blnForceZdayDaily = posDefault[68].toBool();
      POSDefault.blnSplitPrepItemQty = posDefault[69].toBool();
      POSDefault.blnPrinterRedirect = posDefault[71].toBool();
      POSDefault.blnAttndByShift = posDefault[72].toBool();
      POSDefault.blnUnBlockFOCBillValidation = posDefault[73].toBool();
      POSDefault.blnNTUCIfMemberPromo = posDefault[74].toBool();
      POSDefault.strNTUCFirstLine = posDefault[75];
      POSDefault.strNTUCSecondLine = posDefault[76];
      POSDefault.SectorLogonPwd = posDefault[77];
      POSDefault.EnableMemOffline = posDefault[78].toBool();
      POSDefault.blnPartialRcptConsolidate = posDefault[80].toBool();
      POSDefault.blnSetmenuIndividual = posDefault[81].toBool();
      POSDefault.blnShutdown = posDefault[82].toBool();
      POSDefault.blnMinimizeWin = posDefault[83].toBool();
      POSDefault.PhilippineTax = posDefault[84].toBool();
      POSDefault.TScreenRefreshTime = posDefault[85].toDouble();
      if (POSDefault.TScreenRefreshTime == 0) {
        POSDefault.TScreenRefreshTime = 1;
      }

      POSDefault.IntScroll = posDefault[86].toDouble();
      POSDefault.RfndPrompt4RcptNo = posDefault[87].toBool();
      POSDefault.blnPrintUnluckyVoucher = posDefault[88].toBool();
      POSDefault.BlnLastVoid = posDefault[89].toBool();
      if (!POSDefault.BlnLastVoid) {
        POSDefault.BlnLastVoid = true;
      }

      POSDefault.blnPrintBarcode = posDefault[90].toBool();
      POSDefault.GenerateReceiptNoEnd = posDefault[93].toBool();
      POSDefault.blnLockCashlessState = posDefault[95].toBool();
      POSDefault.PrintKPWhenVoid = posDefault[97].toBool();
      if (!POSDefault.PrintKPWhenVoid) {
        POSDefault.PrintKPWhenVoid = true;
      }

      POSDefault.BlockPLUSoldOut = posDefault[101].toBool();
      POSDefault.ForcePLUCoverQty = posDefault[102].toBool();
      POSDefault.MaxNarrative = posDefault[103].toInt();
      ;
      if (POSDefault.MaxNarrative == 0) {
        POSDefault.MaxNarrative = 40;
      }

      POSDefault.g_blnEnableAevitas = posDefault[104].toBool();
      POSDefault.MaxOrderQty = posDefault[106].toDouble();
      POSDefault.g_blnOrderItemCashlessCheck = posDefault[107].toBool();
      POSDefault.PLUImageDB = posDefault[108].toBool();
      POSDefault.OffMemTrans = posDefault[109].toBool();
      POSDefault.g_intFormatAevitas = posDefault[110].toInt();
      ;
      if (POSDefault.g_intFormatAevitas == 0) {
        POSDefault.g_intFormatAevitas = 1;
      }
    }
  }
}

// ignore: avoid_classes_with_only_static_members
class POSDtls with TypeUtil {
  static late int categoryID = 1;
  static late String deviceNo = '1';
  static late String posType;
  static late String strSalesAreaID = 'LOUN';
  static late String strPOSTitle = '';
  static late String selTermDSN;
  static late String srvrDSN;
  static late String printRcpt;
  static late String hpyHr1;
  static late String hpyHr2;
  static late String hpyHr3;
  static late String hpyStart1;
  static late String hpyEnd1;
  static late String hpyStart2;
  static late String hpyEnd2;
  static late String hpyStart3;
  static late String hpyEnd3;
  static late int defCtgryID;
  // static late int ctgryID;
  static late int mnuLvl;
  static late String tblNameType;
  static late int firstTable;
  static late int lastTable;
  static late bool tblAutoOnly;
  static late bool forceTable = false;
  static late bool forceCover = true;
  static late bool blnForceCovertracking;
  static late bool xzSms;
  static late String zxSmsDevice;
  static late String dialInprovider;
  static late String providerProtocol;
  static late String providerPassword;
  static late bool FingerPrint;
  static late bool sdkPOS;
  static late bool PrintRental;
  static late bool PrintVoidRemarksKP;
  static late bool PluNoItem;
  static late bool FingerPrintMem;
  static late bool FingerPrintOP;
  static late bool ForceServerNo;
  static late bool blnForceSalesCategory;
  static late bool DualFnPrinter;
  static late bool EnableSysSetUp;
  static late bool PrintVoids = true;
  static late bool PrintFreeItems = true;
  static late bool PrintUnitPrice = true;
  static late bool PrintGroupsubtotal = true;
  static late bool PrintSalesCategory = true;
  static late bool PrintDeptSubTotal = true;
  static late bool PrintSalesCtgSubTotal = true;
  static late bool PrintGroup = true;
  static late bool PrintDepartment = true;
  static late bool KPPrintGroup = true;
  static late bool KPPrintDepartment = true;
  static late bool KPOrderRemarks = true;
  static late bool PrintRounding = true;
  static late bool PrintTax = true;
  static late bool PrintTotalTax = true;
  static late String TotalTaxTitle = 'TotalTaxTitle';
  static late bool EnBell;
  static late String BColor;
  static late String FColor;
  static late bool PrintPrmnDtls = true;
  static late bool PrintPrmnSummary = true;
  static late bool PrintFreePrep = true;
  static late bool PrintFreePLU = true;
  static late bool PrintPrepWithPrice = true;
  static late bool PrintTimeAttend = true;
  static late int AutoTblStart;
  static late int AutoTblEnd;
  static late bool Kitchen;
  static late bool ApplyPrmn;
  static late int DefPShift = 1;
  static late String PShift = '1';
  static late bool CustDisplay;
  static late String CustDisp1;
  static late String CustDisp2;
  static late int CustDispPort;
  static late bool DispScroll;
  static late int ClosedBillCnt;
  static late int ReprintBillCnt;
  static late int PreprintBillCnt;
  static late int AllVoidBillCnt;
  static late int XreportCnt;
  static late int ZreportCnt;
  static late bool OrderStation;
  static late bool PLU_BillDiscount;
  static late bool XZALLPOS;
  static late bool xzGroup;
  static late bool xzHistory;
  static late bool xzOperator;
  static late bool xzPluFoc;
  static late bool xzRemarks;
  static late bool blnWeighingScale;
  static late int intWeighingPort;
  static late int intWeighScaleType;
  static late int WeighScaleDec;
  static late int WeighScaleDecimal;
  static late bool blnPrintLstOpName;
  static late bool printFirstservername;
  static late bool blnNetsScan;
  static late int intNetsPort;
  static late int intCreditCardPort;
  static late int intCreditCardTimeOut;
  static late String strPOSButtonColor;
  static late bool blnTblMangTime;
  static late String strTransTblKpID;
  static late bool blnTransTbl_AllPrinter;
  static late bool printrcptno;
  static late bool PrintRcptTime;
  static late bool PrintTableNo;
  static late bool blnKPPrintConsolidate;
  static late bool blnKPPrintIndividual;
  static late bool blnKPPrintMaster = true;
  static late bool blnKPPrintTransferTable;
  static late bool blnKPPrintStickerRcpt;
  static late bool blnKPPrintID = true;
  static late bool blnKPMasterPrintID;
  static late bool blnKPPrintPrepQty;
  static late bool blnKPPrintCover = true;
  static late bool blnKPPrintPLUNo;
  static late bool blnKPPrintPrice;
  static late bool blnKPPrintPriceTotal;
  static late bool blnKPPrintSideway;
  static late bool blnKPPrintBarcode;
  static late bool blnKPPrintAutoSplitQty;
  static late bool blnKPPartialConsolidate = false;
  static late bool blnKPPrintBigTableNo;
  static late bool blnKPPrintRefundItem;
  static late bool blnKPPrintCounter;
  static late bool blnPrint;
  static late bool PrintTblRemarks = true;
  static late bool MasterKPPrintTblRemarks;
  static late bool blnMultiDrawer;
  static late String DrawerName;
  static late bool blnDumpDrawer;
  static late String DrawerPort;
  static late int DrawerValue;
  static late bool viewDot;
  static late String stritemlistBColor;
  static late String strItemListFColor;
  static late int intItemListFontSize;
  static late bool blnItemListBold;
  static late String strNumpadBColor;
  static late int intNumpadFontSize;
  static late bool blnNumpadBold;
  static late bool BlnCreditCard_Scan;
  static late bool blnpoolportno;
  static late int intPoolPortNo;
  static late int intlanguage;
  static late int intlanguageop;
  static late bool ForceFiPo;
  static late int intItemRight;
  static late int intItemBottom;
  static late int intMenuRight;
  static late int intMenuBottom;
  static late bool DispWelcomeOnly;
  static late bool StartWithOpenTbls;
  static late bool TBLManagement = true;
  static late int NumKpBHdrLines;
  static late bool LineBetKPHdr;
  static late bool LineBetKPItems;
  static late bool LineBetKPMsgHdr;
  static late bool LineBetKPMessage;
  static late bool ForceSeatNo;
  static late String SignInName;
  static late bool blnSecondScreen;
  static late bool blnViewOrderGrid;
  static late String GridHcolor;
  static late String GridOcolor;
  static late String GridEcolor;
  static late String GridFcolor;
  static late String GridMColor;
  static late String GridPcolor;
  static late String GridCColor;
  static late String GridFocColor;
  static late String GridDcolor;
  static late String SecondBcolor;
  static late String SecondFcolor;
  static late String firstPic;
  static late String SecondPic;
  static late String CompanyPic;
  static late String TablePic;
  static late String ScreenHeader1 = 'Admin';
  static late String ScreenHeader2 = 'Admin1';
  static late String ScreenHeader3 = 'Admin2';
  static late bool blnSmartCard;
  static late int SmartcardPort;
  static late bool blnAutoReceivedPOS;
  static late String strAutoReceivedPOS;
  static late bool SmartCardMem;
  static late bool SmartCardOP;
  static late bool blnSmartCardTopUp;
  static late int cntVisitWarning;
  static late bool blnTicketTag;
  static late bool blnPrintTotalQty;
  static late bool printBalancePoints;
  static late bool blnXPA;
  static late bool blnForceSalesCategorySellband;
  static late int RentalWarning;
  static late bool printZeroPrice = true;
  static late bool blnEzlink;
  static late int EzlinkPort;
  static late bool blnViewTableNo;
  static late int PoolTableLoc;
  static late String strMinTimeForZDay;
  static late bool blnMinTimeOverMidNight;
  static late bool blnDisplayMemberFav;
  static late bool blnDisplayMemberPurchase;
  static late bool blnBixolonCustDisp;
  static late bool blnViewRePrintAll;
  static late bool blnPrinXZRemarks;
  static late bool blnPrintVAT;
  static late bool blnPrintCaptainOrder;
  static late String strScroll;
  static late bool printOfficial;
  static late bool XZprintCollected;
  static late String LabelTable = '';
  static late bool UpdateRsvn;
  static late bool BlnAutoPromotion;
  static late bool BlnFreeItems;
  static late bool PrintZeroSales;
  static late bool EnableCombo;
  static late String BarcodeWeight;
  static late String BarcodePrice;
  static late int BarcodeWeightDec;
  static late int BarcodeWeightDecimal;
  static late bool blnNewTablePopUp;
  static late String strPopUpMsg;
  static late bool blnFPOD;
  static late bool SDK2POS;
  static late int SecondScreenFontsize;
  static late bool RcptManualPrinterId;
  static late bool g_blnPreRcptDblSize;
  static late String g_strPreRcptComment;
  static late bool blnPrintLstServerName;
  static late bool ConsolidateMedia;
  static late int OMRPort;
  static late bool g_blnForceCloseDrawer;
  static late bool ZipCodeTableNo;
  static late bool PrintRcptTitle;
  static late bool AskNarrative;
  static late double AskNarrativeAmount;
  static late bool SendBillToEmail;
  static late bool PrintTaxTitle;
  static late bool g_blnTabletScreen;

  static late String refDtName;
  static late String refTimeName;
  static late bool AlertPrevDayPendTbls;
  static late int SecID;
  static late bool blnKPPrintStickerCheck;
  static late bool XZSms;
  static late String xzSmsDevice;

  static Future<void> initPOSDtls() async {
    GlobalConfigRepository configRepository = GetIt.I<GlobalConfigRepository>();
    List<List<String>> posDtls = await configRepository.getPosDtls();
    if (posDtls.isNotEmpty) {
      List<String> tempData = posDtls[0];

      POSDtls.deviceNo = "POS001";
      POSDtls.strPOSTitle = tempData[1];
      POSDtls.strSalesAreaID = tempData[3];
      POSDtls.forceTable = tempData[5].toBool();
      POSDtls.forceCover = tempData[6].toBool();
      POSDtls.EnBell = tempData[7].toBool();
      POSDtls.DefPShift = tempData[8].toInt();
      POSDtls.PShift = POSDtls.DefPShift.toString();
      POSDtls.defCtgryID = tempData[9].toInt();
      POSDtls.categoryID = tempData[9].toInt();
      POSDtls.hpyHr1 = tempData[10];
      POSDtls.hpyHr2 = tempData[11];
      POSDtls.hpyHr3 = tempData[12];
      POSDtls.hpyStart1 = tempData[13];
      POSDtls.hpyEnd1 = tempData[14];
      POSDtls.hpyStart2 = tempData[22];
      POSDtls.hpyEnd2 = tempData[23];
      POSDtls.hpyStart3 = tempData[31];
      POSDtls.hpyEnd3 = tempData[32];
      POSDtls.tblNameType = tempData[41];
      POSDtls.tblAutoOnly = tempData[42].toBool();
      POSDtls.firstTable = tempData[43].toInt();
      POSDtls.lastTable = tempData[44].toInt();
      POSDtls.AutoTblStart = tempData[45].toInt();
      POSDtls.AutoTblEnd = tempData[46].toInt();
      GlobalConfig.TableNoInt = POSDtls.AutoTblStart;
      POSDtls.printRcpt = tempData[49];
      POSDtls.DualFnPrinter = tempData[50].toBool();
      POSDtls.ScreenHeader1 = tempData[51];
      POSDtls.ScreenHeader2 = tempData[52];
      POSDtls.ScreenHeader3 = tempData[53];
      POSDtls.PrintFreeItems = tempData[62].toBool();
      POSDtls.PrintVoids = tempData[63].toBool();
      POSDtls.PrintPrmnDtls = tempData[64].toBool();
      POSDtls.PrintPrmnSummary = tempData[65].toBool();
      POSDtls.selTermDSN = tempData[81];
      POSDtls.srvrDSN = tempData[82];
      POSDtls.EnableSysSetUp = tempData[85].toBool();
      POSDtls.PrintFreePrep = tempData[88].toBool();
      POSDtls.PrintPrepWithPrice = tempData[89].toBool();
      POSDtls.PrintTimeAttend = tempData[94].toBool();
      POSDtls.Kitchen = tempData[95].toBool();
      POSDtls.ApplyPrmn = tempData[96].toBool();
      POSDtls.CustDisplay = tempData[97].toBool();
      POSDtls.CustDisp1 = tempData[98];
      POSDtls.CustDisp2 = tempData[99];
      POSDtls.CustDispPort = tempData[100].toInt();
      POSDtls.DispScroll = tempData[101].toBool();
      POSDtls.ClosedBillCnt = tempData[102].toInt();
      POSDtls.ReprintBillCnt = tempData[103].toInt();
      POSDtls.PreprintBillCnt = tempData[104].toInt();
      POSDtls.AllVoidBillCnt = tempData[105].toInt();
      POSDtls.XreportCnt = tempData[106].toInt();
      POSDtls.ZreportCnt = tempData[107].toInt();
      POSDtls.refDtName = tempData[128] + " Dt";
      POSDtls.refTimeName = tempData[128] + " Time";
      POSDtls.OrderStation = tempData[129].toBool();
      POSDtls.DispWelcomeOnly = tempData[131].toBool();
      POSDtls.StartWithOpenTbls = tempData[132].toBool();
      POSDtls.AlertPrevDayPendTbls = tempData[133].toBool();
      POSDtls.SecID = tempData[134].toInt();
      POSDtls.TBLManagement = tempData[135].toBool();
      POSDtls.NumKpBHdrLines = tempData[136].toInt();
      POSDtls.LineBetKPHdr = tempData[137].toBool();
      POSDtls.LineBetKPItems = tempData[138].toBool();
      POSDtls.LineBetKPMsgHdr = tempData[139].toBool();
      POSDtls.LineBetKPMessage = tempData[140].toBool();
      POSDtls.ForceSeatNo = tempData[141].toBool();
      POSDtls.blnPrint = tempData[142].toBool();
      POSDtls.intlanguage = tempData[143].toInt();
      POSDtls.intlanguageop = tempData[143].toInt();
      POSDtls.PLU_BillDiscount = tempData[145].toBool();
      POSDtls.BlnCreditCard_Scan = tempData[146].toBool();
      POSDtls.intPoolPortNo = tempData[147].toInt();
      if (POSDtls.intPoolPortNo == 0) {
        POSDtls.intPoolPortNo = 1;
      }

      POSDtls.blnpoolportno = tempData[148].toBool();
      POSDtls.XZALLPOS = tempData[150].toBool();
      POSDtls.SignInName = tempData[164];
      POSDtls.intItemRight = tempData[171].toInt();
      if (POSDtls.intItemRight == 0) {
        POSDtls.intItemRight = 5;
      }

      POSDtls.intItemBottom = tempData[172].toInt();
      if (POSDtls.intItemBottom == 0) {
        POSDtls.intItemBottom = 6;
      }

      POSDtls.intMenuRight = tempData[173].toInt();
      if (POSDtls.intMenuRight == 0) {
        POSDtls.intMenuRight = 4;
      }

      POSDtls.intMenuBottom = tempData[174].toInt();
      if (POSDtls.intMenuBottom == 0) {
        POSDtls.intMenuBottom = 5;
      }

      POSDtls.blnWeighingScale = tempData[175].toBool();
      if (!POSDtls.blnWeighingScale) {
        POSDtls.blnWeighingScale = true;
      }

      POSDtls.intWeighingPort = tempData[176].toInt();
      if (POSDtls.intWeighingPort == 0) {
        POSDtls.intWeighingPort = 1;
      }

      POSDtls.stritemlistBColor = tempData[177];
      POSDtls.strItemListFColor = tempData[178];
      POSDtls.intItemListFontSize = tempData[179].toInt();
      POSDtls.blnItemListBold = tempData[180].toBool();
      POSDtls.strNumpadBColor = tempData[181];
      POSDtls.intNumpadFontSize = tempData[182].toInt();
      POSDtls.blnNumpadBold = tempData[183].toBool();
      POSDtls.blnPrintLstOpName = tempData[184].toBool();
      POSDtls.blnNetsScan = tempData[185].toBool();
      POSDtls.intNetsPort = tempData[186].toInt();
      if (POSDtls.intNetsPort == 0) {
        POSDtls.intNetsPort = 1;
      }

      POSDtls.blnKPPrintPrepQty = tempData[187].toBool();
      POSDtls.strPOSButtonColor = tempData[188];
      POSDtls.intCreditCardPort = tempData[194].toInt();
      if (POSDtls.intCreditCardPort == 0) {
        POSDtls.intCreditCardPort = 1;
      }

      POSDtls.blnTblMangTime = tempData[195].toBool();
      if (!POSDtls.blnTblMangTime) {
        POSDtls.blnTblMangTime = true;
      }

      POSDtls.strTransTblKpID = tempData[196];
      POSDtls.blnTransTbl_AllPrinter = tempData[197].toBool();
      if (!POSDtls.blnTransTbl_AllPrinter) {
        POSDtls.blnTransTbl_AllPrinter = true;
      }

      POSDtls.ForceServerNo = tempData[198].toBool();
      POSDtls.printrcptno = tempData[201].toBool();
      if (!POSDtls.printrcptno) {
        POSDtls.printrcptno = true;
      }

      POSDtls.PrintTableNo = tempData[202].toBool();
      POSDtls.ForceFiPo = tempData[205].toBool();
      POSDtls.PrintRcptTime = tempData[206].toBool();
      if (!POSDtls.PrintRcptTime) {
        POSDtls.PrintRcptTime = true;
      }

      POSDtls.blnForceSalesCategory = tempData[207].toBool();
      POSDtls.blnForceCovertracking = tempData[208].toBool();
      POSDtls.XZSms = tempData[209].toBool();
      POSDtls.xzSmsDevice = tempData[210];
      POSDtls.dialInprovider = tempData[212];
      POSDtls.providerProtocol = tempData[213];
      POSDtls.providerPassword = tempData[214];
      POSDtls.FingerPrint = tempData[215].toBool();
      POSDtls.PrintUnitPrice = tempData[219].toBool();
      POSDtls.PrintGroupsubtotal = tempData[220].toBool();
      POSDtls.PrintRounding = tempData[223].toBool();
      POSDtls.PrintTax = tempData[224].toBool();
      POSDtls.viewDot = tempData[225].toBool();
      POSDtls.blnSecondScreen = tempData[226].toBool();
      POSDtls.blnViewOrderGrid = tempData[227].toBool();
      POSDtls.GridHcolor = tempData[228];
      POSDtls.GridOcolor = tempData[229];
      POSDtls.GridEcolor = tempData[230];
      POSDtls.GridFcolor = tempData[231];
      POSDtls.FColor = tempData[232];
      POSDtls.SecondFcolor = tempData[232];
      POSDtls.BColor = tempData[233];
      POSDtls.SecondBcolor = tempData[233];
      POSDtls.firstPic = tempData[234];
      POSDtls.SecondPic = tempData[235];
      POSDtls.GridMColor = tempData[236];
      POSDtls.GridPcolor = tempData[237];
      POSDtls.GridCColor = tempData[238];
      POSDtls.GridDcolor = tempData[239];
      POSDtls.GridFocColor = tempData[240];
      POSDtls.CompanyPic = tempData[241];
      POSDtls.blnSmartCard = tempData[242].toBool();
      POSDtls.SmartcardPort = tempData[243].toInt();
      POSDtls.xzGroup = tempData[244].toBool();
      POSDtls.xzHistory = tempData[245].toBool();
      POSDtls.xzOperator = tempData[246].toBool();
      POSDtls.printFirstservername = tempData[248].toBool();
      POSDtls.PrintTotalTax = tempData[249].toBool();
      POSDtls.TotalTaxTitle = tempData[250];
      POSDtls.FingerPrintMem = tempData[251].toBool();
      POSDtls.FingerPrintOP = tempData[252].toBool();
      POSDtls.blnMultiDrawer = tempData[253].toBool();
      POSDtls.DrawerName = "FTCD1";
      POSDtls.xzPluFoc = tempData[256].toBool();
      if (!POSDtls.xzPluFoc) {
        POSDtls.xzPluFoc = true;
      }

      POSDtls.PrintTblRemarks = tempData[259].toBool();
      POSDtls.blnAutoReceivedPOS = tempData[261].toBool();
      POSDtls.strAutoReceivedPOS = tempData[262];
      POSDtls.SmartCardMem = tempData[263].toBool();
      POSDtls.SmartCardOP = tempData[264].toBool();
      POSDtls.blnSmartCardTopUp = tempData[265].toBool();
      POSDtls.cntVisitWarning = tempData[266].toInt();
      POSDtls.blnTicketTag = tempData[267].toBool();
      POSDtls.blnPrintTotalQty = tempData[268].toBool();
      POSDtls.printBalancePoints = tempData[269].toBool();
      POSDtls.blnXPA = tempData[270].toBool();
      POSDtls.blnForceSalesCategorySellband = tempData[272].toBool();
      POSDtls.RentalWarning = tempData[273].toInt();
      POSDtls.printZeroPrice = tempData[274].toBool();
      POSDtls.blnEzlink = tempData[275].toBool();
      POSDtls.EzlinkPort = tempData[276].toInt();
      POSDtls.blnViewTableNo = tempData[277].toBool();
      POSDtls.TablePic = tempData[278];
      POSDtls.blnDumpDrawer = tempData[279].toBool();
      POSDtls.DrawerPort = tempData[280];
      POSDtls.DrawerValue = tempData[281].toInt();
      POSDtls.PoolTableLoc = tempData[284].toInt();
      POSDtls.strMinTimeForZDay = tempData[291];
      POSDtls.blnMinTimeOverMidNight = tempData[292].toBool();
      POSDtls.xzRemarks = tempData[294].toBool();
      POSDtls.blnPrinXZRemarks = tempData[294].toBool();
      POSDtls.blnDisplayMemberPurchase = tempData[295].toBool();
      POSDtls.blnDisplayMemberFav = tempData[296].toBool();
      POSDtls.blnBixolonCustDisp = tempData[297].toBool();
      POSDtls.blnViewRePrintAll = tempData[302].toBool();
      POSDtls.blnPrintVAT = tempData[303].toBool();
      POSDtls.blnPrintCaptainOrder = tempData[306].toBool();
      POSDtls.strScroll = tempData[307];
      POSDtls.XZprintCollected = tempData[308].toBool();
      POSDtls.printOfficial = tempData[309].toBool();
      POSDtls.LabelTable = tempData[311];
      if (POSDtls.LabelTable == " ") {
        POSDtls.LabelTable = "TABLE";
      }

      POSDtls.sdkPOS = tempData[312].toBool();
      POSDtls.PrintRental = tempData[318].toBool();
      POSDtls.PrintVoidRemarksKP = tempData[319].toBool();
      POSDtls.PluNoItem = tempData[320].toBool();
      POSDtls.UpdateRsvn = tempData[321].toBool();
      POSDtls.BlnAutoPromotion = tempData[322].toBool();
      POSDtls.BlnFreeItems = tempData[324].toBool();
      POSDtls.PrintZeroSales = tempData[325].toBool();
      POSDtls.EnableCombo = tempData[326].toBool();
      POSDtls.BarcodeWeight = tempData[327];
      POSDtls.BarcodePrice = tempData[328];
      POSDtls.blnNewTablePopUp = tempData[329].toBool();
      POSDtls.strPopUpMsg = tempData[330];
      POSDtls.PrintSalesCategory = tempData[331].toBool();
      POSDtls.PrintDeptSubTotal = tempData[332].toBool();
      POSDtls.PrintSalesCtgSubTotal = tempData[333].toBool();
      POSDtls.blnFPOD = tempData[334].toBool();
      POSDtls.intWeighScaleType = tempData[335].toInt();
      POSDtls.SDK2POS = tempData[336].toBool();
      POSDtls.blnKPPrintConsolidate = tempData[337].toBool();
      POSDtls.blnKPPrintIndividual = tempData[338].toBool();
      POSDtls.blnKPPrintMaster = tempData[339].toBool();
      POSDtls.blnKPPrintTransferTable = tempData[340].toBool();
      POSDtls.blnKPPrintStickerRcpt = tempData[341].toBool();
      POSDtls.blnKPPrintStickerCheck = tempData[342].toBool();
      POSDtls.blnKPPrintID = tempData[343].toBool();
      POSDtls.blnKPPrintCover = tempData[344].toBool();
      POSDtls.blnKPPrintPLUNo = tempData[345].toBool();
      POSDtls.blnKPPrintPrice = tempData[346].toBool();
      POSDtls.blnKPPrintSideway = tempData[347].toBool();
      POSDtls.blnKPPrintBarcode = tempData[348].toBool();
      POSDtls.blnKPPrintAutoSplitQty = tempData[349].toBool();
      POSDtls.SecondScreenFontsize = tempData[350].toInt();
      POSDtls.RcptManualPrinterId = tempData[351].toBool();
      POSDtls.blnKPPrintBigTableNo = tempData[352].toBool();
      POSDtls.g_blnPreRcptDblSize = tempData[353].toBool();
      POSDtls.g_strPreRcptComment = tempData[354];
      POSDtls.blnKPPrintRefundItem = tempData[355].toBool();
      POSDtls.BarcodeWeightDec = tempData[356].toInt();
      if (POSDtls.BarcodeWeightDec == 0) {
        POSDtls.BarcodeWeightDec = 2;
      }

      POSDtls.BarcodeWeightDecimal = 1;
      for (int i = 1; i < POSDtls.BarcodeWeightDec; i++) {
        String barcodeWDec = POSDtls.BarcodeWeightDec.toString() + "0";
        POSDtls.BarcodeWeightDecimal = barcodeWDec.toInt();
      }

      POSDtls.WeighScaleDec = tempData[357].toInt();
      POSDtls.WeighScaleDecimal = 1;
      for (int i = 1; i < POSDtls.WeighScaleDec; i++) {
        String weightscID = POSDtls.BarcodeWeightDec.toString() + "0";
        POSDtls.WeighScaleDecimal = weightscID.toInt();
      }

      POSDtls.blnPrintLstServerName = tempData[358].toBool();
      POSDtls.intCreditCardTimeOut = tempData[359].toInt();
      if (POSDtls.intCreditCardTimeOut == 0) {
        POSDtls.intCreditCardTimeOut = 30;
      }

      POSDtls.PrintFreePLU = tempData[360].toBool();
      POSDtls.ConsolidateMedia = tempData[361].toBool();
      POSDtls.PrintGroup = tempData[362].toBool();
      POSDtls.PrintDepartment = tempData[363].toBool();
      POSDtls.KPPrintGroup = tempData[364].toBool();
      POSDtls.KPPrintDepartment = tempData[365].toBool();
      POSDtls.OMRPort = tempData[366].toInt();
      POSDtls.g_blnForceCloseDrawer = tempData[367].toBool();
      POSDtls.MasterKPPrintTblRemarks = tempData[368].toBool();
      POSDtls.ZipCodeTableNo = tempData[369].toBool();
      POSDtls.blnKPPartialConsolidate = tempData[370].toBool();
      POSDtls.KPOrderRemarks = tempData[371].toBool();
      POSDtls.PrintRcptTitle = tempData[372].toBool();
      POSDtls.AskNarrative = tempData[373].toBool();
      POSDtls.AskNarrativeAmount = tempData[374].toDouble();
      POSDtls.blnKPMasterPrintID = tempData[375].toBool();
      POSDtls.SendBillToEmail = tempData[376].toBool();
      POSDtls.blnKPPrintPriceTotal = tempData[377].toBool();
      POSDtls.PrintTaxTitle = tempData[378].toBool();
      POSDtls.g_blnTabletScreen = tempData[379].toBool();
      POSDtls.blnKPPrintCounter = tempData[380].toBool();
    }
  }
}

// ignore: avoid_classes_with_only_static_members
class InitSalesVar {
  static late int NCover = 0;
  static late String TransMode = 'REG';
  static late String LoyaltyCardNo = '';
  static late int SeatNo = 0;
  static late int RefundID = 0;
  static late String strTableName = '';

  //Tax
  static late bool ApplyTax0 = false;
  static late bool ApplyTax1 = false;
  static late bool ApplyTax2 = false;
  static late bool ApplyTax3 = false;
  static late bool ApplyTax4 = false;
  static late bool ApplyTax5 = false;
  static late bool ApplyTax6 = false;
  static late bool ApplyTax7 = false;
  static late bool ApplyTax8 = false;
  static late bool ApplyTax9 = false;
  static late double TTax0 = 0.0;
  static late double TTax1 = 0.0;
  static late double TTax2 = 0.0;
  static late double TTax3 = 0.0;
  static late double TTax4 = 0.0;
  static late double TTax5 = 0.0;
  static late double TTax6 = 0.0;
  static late double TTax7 = 0.0;
  static late double TTax8 = 0.0;
  static late double TTax9 = 0.0;

  //Member
  static late int memId = 0;
}
