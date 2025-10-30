import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/features/credit/data/credit_model.dart';
import 'package:pranomiapp/features/credit/data/credit_service.dart';
import 'package:pranomiapp/features/credit/presentation/credit_state.dart';
import 'package:pranomiapp/features/credit/presentation/credit_view_model.dart';
import 'package:provider/provider.dart';

/// Credit Page - MVVM Pattern with Provider
/// Following Single Responsibility: Only handles UI composition
class CreditPage extends StatelessWidget {
  const CreditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreditViewModel(locator<CreditService>()),
      child: const _CreditView(),
    );
  }
}

/// Main view widget - Listens to ViewModel changes
class _CreditView extends StatefulWidget {
  const _CreditView();

  @override
  State<_CreditView> createState() => _CreditViewState();
}

class _CreditViewState extends State<_CreditView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger load more when near bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CreditViewModel>().loadMoreTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CreditViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(context, viewModel);
        },
      ),
    );
  }

  /// Builds body based on current state
  Widget _buildBody(BuildContext context, CreditViewModel viewModel) {
    final state = viewModel.state;

    // Pattern matching on state type
    if (state is CreditLoading) {
      return  Center(child:  LoadingAnimationWidget.staggeredDotsWave(
        // LoadingAnimationwidget that call the
        color: AppTheme.accentColor, // staggereddotwave animation
        size: 50,
      ));
    }

    if (state is CreditError) {
      // Show error with existing data if available
      if (state.hasExistingData) {
        return _buildTransactionsList(
          context,
          viewModel,
          state.existingTransactions,
          isLoadingMore: false,
          hasError: true,
          errorMessage: state.message,
        );
      }
      return _ErrorView(
        error: state.message,
        onRetry: viewModel.fetchTransactions,
      );
    }

    if (state is CreditLoaded) {
      if (state.isEmpty) {
        return _EmptyView(onRefresh: viewModel.refresh);
      }

      return _buildTransactionsList(
        context,
        viewModel,
        state.transactions,
        isLoadingMore: state.isLoadingMore,
      );
    }

    // Initial state or unknown state
    return const SizedBox.shrink();
  }

  /// Builds the transactions list with pagination
  Widget _buildTransactionsList(
    BuildContext context,
    CreditViewModel viewModel,
    List<CreditTransaction> transactions, {
    required bool isLoadingMore,
    bool hasError = false,
    String? errorMessage,
  }) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: Column(
        children: [
          if (hasError)
            Container(
              width: double.infinity,
              color: AppTheme.errorLightBackground,
              padding: const EdgeInsets.all(8),
              child: Text(
                errorMessage ?? 'Bir hata oluştu',
                style: const TextStyle(color: AppTheme.errorDarkText),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(12.0),
              itemCount: transactions.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == transactions.length) {
                  return const _LoadingMoreIndicator();
                }
                final transaction = transactions[index];
                return _TransactionCard(
                  key: ValueKey(transaction.id),
                  transaction: transaction,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 6),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REUSABLE UI COMPONENTS (Following Single Responsibility Principle)
// ============================================================================

/// Error view widget
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.errorColor, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Tekrar Dene"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state view widget
class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Kredi hareketi bulunmamaktadır.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text("Yenile"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction card widget - Encapsulates single transaction display
class _TransactionCard extends StatelessWidget {
  final CreditTransaction transaction;

  // Static formatters for performance
  static final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy HH:mm');
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
  );

  const _TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TransactionHeader(
              transaction: transaction,
              currencyFormatter: _currencyFormatter,
            ),
            const SizedBox(height: 8),
            _TransactionDetails(
              transaction: transaction,
              dateFormatter: _dateFormatter,
              currencyFormatter: _currencyFormatter,
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction header with reference number and amount
class _TransactionHeader extends StatelessWidget {
  final CreditTransaction transaction;
  final NumberFormat currencyFormatter;

  const _TransactionHeader({
    required this.transaction,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            transaction.referenceNumber,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          currencyFormatter.format(transaction.transactionAmount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: transaction.transactionAmount >= 0
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
              ),
        ),
      ],
    );
  }
}

/// Transaction details (date, balance, type, description)
class _TransactionDetails extends StatelessWidget {
  final CreditTransaction transaction;
  final DateFormat dateFormatter;
  final NumberFormat currencyFormatter;

  const _TransactionDetails({
    required this.transaction,
    required this.dateFormatter,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarih: ${dateFormatter.format(transaction.transactionDate)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textGray,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bakiye: ${currencyFormatter.format(transaction.totalTransactionAmount)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          _getTransactionTypeDescription(transaction.transactionType),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textGray,
              ),
        ),
        if (transaction.description != null &&
            transaction.description!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Açıklama: ${transaction.description}',
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// Loading more indicator
class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child:  LoadingAnimationWidget.staggeredDotsWave(
        // LoadingAnimationwidget that call the
        color: AppTheme.accentColor, // staggereddotwave animation
        size: 50,
      )),
    );
  }
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Maps transaction type to human-readable description
String _getTransactionTypeDescription(int type) {
  switch (type) {
    case 1:
      return "Diğer";
    case 2:
      return "Nakit";
    case 3:
      return "Havale/Eft";
    case 4:
      return "Kredi Kartı";
    case 5:
      return "Hediye";
    case 6:
      return "E-Fatura";
    case 7:
      return "E-Arşive Fatura";
    case 8:
      return "E-İrsaliye";
    default:
      return "İşlem Tipi: $type";
  }
}