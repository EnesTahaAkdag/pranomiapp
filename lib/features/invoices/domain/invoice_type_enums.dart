enum InvoiceTypeEnum {
  incomeInvoice,
  expenseInvoice,
  incomeOrder,
  expenseOrder,
  incomeWayBill,
  expenseWayBill,
}

InvoiceTypeEnum parseInvoiceType(dynamic value) {
  switch (value) {
    case 'IncomeInvoice':
    case 1:
      return InvoiceTypeEnum.incomeInvoice;
    case 'ExpenseInvoice':
    case 2:
      return InvoiceTypeEnum.expenseInvoice;
    case 'IncomeOrder':
    case 3:
      return InvoiceTypeEnum.incomeOrder;
    case 'ExpenseOrder':
    case 4:
      return InvoiceTypeEnum.expenseOrder;
    case 'IncomeWayBill':
    case 5:
      return InvoiceTypeEnum.incomeWayBill;
    case 'ExpenseWayBill':
    case 6:
      return InvoiceTypeEnum.expenseWayBill;
    default:
      throw Exception("Bilinmeyen Fatura Tipi: $value");
  }
}
