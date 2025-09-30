import 'dart:convert';

class CreditResponse {
  final bool success;
  final int statusCode;
  final CreditItem item;

  CreditResponse({
    required this.success,
    required this.statusCode,
    required this.item,
  });

  factory CreditResponse.fromJson(Map<String, dynamic> json) {
    return CreditResponse(
      success: json['Success'] ?? false,
      statusCode: json['StatusCode'] ?? 0,
      item: CreditItem.fromJson(json['Item']),
    );
  }
}

class CreditItem {
  final int count;
  final int currentPage;
  final int currentSize;
  final int totalPages;
  final List<CreditTransaction> creditTransactions;

  CreditItem({
    required this.count,
    required this.currentPage,
    required this.currentSize,
    required this.totalPages,
    required this.creditTransactions,
  });

  factory CreditItem.fromJson(Map<String, dynamic> json) {
    return CreditItem(
      count: json['Count'] ?? 0,
      currentPage: json['CurrentPage'] ?? 0,
      currentSize: json['CurrentSize'] ?? 0,
      totalPages: json['TotalPages'] ?? 0,
      creditTransactions: (json['creditTransactions'] as List<dynamic>)
          .map((e) => CreditTransaction.fromJson(e))
          .toList(),
    );
  }
}

class CreditTransaction {
  final int id;
  final DateTime transactionDate;
  final int transactionType;
  final String referenceNumber;
  final String? description;
  final double transactionAmount;
  final double totalTransactionAmount;

  CreditTransaction({
    required this.id,
    required this.transactionDate,
    required this.transactionType,
    required this.referenceNumber,
    this.description,
    required this.transactionAmount,
    required this.totalTransactionAmount,
  });

  factory CreditTransaction.fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: json['Id'] ?? 0,
      transactionDate: DateTime.parse(json['TransactionDate']),
      transactionType: json['TransactionType'] ?? 0,
      referenceNumber: json['ReferenceNumber'] ?? "",
      description: json['Description'],
      transactionAmount: (json['TransactionAmount'] as num).toDouble(),
      totalTransactionAmount: (json['TotalTransactionAmount'])
    );
  }
}