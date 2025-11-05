import 'package:pranomiapp/features/credit/data/credit_model.dart';

/// Base state class for credit transactions
/// Following Single Responsibility Principle - each state represents one condition
class CreditState {
  const CreditState();
}

/// Initial state before any data is loaded
class CreditInitial extends CreditState {
  const CreditInitial();
}

/// Loading state when fetching initial data
class CreditLoading extends CreditState {
  const CreditLoading();
}

/// Success state with loaded credit transactions
class CreditLoaded extends CreditState {
  final List<CreditTransaction> transactions;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;

  const CreditLoaded({
    required this.transactions,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
  });

  /// Convenience getters
  bool get isEmpty => transactions.isEmpty;
  bool get isNotEmpty => transactions.isNotEmpty;
  bool get hasMorePages => currentPage < totalPages;
  int get count => transactions.length;

  /// Copy with method for state updates (useful for pagination)
  CreditLoaded copyWith({
    List<CreditTransaction>? transactions,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return CreditLoaded(
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Error state with error message
class CreditError extends CreditState {
  final String message;
  final List<CreditTransaction> existingTransactions;

  const CreditError(
    this.message, {
    this.existingTransactions = const [],
  });

  bool get hasExistingData => existingTransactions.isNotEmpty;
}