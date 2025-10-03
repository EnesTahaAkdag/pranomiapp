// lib/features/credit/data/CreditService.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Or foundation if only debugPrint is used
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/features/credit/data/CreditModel.dart'; // Make sure this is imported

class CreditService extends ApiServiceBase {
  Future<CreditItem?> fetchCredits({
    required int page,
    required int size,
    DateTime? transactionDate,
  }) {
    return getRequest<CreditItem>(
      path: 'EInvoice/CreditTransactions',
      queryParameters: {
        'page': page,
        'size': size,
        if (transactionDate != null)
          'transactionDate': transactionDate.toIso8601String(),
      },
      fromJson: (data) => CreditResponse.fromJson(data).item,
    );
  }
}

