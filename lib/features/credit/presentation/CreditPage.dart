// lib/features/credit/presentation/CreditPage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/features/credit/data/CreditModel.dart';
import 'package:pranomiapp/features/credit/data/CreditService.dart';
import 'package:pranomiapp/core/di/Injection.dart'; // Assuming locator is setup

class CreditPage extends StatefulWidget {
  const CreditPage({super.key});

  @override
  State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  late final CreditService _creditService;
  final List<CreditTransaction> _transactions = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  int _totalPages = 1;
  String? _error;

  // Formatters can be static if they don't depend on instance state
  static final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy HH:mm');
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
  );

  @override
  void initState() {
    super.initState();
    _creditService = locator<CreditService>();
    _scrollController.addListener(_onScroll);
    _fetchCreditTransactions(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCreditTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _transactions.clear();
        _error = null;
      });
    } else {
      if (_isLoadingMore || _currentPage >= _totalPages) return;
      setState(() {
        _isLoadingMore = true;
        _error = null;
      });
    }

    try {
      final creditItem = await _creditService.fetchCredits(
        page: _currentPage,
        size: 20,
      );

      if (mounted) {
        if (creditItem != null) {
          setState(() {
            _transactions.addAll(creditItem.creditTransactions);
            _currentPage = creditItem.currentPage + 1;
            _totalPages = creditItem.totalPages;
          });
        } else if (isRefresh) {
          _error = "Kredi hareketleri yüklenemedi.";
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Bir hata oluştu: ${e.toString()}";
        });
        debugPrint("Error fetching credit transactions: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _totalPages) {
      _fetchCreditTransactions();
    }
  }

  static String getTransactionTypeDescription(int type) {
    // Placeholder - implement actual logic
    return "İşlem Tipi: $type";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _CreditPageBody(
        isLoading: _isLoading,
        isLoadingMore: _isLoadingMore,
        error: _error,
        transactions: _transactions,
        scrollController: _scrollController,
        onRefresh: () => _fetchCreditTransactions(isRefresh: true),
        dateFormatter: _dateFormatter,
        currencyFormatter: _currencyFormatter,
        getTransactionTypeDescription: getTransactionTypeDescription,
      ),
    );
  }
}

// --- New Extracted Body Widget ---
class _CreditPageBody extends StatelessWidget {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final List<CreditTransaction> transactions;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final DateFormat dateFormatter;
  final NumberFormat currencyFormatter;
  final String Function(int) getTransactionTypeDescription;

  const _CreditPageBody({
    // key is not strictly needed here as it's a private widget, but good practice
    // super.key,
    required this.isLoading,
    required this.isLoadingMore,
    required this.error,
    required this.transactions,
    required this.scrollController,
    required this.onRefresh,
    required this.dateFormatter,
    required this.currencyFormatter,
    required this.getTransactionTypeDescription,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && transactions.isEmpty) {
      return const _LoadingView();
    }

    if (error != null && transactions.isEmpty) {
      return _ErrorView(error: error!, onRetry: onRefresh);
    }

    if (transactions.isEmpty) {
      return _EmptyView(onRefresh: onRefresh);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.all(12.0),
        itemCount: transactions.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == transactions.length) {
            return const _LoadingMoreIndicator();
          }
          final transaction = transactions[index];
          return _TransactionListItem(
            key: ValueKey(transaction.id),
            transaction: transaction,
            dateFormatter: dateFormatter,
            currencyFormatter: currencyFormatter,
            getTransactionTypeDescription: getTransactionTypeDescription,
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 6),
      ),
    );
  }
}

// --- Previously Extracted Widgets (remain the same) ---

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

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
              style: const TextStyle(color: Colors.red, fontSize: 16),
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
            ElevatedButton(onPressed: onRefresh, child: const Text("Yenile")),
          ],
        ),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final CreditTransaction transaction;
  final DateFormat dateFormatter;
  final NumberFormat currencyFormatter;
  final String Function(int) getTransactionTypeDescription;

  const _TransactionListItem({
    super.key,
    required this.transaction,
    required this.dateFormatter,
    required this.currencyFormatter,
    required this.getTransactionTypeDescription,
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
            Row(
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
                    color:
                        transaction.transactionAmount >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tarih: ${dateFormatter.format(transaction.transactionDate)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              getTransactionTypeDescription(transaction.transactionType),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
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
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
