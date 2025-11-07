import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/core/utils/app_constants.dart';
import 'package:pranomiapp/core/widgets/app_loading_indicator.dart';
import 'package:pranomiapp/features/credit/data/credit_model.dart';
import 'package:pranomiapp/features/credit/data/credit_service.dart';
import 'package:pranomiapp/features/credit/presentation/credit_state.dart';
import 'package:pranomiapp/features/credit/presentation/credit_view_model.dart';
import 'package:provider/provider.dart';

/// Credit Page - MVVM Pattern with Provider
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

/// Main view widget
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - AppConstants.paginationScrollThreshold) {
      context.read<CreditViewModel>().loadMoreTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<CreditViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(context, viewModel);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CreditViewModel viewModel) {
    final state = viewModel.state;

    return state.map(
      initial: (_) => const SizedBox.shrink(),
      loading: (_) => const Center(child: AppLoadingIndicator()),
      loaded: (loadedState) {
        if (loadedState.transactions.isEmpty) {
          return _EmptyView(onRefresh: viewModel.refresh);
        }

        return Column(
          children: [
            _buildBalanceSummary(context, loadedState.transactions),
            Expanded(
              child: _buildTransactionsList(
                context,
                viewModel,
                loadedState.transactions,
                isLoadingMore: loadedState.isLoadingMore,
              ),
            ),
          ],
        );
      },
      error: (errorState) {
        if (errorState.existingTransactions.isNotEmpty) {
          return Column(
            children: [
              _buildBalanceSummary(context, errorState.existingTransactions),
              Expanded(
                child: _buildTransactionsList(
                  context,
                  viewModel,
                  errorState.existingTransactions,
                  isLoadingMore: false,
                  hasError: true,
                  errorMessage: errorState.message,
                ),
              ),
            ],
          );
        }
        return _ErrorView(
          error: errorState.message,
          onRetry: viewModel.fetchTransactions,
        );
      },
    );
  }

  /// Builds balance summary card at the top
  Widget _buildBalanceSummary(BuildContext context, List<CreditTransaction> transactions) {
    final currentBalance = transactions.isNotEmpty
        ? transactions.first.totalTransactionAmount
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blueAccent,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mevcut Bakiye',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AnimatedBalanceCounter(
            balance: currentBalance,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${transactions.length} işlem',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          if (hasError)
            Container(
              width: double.infinity,
              color: AppTheme.errorLightBackground,
              padding: const EdgeInsets.all(AppConstants.spacingS),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.errorDarkText, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage ?? 'Bir hata oluştu',
                      style: const TextStyle(color: AppTheme.errorDarkText),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// UI COMPONENTS
// ============================================================================

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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.errorLightBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppTheme.errorColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Tekrar Dene"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: Colors.grey[400],
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz işlem yok',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kredi hareketi bulunmamaktadır',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Yenile"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final CreditTransaction transaction;

  static final DateFormat _dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR');
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
    final isPositive = transaction.transactionAmount >= 0;
    final transactionColor = isPositive ? Colors.green : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: transactionColor.withOpacity(0.6),
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: transactionColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTransactionIcon(transaction.transactionType),
                        color: transactionColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTransactionTypeDescription(transaction.transactionType),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction.referenceNumber,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isPositive ? '+' : ''}${_currencyFormatter.format(transaction.transactionAmount)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: transactionColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _currencyFormatter.format(transaction.totalTransactionAmount),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        _dateFormatter.format(transaction.transactionDate),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            transaction.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[900],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            const AppLoadingIndicator(),
            const SizedBox(height: 8),
            Text(
              'Yükleniyor...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated counter widget for balance display
/// Animates from 0 to the target balance value with smooth easing
class _AnimatedBalanceCounter extends StatefulWidget {
  final double balance;

  const _AnimatedBalanceCounter({
    required this.balance,
  });

  @override
  State<_AnimatedBalanceCounter> createState() => _AnimatedBalanceCounterState();
}

class _AnimatedBalanceCounterState extends State<_AnimatedBalanceCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: AppConstants.loadingAnimationDuration),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.balance,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedBalanceCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance) {
      _animation = Tween<double>(
        begin: oldWidget.balance,
        end: widget.balance,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _currencyFormatter.format(_animation.value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

IconData _getTransactionIcon(int type) {
  switch (type) {
    case 2:
      return Icons.payments_rounded; // Nakit
    case 3:
      return Icons.account_balance_rounded; // Havale/Eft
    case 4:
      return Icons.credit_card_rounded; // Kredi Kartı
    case 5:
      return Icons.card_giftcard_rounded; // Hediye
    case 6:
      return Icons.receipt_rounded; // E-Fatura
    case 7:
      return Icons.archive_rounded; // E-Arşiv
    case 8:
      return Icons.local_shipping_rounded; // E-İrsaliye
    default:
      return Icons.swap_horiz_rounded; // Diğer
  }
}

String _getTransactionTypeDescription(int type) {
  switch (type) {
    case 1:
      return "Diğer";
    case 2:
      return "Nakit";
    case 3:
      return "Havale/EFT";
    case 4:
      return "Kredi Kartı";
    case 5:
      return "Hediye";
    case 6:
      return "E-Fatura";
    case 7:
      return "E-Arşiv Fatura";
    case 8:
      return "E-İrsaliye";
    default:
      return "İşlem";
  }
}