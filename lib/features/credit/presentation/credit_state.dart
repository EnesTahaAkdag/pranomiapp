import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pranomiapp/features/credit/data/credit_model.dart';

part 'credit_state.freezed.dart';

/// Base state class for credit transactions
/// Following Single Responsibility Principle - each state represents one condition
@freezed
class CreditState with _$CreditState {
  const factory CreditState.initial() = _Initial;
  const factory CreditState.loading() = _Loading;
  const factory CreditState.loaded({
    required List<CreditTransaction> transactions,
    required int currentPage,
    required int totalPages,
    @Default(false) bool isLoadingMore,
  }) = _Loaded;

  const factory CreditState.error(
    String message, {
    @Default([]) List<CreditTransaction> existingTransactions,
  }) = _Error;
}




