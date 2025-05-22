class EInvoiceOpenAsPdfModel {
  final bool success;
  final int statusCode;
  final String item;
  final List<String> errorMessages;
  final List<String> successMessages;
  final List<String> warningMessages;

  EInvoiceOpenAsPdfModel({
    required this.success,
    required this.statusCode,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory EInvoiceOpenAsPdfModel.fromJson(Map<String, dynamic> json) {
    return EInvoiceOpenAsPdfModel(
      success: json['Success'],
      statusCode: json['StatusCode'],
      item: json['Item'].toString(),
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}
