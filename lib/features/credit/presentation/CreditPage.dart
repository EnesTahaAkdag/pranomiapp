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

  // Moved to static as it doesn't rely on instance members and can be reused or kept with model
  static String getTransactionTypeDescription(int type) {
    // This is a placeholder. You should map type numbers to meaningful descriptions.
    //  public enum PraNomiCustomerCreditTransactionTypeEnum : byte
    //  {
    //
    //  /*Diğer*/
    //      Other = 1,
    //
    // /*Nakit*/
    //      Cash = 2,
    //
    //  /*Havale/Eft*/
    //      BankEft = 3,
    //
    //  /*Kredi Kartı*/
    //      CreditCard = 4,
    //
    //  /*Hediye*/
    //      Gift = 5,
    //
    // /*E-Fatura*/
    //      eInvoice = 6,
    //
    //      /*E-Arşiv Fatura*/
    //      eArchive = 7,
    //
    //      /*E-İrsaliye*/
    //      eDespacth = 8,
    //  }
    // Example:
    // switch (type) {
    //   case 1: return "Gelen Havale";
    //   case 6: return "Satış";
    //   default: return "Diğer İşlem";
    // }
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

    }
    return "İşlem Tipi: $type"; // Replace with actual logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _transactions.isEmpty) {
      return const _LoadingView();
    }

    if (_error != null && _transactions.isEmpty) {
      return _ErrorView(
        error: _error!,
        onRetry: () => _fetchCreditTransactions(isRefresh: true),
      );
    }

    if (_transactions.isEmpty) {
      return _EmptyView(
        onRefresh: () => _fetchCreditTransactions(isRefresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchCreditTransactions(isRefresh: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(12.0),
        itemCount: _transactions.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _transactions.length) {
            return const _LoadingMoreIndicator();
          }
          final transaction = _transactions[index];
          return _TransactionListItem(
            key: ValueKey(transaction.id), // Use a key for better list performance
            transaction: transaction,
            dateFormatter: _dateFormatter,
            currencyFormatter: _currencyFormatter,
            getTransactionTypeDescription: getTransactionTypeDescription, // Pass static method
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 6),
      ),
    );
  }
}

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

class _TransactionListItem extends StatelessWidget {
  final CreditTransaction transaction;
  final DateFormat dateFormatter;
  final NumberFormat currencyFormatter;
  final String Function(int) getTransactionTypeDescription;


  const _TransactionListItem({
    super.key, // Pass the key here
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  currencyFormatter.format(transaction.transactionAmount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: transaction.transactionAmount >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tarih: ${dateFormatter.format(transaction.transactionDate)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              getTransactionTypeDescription(transaction.transactionType),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
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
