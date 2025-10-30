// lib/features/credit/data/credit_service.dart
import 'package:pranomiapp/features/credit/data/credit_model.dart'; // Make sure this is imported

import '../../../core/services/api_service_base.dart';

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

