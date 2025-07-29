class AccountAddResponseModel {
  List<String> errorMessages;
  List<String> successMessages;
  List<String> warningMessages;

  AccountAddResponseModel({
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory AccountAddResponseModel.fromJson(Map<String, dynamic> json) {
    return AccountAddResponseModel(
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}

class AccountAddModel {
  int? amount;
  String? description;
  int? customerId;
  int? accountId;
  int? chequeId;
  bool? isCheque;
  DateTime? date;
  DateTime? dueDate;
  int? bankId;
  String? chequeNumber;
  int? currencyId;
  String? customerType;
  int? invoiceId;
  String? paymentType;
  bool? isPayment;

  AccountAddModel({
    this.amount,
    this.description,
    this.customerId,
    this.accountId,
    this.chequeId,
    this.isCheque,
    this.date,
    this.dueDate,
    this.bankId,
    this.chequeNumber,
    this.currencyId,
    this.customerType,
    this.invoiceId,
    this.paymentType,
    this.isPayment,
  });

  Map<String, dynamic> toJson() {
    return {
      'Amount': amount,
      'Description': description,
      'CustomerId': customerId,
      'AccountId': accountId,
      'ChequeId': chequeId,
      'IsCheque': isCheque,
      'Date': date?.toIso8601String(),
      'DueDate': dueDate?.toIso8601String(),
      'BankId': bankId,
      'ChequeNumber': chequeNumber,
      'CurrencyId': currencyId,
      'CustomerType': customerType,
      'InvoiceId': invoiceId,
      'PaymentType': paymentType,
      'IsPayment': isPayment,
    };
  }
}

// {
//   "Amount": 0,
//   "Description": "string",
//   "CustomerId": 0,
//   "AccountId": 0,
//   "ChequeId": 0,
//   "IsCheque": true,
//   "Date": "2025-07-14T06:37:57.592Z",
//   "DueDate": "2025-07-14T06:37:57.592Z",
//   "BankId": 0,
//   "ChequeNumber": "string",
//   "CurrencyId": 0,
//   "CustomerType": "Customer",
//   "InvoiceId": 0,
//   "PaymentType": "Customer",
//   "IsPayment": true
// }
