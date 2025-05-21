// ignore: file_names, constant_identifier_names
enum EInvoiceAnswerTypeEnum { Approved, Outgoing }

EInvoiceAnswerTypeEnum parseInvoiceType(dynamic value) {
  switch (value) {
    case 'outgoing':
    case 1:
      return EInvoiceAnswerTypeEnum.Outgoing;
    case 'approved':
    case 2:
      return EInvoiceAnswerTypeEnum.Approved;
    default:
      throw Exception("Bilinmeyen Fatura Tipi: $value");
  }
}
