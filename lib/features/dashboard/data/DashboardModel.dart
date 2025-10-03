class DashboardResponse {
  final bool success;
  final int statusCode;
  final DashboardItem? item;
  final List<String> errorMessages;
  final List<String> successMessages;
  final List<String> warningMessages;

  DashboardResponse({
    required this.success,
    required this.statusCode,
    this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['Success'] ?? false,
      statusCode: json['StatusCode'] ?? 0,
      item: json['Item'] != null
          ? DashboardItem.fromJson(json['Item'])
          : null,
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Success': success,
      'StatusCode': statusCode,
      'Item': item?.toJson(),
      'ErrorMessages': errorMessages,
      'SuccessMessages': successMessages,
      'WarningMessages': warningMessages,
    };
  }
}

// Dashboard Item Model
class DashboardItem {
  final double totalCashAccountBalance;
  final List<BankAccountBalance> totalBankAccountBalances;
  final double activeCustomerAccountReceiving;
  final double activeCustomerAccountPayment;
  final double nextCustomerAccountReceiving;
  final double nextCustomerAccountPayment;
  final double totalIncomeAmount;
  final double totalExpenseAmount;
  final double activeInvoiceReceiving;
  final double nextInvoiceReceiving;
  final double activeInvoicePayment;
  final double nextInvoicePayment;
  final double activeChequeReceiving;
  final double nextChequeReceiving;
  final double activeChequePayment;
  final double nextChequePayment;
  final double activeDeedPayment;
  final double activeDeedReceiving;
  final double nextDeedPayment;
  final double nextDeedReceiving;

  DashboardItem({
    required this.totalCashAccountBalance,
    required this.totalBankAccountBalances,
    required this.activeCustomerAccountReceiving,
    required this.activeCustomerAccountPayment,
    required this.nextCustomerAccountReceiving,
    required this.nextCustomerAccountPayment,
    required this.totalIncomeAmount,
    required this.totalExpenseAmount,
    required this.activeInvoiceReceiving,
    required this.nextInvoiceReceiving,
    required this.activeInvoicePayment,
    required this.nextInvoicePayment,
    required this.activeChequeReceiving,
    required this.nextChequeReceiving,
    required this.activeChequePayment,
    required this.nextChequePayment,
    required this.activeDeedPayment,
    required this.activeDeedReceiving,
    required this.nextDeedPayment,
    required this.nextDeedReceiving,
  });

  factory DashboardItem.fromJson(Map<String, dynamic> json) {
    return DashboardItem(
      totalCashAccountBalance: (json['TotalCashAccountBalance'] ?? 0).toDouble(),
      totalBankAccountBalances: (json['TotalBankAccountBalances'] as List?)
          ?.map((e) => BankAccountBalance.fromJson(e))
          .toList() ?? [],
      activeCustomerAccountReceiving: (json['ActiveCustomerAccountReceiving'] ?? 0).toDouble(),
      activeCustomerAccountPayment: (json['ActiveCustomerAccountPayment'] ?? 0).toDouble(),
      nextCustomerAccountReceiving: (json['NextCustomerAccountReceiving'] ?? 0).toDouble(),
      nextCustomerAccountPayment: (json['NextCustomerAccountPayment'] ?? 0).toDouble(),
      totalIncomeAmount: (json['TotalIncomeAmount'] ?? 0).toDouble(),
      totalExpenseAmount: (json['TotalExpenseAmount'] ?? 0).toDouble(),
      activeInvoiceReceiving: (json['ActiveInvoiceReceiving'] ?? 0).toDouble(),
      nextInvoiceReceiving: (json['NextInvoiceReceiving'] ?? 0).toDouble(),
      activeInvoicePayment: (json['ActiveInvoicePayment'] ?? 0).toDouble(),
      nextInvoicePayment: (json['NextInvoicePayment'] ?? 0).toDouble(),
      activeChequeReceiving: (json['ActiveChequeReceiving'] ?? 0).toDouble(),
      nextChequeReceiving: (json['NextChequeReceiving'] ?? 0).toDouble(),
      activeChequePayment: (json['ActiveChequePayment'] ?? 0).toDouble(),
      nextChequePayment: (json['NextChequePayment'] ?? 0).toDouble(),
      activeDeedPayment: (json['ActiveDeedPayment'] ?? 0).toDouble(),
      activeDeedReceiving: (json['ActiveDeedReceiving'] ?? 0).toDouble(),
      nextDeedPayment: (json['NextDeedPayment'] ?? 0).toDouble(),
      nextDeedReceiving: (json['NextDeedReceiving'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TotalCashAccountBalance': totalCashAccountBalance,
      'TotalBankAccountBalances': totalBankAccountBalances.map((e) => e.toJson()).toList(),
      'ActiveCustomerAccountReceiving': activeCustomerAccountReceiving,
      'ActiveCustomerAccountPayment': activeCustomerAccountPayment,
      'NextCustomerAccountReceiving': nextCustomerAccountReceiving,
      'NextCustomerAccountPayment': nextCustomerAccountPayment,
      'TotalIncomeAmount': totalIncomeAmount,
      'TotalExpenseAmount': totalExpenseAmount,
      'ActiveInvoiceReceiving': activeInvoiceReceiving,
      'NextInvoiceReceiving': nextInvoiceReceiving,
      'ActiveInvoicePayment': activeInvoicePayment,
      'NextInvoicePayment': nextInvoicePayment,
      'ActiveChequeReceiving': activeChequeReceiving,
      'NextChequeReceiving': nextChequeReceiving,
      'ActiveChequePayment': activeChequePayment,
      'NextChequePayment': nextChequePayment,
      'ActiveDeedPayment': activeDeedPayment,
      'ActiveDeedReceiving': activeDeedReceiving,
      'NextDeedPayment': nextDeedPayment,
      'NextDeedReceiving': nextDeedReceiving,
    };
  }
}

// Bank Account Balance Model
class BankAccountBalance {
  final String currencyCode;
  final double totalBankAccountBalance;

  BankAccountBalance({
    required this.currencyCode,
    required this.totalBankAccountBalance,
  });

  factory BankAccountBalance.fromJson(Map<String, dynamic> json) {
    return BankAccountBalance(
      currencyCode: json['CurrencyCode'] ?? '',
      totalBankAccountBalance: (json['TotalBankAccountBalance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CurrencyCode': currencyCode,
      'TotalBankAccountBalance': totalBankAccountBalance,
    };
  }
}