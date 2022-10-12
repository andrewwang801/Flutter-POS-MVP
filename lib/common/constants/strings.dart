const String message_allvoid_failed_transaction =
    'All Void Failed! No Transaction - Please open table first';
const String message_allvoid_failed_permission =
    'All Void Failed! No Transaction - Not enough permission to All Void';

const String message_title_error = 'Error';

const String message_plu_not_found = 'Can not find the PLU:';

const String message_void_item_failed =
    'Void Item Failed! \n Void item not allowed after a "Bill Discount". Void Previous "Bill Discount" and try again';

// Cash
const String k_cash_payment = 'Cash Payment';
const String k_payment = 'Payment';
const String k_total_bill = 'Total Bill';
const String k_change = 'Change';
const String k_amount_due = 'Amount Due';
const String k_balance_due = 'Balance Due';
const String message_payment_cash_failed =
    'Payment Cash Failed! Paid amount is not enough.';

// Printer
const String message_no_printer = 'There is no printer connected';

class PrintStatus {
  static const String k_void_table = 'Void Table';
  static const String k_close_tables = 'Close Tables';
  static const String k_refund = 'Refund';

  static const String k_close = 'Close';
  static const String k_all_void = 'All Void';
}

class TableName {
  static const String table_held_items = 'HeldItems';
  static const String table_kp_status = 'KPStatus';
}

class Bill {
  static const String k_total = 'TOTAL';
  static const String k_sub_total = 'SUB TOTAL';
  static const String k_total_item = 'TOTAL ITEM';
  static const String k_tital_qty = 'TOTAL QTY';
  static const String k_closed_bill = 'Closed Bill';
  static const String k_items_total = 'ITEMS TOTAL';
  static const String k_pax = 'Pax';
  static const String k_pos_title = 'POS Title';
  static const String k_rcpt = 'Rcpt#';
}
