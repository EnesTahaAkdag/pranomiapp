class InvoiceCancelModel {
  final String documentNumber;

  InvoiceCancelModel({required this.documentNumber});

  Map<String, dynamic> toJson() => {'DocumentNumber': documentNumber};
}

class InvoiceCancelResponseModel {
  final bool success;
  final String item;
  final List<String> errorMessages;
  final List<String> successMessages;
  final List<String> warningMessages;

  InvoiceCancelResponseModel({
    required this.success,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory InvoiceCancelResponseModel.fromJson(Map<String, dynamic> json) {
    return InvoiceCancelResponseModel(
      success: json['Success'],
      item: json['Item'].toString(),
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}
