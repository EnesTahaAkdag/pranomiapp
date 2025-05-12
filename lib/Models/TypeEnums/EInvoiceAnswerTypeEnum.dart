enum EInvoiceAnswerTypeEnum { approved, rejected }

EInvoiceAnswerTypeEnum parseInvoiceType(dynamic value) {
  switch (value) {
    case 'Approved':
    case 1:
      return EInvoiceAnswerTypeEnum.approved;
    case 'Rejected':
    case 2:
      return EInvoiceAnswerTypeEnum.rejected;
    default:
      throw Exception("Bilinmeyen Fatura Tipi: $value");
  }
}
