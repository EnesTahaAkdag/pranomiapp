class InvoiceSendEInvoiceModel {
  final int invoiceId;
  final String email;
  final String invoiceNote;

  InvoiceSendEInvoiceModel({
    required this.invoiceId,
    required this.email,
    required this.invoiceNote,
  });
  factory InvoiceSendEInvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceSendEInvoiceModel(
      invoiceId: json['InvoiceId'],
      email: json['Email'],
      invoiceNote: json['InvoiceNote'],
    );
  }
}

class InvoiceSendEInvoiceResponseModel {
  final bool success;
  final int item;
  final List<String> errorMessages;
  final List<String> successMessages;
  final List<String> warningMessages;

  InvoiceSendEInvoiceResponseModel({
    required this.success,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory InvoiceSendEInvoiceResponseModel.fromJson(Map<String, dynamic> json) {
    return InvoiceSendEInvoiceResponseModel(
      success: json['Success'],
      item: json['Item'],
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}
