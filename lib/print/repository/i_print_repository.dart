abstract class IPrintRepository {
  Future<List<String>> getKPPrintItems(
      int salesNo,
      int splitNo,
      int kpNo,
      String tableNo,
      String categoryName,
      String tableName,
      String kpTableName,
      int transID);
  Future<List<List<String>>> getPrinterSetting(int printerID);
  Future<List<List<String>>> getKPSalesCategory(int salesNo, int splitNo,
      String tableName, String kpTableName, int transID);
  Future<List<List<String>>> getKPNo(int salesNo, int splitNo,
      String categoryName, String tableName, String kpTableName, int transID);
  Future<String> generateKP(
      int salesNo,
      int splitNo,
      String tableNo,
      String ctgName,
      int kpID,
      String tblName,
      String kpTblName,
      int transID,
      int countCopy);
  Future<List<List<String>>> getKPIndividual(
      int salesNo,
      int splitNo,
      int kpNo,
      String tableNo,
      String categoryName,
      String tableName,
      String kpTableName,
      int transID);

  Future<List<List<String>>> getKPIndividualItems(
      int salesNo,
      int splitNo,
      int kpNo,
      String tableNo,
      String categoryName,
      String tableName,
      String kpTableName,
      int transID);
  Future<String> generateIndividualKP(
      int salesNo,
      int splitNo,
      String tableNo,
      String ctgName,
      int kpID,
      String nameIndv,
      double qtyIndv,
      bool indv,
      String tblName,
      String kpTblName,
      int transId,
      int countCopy);
  Future<String> generateKPIndividual(
      int salesNo,
      int splitNo,
      String tableNo,
      String ctgName,
      int kpID,
      String tblName,
      String kpTblName,
      int transID,
      int countCopy);

  Future<void> kpPrinting(int kpsNo, int kpsPlNo, String kpTblNo,
      String tblName, String kpTblName, int transID, int countReprint);
  Future<void> updateKPPrintItem(int salesNo, int splitNo);

  Future<bool> findAutoCheckOp();
  Future<String> getRemarks(int salesNo, int splitNo, String tableName);
  Future<int> getCover(int salesNo, int splitNo);
  Future<String> getRcptNo(int salesNo, int splitNo);

  // Master KP
  Future<List<List<String>>> getMasterKPID(String posID);
  Future<List<List<String>>> getMasterKPSC(
      int salesNo, int splitNo, int masterKPID, int masterID);
  Future<String> generateMasterKP(int masterKPID, String ctgName, int ctgID,
      String tblNo, int salesNo, int splitNo, int masterID);
}
