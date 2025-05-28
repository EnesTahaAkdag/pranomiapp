class EInvoiceCancelModel {
  final String uuId;
  final String answerCode;
  final String rejectedNote;
  final String documentNumber;

  EInvoiceCancelModel({
    required this.uuId,
    required this.answerCode,
    required this.rejectedNote,
    required this.documentNumber,
  });

  Map<String, dynamic> toJson() => {
    'UUID': uuId,
    'AnswerCode': answerCode,
    'RejectedNote': rejectedNote,
    'DocumentNumber': documentNumber,
  };

  factory EInvoiceCancelModel.fromJson(Map<String, dynamic> json) {
    return EInvoiceCancelModel(
      uuId: json['UUID'] ?? "",
      answerCode: json['AnswerCode'] ?? "",
      rejectedNote: json['RejectedNote'] ?? "",
      documentNumber: json['DocumentNumber'] ?? "",
    );
  }
}
