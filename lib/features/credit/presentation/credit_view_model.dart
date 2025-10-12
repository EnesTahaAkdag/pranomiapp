import 'package:flutter/foundation.dart';
import 'package:pranomiapp/features/credit/data/credit_service.dart';
import 'package:pranomiapp/features/credit/presentation/credit_state.dart';

/// ViewModel for Credit feature with pagination support
/// Following MVVM pattern with Provider for state management
/// Single Responsibility: Manages credit transactions business logic
class CreditViewModel extends ChangeNotifier {
  final CreditService _creditService;

  // Private state, exposed through getter
  CreditState _state = const CreditInitial();

  /// Current state of credit transactions
  CreditState get state => _state;

  /// Page size for pagination
  static const int _pageSize = 20;

  /// Constructor with dependency injection
  /// Following Dependency Inversion Principle
  CreditViewModel(this._creditService) {
    // Auto-load transactions when ViewModel is created
    fetchTransactions();
  }

  /// Fetches credit transactions (initial load)
  Future<void> fetchTransactions() async {
    // Set loading state
    _updateState(const CreditLoading());

    try {
      // Fetch first page
      final creditItem = await _creditService.fetchCredits(
        page: 0,
        size: _pageSize,
      );

      // Update state based on result
      if (creditItem != null) {
        _updateState(CreditLoaded(
          transactions: creditItem.creditTransactions,
          currentPage: creditItem.currentPage + 1, // +1 for next page
          totalPages: creditItem.totalPages,
        ));
      } else {
        _updateState(const CreditError('Kredi hareketleri yüklenemedi.'));
      }
    } catch (e) {
      // Handle errors gracefully
      final errorMessage = 'Bir hata oluştu: ${e.toString()}';
      _updateState(CreditError(errorMessage));
      debugPrint('Error fetching credit transactions: $e');
    }
  }

  /// Loads more transactions (pagination)
  Future<void> loadMoreTransactions() async {
    final currentState = _state;

    // Only load more if we're in loaded state and have more pages
    if (currentState is! CreditLoaded || !currentState.hasMorePages) {
      return;
    }

    // Prevent duplicate requests
    if (currentState.isLoadingMore) {
      return;
    }

    // Set loading more flag
    _updateState(currentState.copyWith(isLoadingMore: true));

    try {
      // Fetch next page
      final creditItem = await _creditService.fetchCredits(
        page: currentState.currentPage,
        size: _pageSize,
      );

      if (creditItem != null) {
        // Append new transactions to existing list
        final updatedTransactions = [
          ...currentState.transactions,
          ...creditItem.creditTransactions,
        ];

        _updateState(CreditLoaded(
          transactions: updatedTransactions,
          currentPage: creditItem.currentPage + 1,
          totalPages: creditItem.totalPages,
          isLoadingMore: false,
        ));
      } else {
        // Failed to load more, keep existing data
        _updateState(currentState.copyWith(isLoadingMore: false));
      }
    } catch (e) {
      // On error, keep existing data but show error with existing transactions
      _updateState(CreditError(
        'Daha fazla yüklenemedi: ${e.toString()}',
        existingTransactions: currentState.transactions,
      ));
      debugPrint('Error loading more transactions: $e');
    }
  }

  /// Refresh transactions (pull-to-refresh)
  Future<void> refresh() async {
    await fetchTransactions();
  }

  /// Updates state and notifies listeners
  /// Private method to ensure encapsulation
  void _updateState(CreditState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}