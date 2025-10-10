class SendEInvoiceModel {
  final int invoiceId;
  final String email;
  final String invoiceNote;

  SendEInvoiceModel({
    required this.invoiceId,
    required this.email,
    required this.invoiceNote,
  });

  Map<String, dynamic> toJson() => {
    'InvoiceId': invoiceId,
    'Email': email,
    'InvoiceNote': invoiceNote,
  };
}

class SendEInvoiceResponseModel {
  final bool success;
  final String item;
  final List<String> errorMessages;
  final List<String> successMessages;
  final List<String> warningMessages;

  SendEInvoiceResponseModel({
    required this.success,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory SendEInvoiceResponseModel.fromJson(Map<String, dynamic> json) {
    return SendEInvoiceResponseModel(
      success: json['Success'],
      item: json['Item'].toString(),
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}
