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
  bool _isLoadingMore = false; // For loading indicator at the bottom
  int _currentPage = 0;
  int _totalPages = 1;
  String? _error;

  final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy HH:mm');
  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

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
    super.dispose();}

  Future<void> _fetchCreditTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _transactions.clear();
        _error = null;
      });
    } else {
      // Avoid multiple simultaneous loads for pagination
      if (_isLoadingMore || _currentPage >= _totalPages) return;
      setState(() {
        _isLoadingMore = true;
        _error = null;
      });
    }

    try {
      // Assuming CreditService.fetchCredits now returns CreditItem
      final creditItem = await _creditService.fetchCredits(
        page: _currentPage,
        size: 20, // Or your preferred page size
      );

      if (mounted) {
        if (creditItem != null) {
          setState(() {
            _transactions.addAll(creditItem.creditTransactions);
            _currentPage = creditItem.currentPage + 1; // Prepare for next page
            _totalPages = creditItem.totalPages;
          });
        } else if (isRefresh) {
          // Only set error if initial load fails and it's a refresh
          _error = "Kontör hareketleri yüklenemedi.";
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _totalPages) {
      _fetchCreditTransactions();
    }
  }

  String _getTransactionTypeDescription(int type) {
    // This is a placeholder. You should map type numbers to meaningful descriptions.
    // Example:
    // switch (type) {
    //   case 1: return "Gelen Havale";
    //   case 6: return "Satış";
    //   default: return "Diğer İşlem";
    // }
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _fetchCreditTransactions(isRefresh: true),
                child: const Text("Tekrar Dene"),
              ),
            ],
          ),
        ),
      );
    }

    if (_transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Kontör hareketi bulunmamaktadır.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _fetchCreditTransactions(isRefresh: true),
                child: const Text("Yenile"),
              ),
            ],
          ),
        ),
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
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final transaction = _transactions[index];
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _currencyFormatter.format(transaction.transactionAmount),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: transaction.transactionAmount >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tarih: ${_dateFormatter.format(transaction.transactionDate)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTransactionTypeDescription(transaction.transactionType),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  if (transaction.description != null && transaction.description!.isNotEmpty) ...[
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
        },
        separatorBuilder: (context, index) => const SizedBox(height: 6),
      ),
    );
  }
}
