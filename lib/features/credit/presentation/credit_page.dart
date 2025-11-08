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
        _scrollController.position.maxScrollExtent -
            AppConstants.paginationScrollThreshold) {
      context.read<CreditViewModel>().loadMoreTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creditPageBackground,
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
  Widget _buildBalanceSummary(
    BuildContext context,
    List<CreditTransaction> transactions,
  ) {
    final currentBalance =
        transactions.isNotEmpty
            ? transactions.first.totalTransactionAmount
            : 0.0;

    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingM),
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        color: AppTheme.creditBalanceCardBackground,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: AppConstants.spacing20,
            offset: const Offset(0, AppConstants.spacing10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing10),
                decoration: BoxDecoration(
                  color: AppTheme.balanceCardOverlay,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppTheme.white,
                  size: AppConstants.iconSizeM,
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              const Text(
                'Mevcut Bakiye',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: AppConstants.fontSizeBalanceTitle,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          _AnimatedBalanceCounter(balance: currentBalance),
          const SizedBox(height: AppConstants.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing12,
              vertical: AppConstants.spacing6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.balanceCardOverlay,
              borderRadius: BorderRadius.circular(AppConstants.spacing20),
            ),
            child: Text(
              '${transactions.length} işlem',
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: AppConstants.fontSizeTransactionCount,
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
                  const Icon(
                    Icons.error_outline,
                    color: AppTheme.errorDarkText,
                    size: 20,
                  ),
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

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              decoration: const BoxDecoration(
                color: AppTheme.errorLightBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppTheme.errorColor,
                size: AppConstants.iconSizeXxl,
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeL,
                color: AppTheme.textBlack87,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXl),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Tekrar Dene"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingXl,
                  vertical: AppConstants.spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
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
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              decoration: const BoxDecoration(
                color: AppTheme.emptyStateIconBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppTheme.emptyStateIconColor,
                size: AppConstants.iconSize80 - AppConstants.spacingM,
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            const Text(
              'Henüz işlem yok',
              style: TextStyle(
                fontSize: AppConstants.fontSizeXxl,
                fontWeight: FontWeight.bold,
                color: AppTheme.emptyStateTitleColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            const Text(
              'Kredi hareketi bulunmamaktadır',
              style: TextStyle(
                fontSize: AppConstants.fontSizeM,
                color: AppTheme.emptyStateSubtitleColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXl),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Yenile"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingXl,
                  vertical: AppConstants.spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
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

  static final DateFormat _dateFormatter = DateFormat(
    'dd MMM yyyy, HH:mm',
    'tr_TR',
  );
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
  );

  const _TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.transactionAmount >= 0;
    final transactionColor = isPositive
        ? AppTheme.transactionIncomeColor
        : AppTheme.transactionExpenseColor;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.transactionCardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: AppTheme.transactionCardShadow,
            blurRadius: AppConstants.spacing10,
            offset: const Offset(0, AppConstants.elevationLow),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: transactionColor.withValues(alpha: 0.6),
                width: AppConstants.spacingXs,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacing10),
                      decoration: BoxDecoration(
                        color: transactionColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
                      ),
                      child: Icon(
                        _getTransactionIcon(transaction.transactionType),
                        color: transactionColor,
                        size: AppConstants.iconSizeM,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTransactionTypeDescription(
                              transaction.transactionType,
                            ),
                            style: const TextStyle(
                              fontSize: AppConstants.fontSizeTransactionType,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textBlack87,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingXs),
                          Text(
                            transaction.referenceNumber,
                            style: const TextStyle(
                              fontSize: AppConstants.fontSizeTransactionCount,
                              color: AppTheme.gray600,
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
                            fontSize: AppConstants.fontSizeTransactionAmount,
                            fontWeight: FontWeight.bold,
                            color: transactionColor,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingXs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingS,
                            vertical: AppConstants.spacingXs,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.transactionBadgeBackground,
                            borderRadius: BorderRadius.circular(AppConstants.spacing6),
                          ),
                          child: Text(
                            _currencyFormatter.format(
                              transaction.totalTransactionAmount,
                            ),
                            style: const TextStyle(
                              fontSize: AppConstants.fontSizeTransactionBadge,
                              color: AppTheme.transactionBadgeTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing12),
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacing12),
                  decoration: BoxDecoration(
                    color: AppTheme.transactionTimeBackground,
                    borderRadius: BorderRadius.circular(AppConstants.spacing10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: AppConstants.iconSizeS,
                        color: AppTheme.transactionTimeIconColor,
                      ),
                      const SizedBox(width: AppConstants.spacing6),
                      Text(
                        _dateFormatter.format(transaction.transactionDate),
                        style: const TextStyle(
                          fontSize: AppConstants.fontSizeTransactionCount,
                          color: AppTheme.transactionTimeTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (transaction.description != null &&
                    transaction.description!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacing12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.spacing12),
                    decoration: BoxDecoration(
                      color: AppTheme.descriptionBackgroundLight,
                      borderRadius: BorderRadius.circular(AppConstants.spacing10),
                      border: Border.all(
                        color: AppTheme.descriptionBorderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: AppConstants.iconSizeS,
                          color: AppTheme.descriptionTextColor,
                        ),
                        const SizedBox(width: AppConstants.spacingS),
                        Expanded(
                          child: Text(
                            transaction.description!,
                            style: const TextStyle(
                              fontSize: AppConstants.fontSizeTransactionCount,
                              color: AppTheme.descriptionTextColor,
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing20),
      child: Center(
        child: Column(
          children: [
            AppLoadingIndicator(),
            SizedBox(height: AppConstants.spacingS),
            Text(
              'Yükleniyor...',
              style: TextStyle(
                fontSize: AppConstants.fontSizeS,
                color: AppTheme.gray600,
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

  const _AnimatedBalanceCounter({required this.balance});

  @override
  State<_AnimatedBalanceCounter> createState() =>
      _AnimatedBalanceCounterState();
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedBalanceCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance) {
      _animation = Tween<double>(
        begin: oldWidget.balance,
        end: widget.balance,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
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
            color: AppTheme.white,
            fontSize: AppConstants.fontSizeBalanceAmount,
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
