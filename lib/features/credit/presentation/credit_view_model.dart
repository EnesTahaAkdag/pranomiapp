import 'package:flutter/foundation.dart';
import 'package:pranomiapp/features/credit/data/credit_service.dart';
import 'package:pranomiapp/features/credit/presentation/credit_state.dart';

/// ViewModel for Credit feature with pagination support
/// Following MVVM pattern with Provider for state management
/// Single Responsibility: Manages credit transactions business logic
class CreditViewModel extends ChangeNotifier {
  final CreditService _creditService;

  // Private state, exposed through getter
  CreditState _state = const CreditState.initial();

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
    _updateState(const CreditState.loading());

    try {
      // Fetch first page
      final creditItem = await _creditService.fetchCredits(
        page: 0,
        size: _pageSize,
      );

      // Update state based on result
      if (creditItem != null) {
        _updateState(CreditState.loaded(
          transactions: creditItem.creditTransactions,
          currentPage: creditItem.currentPage + 1, // +1 for next page
          totalPages: creditItem.totalPages,
        ));
      } else {
        _updateState(const CreditState.error('Kredi hareketleri yüklenemedi.'));
      }
    } catch (e) {
      // Handle errors gracefully
      final errorMessage = 'Bir hata oluştu: ${e.toString()}';
      _updateState(CreditState.error(errorMessage));
      debugPrint('Error fetching credit transactions: $e');
    }
  }

  /// Loads more transactions (pagination)
  Future<void> loadMoreTransactions() async {
    // Use freezed's mapOrNull to handle only the loaded state
    await _state.mapOrNull(
      loaded: (loadedState) async {
        // Check if we have more pages
        final hasMorePages = loadedState.currentPage < loadedState.totalPages;

        // Only load more if we have more pages and not already loading
        if (!hasMorePages || loadedState.isLoadingMore) {
          return;
        }

        // Set loading more flag - using copyWith for cleaner code
        _updateState(loadedState.copyWith(isLoadingMore: true));

        try {
          // Fetch next page
          final creditItem = await _creditService.fetchCredits(
            page: loadedState.currentPage,
            size: _pageSize,
          );

          if (creditItem != null) {
            // Append new transactions to existing list
            final updatedTransactions = [
              ...loadedState.transactions,
              ...creditItem.creditTransactions,
            ];

            // Update with new data - using copyWith for clarity
            _updateState(loadedState.copyWith(
              transactions: updatedTransactions,
              currentPage: creditItem.currentPage + 1,
              totalPages: creditItem.totalPages,
              isLoadingMore: false,
            ));
          } else {
            // Failed to load more, keep existing data - only update the loading flag
            _updateState(loadedState.copyWith(isLoadingMore: false));
          }
        } catch (e) {
          // On error, keep existing data but show error with existing transactions
          _updateState(CreditState.error(
            'Daha fazla yüklenemedi: ${e.toString()}',
            existingTransactions: loadedState.transactions,
          ));
          debugPrint('Error loading more transactions: $e');
        }
      },
    );
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