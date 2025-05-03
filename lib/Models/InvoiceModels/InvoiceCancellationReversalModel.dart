class InvoiceCancellationReversalModel {
  final String documentNumber;

  InvoiceCancellationReversalModel({required this.documentNumber});

  Map<String, dynamic> toJson() => {'DocumentNumber': documentNumber};
}

class InvoiceCancellationReversalResponseModel {
  final bool success;
  final String item;
  final List<String> errorMessages;
  final List<String> successMessages;
  final List<String> warningMessages;

  InvoiceCancellationReversalResponseModel({
    required this.success,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory InvoiceCancellationReversalResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvoiceCancellationReversalResponseModel(
      success: json['Success'],
      item: json['Item'].toString(),
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}
