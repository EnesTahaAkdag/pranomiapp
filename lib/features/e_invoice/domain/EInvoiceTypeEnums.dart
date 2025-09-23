enum EInvoiceTypeEnum { eInvoice, eArchive, eDespacth, gibEArchive }

EInvoiceTypeEnum parseEInvoceType(dynamic value) {
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'e_invoice':
        return EInvoiceTypeEnum.eInvoice;
      case 'earchive':
        return EInvoiceTypeEnum.eArchive;
      case 'edespacth':
        return EInvoiceTypeEnum.eDespacth;
      case 'gibearchive':
        return EInvoiceTypeEnum.gibEArchive;
    }
  }
  if (value is int) {
    switch (value) {
      case 1:
        return EInvoiceTypeEnum.eInvoice;
      case 2:
        return EInvoiceTypeEnum.eArchive;
      case 3:
        return EInvoiceTypeEnum.eDespacth;
      case 4:
        return EInvoiceTypeEnum.gibEArchive;
    }
  }

  throw Exception("Bilinmeyen E-Fatura Tipi: $value");
}
