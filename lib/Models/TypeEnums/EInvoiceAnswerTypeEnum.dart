enum EInvoiceAnswerTypeEnum { approved, outgoing }

EInvoiceAnswerTypeEnum parseInvoiceType(dynamic value) {
  switch (value) {
    case 'Approved':
    case 1:
      return EInvoiceAnswerTypeEnum.approved;
    case 'Rejected':
    case 2:
      return EInvoiceAnswerTypeEnum.outgoing;
    default:
      throw Exception("Bilinmeyen Fatura Tipi: $value");
  }
}
