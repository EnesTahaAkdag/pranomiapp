enum EInvoiceTypeEnum { eInvoice, eArchive, eDespacth, gibEArchive }

EInvoiceTypeEnum parseEInvoceType(dynamic value) {
  switch (value) {
    case 'eInvoice':
    case 1:
      return EInvoiceTypeEnum.eInvoice;
    case 'eArchive':
    case 2:
      return EInvoiceTypeEnum.eArchive;
    case 'eDespacth':
    case 3:
      return EInvoiceTypeEnum.eDespacth;
    case 'GibEArchive':
    case 4:
      return EInvoiceTypeEnum.gibEArchive;
    default:
      throw Exception("Bilinmeyen E-Fatura Tipi: $value");
  }
}
