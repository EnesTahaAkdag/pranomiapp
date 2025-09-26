import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/Models/AccountModels/AccountModels.dart';
import 'package:pranomiapp/services/AccountServers/AccountService.dart';
import 'package:pranomiapp/core/di/Injection.dart'; // Assuming locator is setup for AccountService

class AccountDepositAndBanksPage extends StatefulWidget {
  const AccountDepositAndBanksPage({super.key});

  @override
  State<AccountDepositAndBanksPage> createState() => _AccountDepositAndBanksPageState();
}

class _AccountDepositAndBanksPageState extends State<AccountDepositAndBanksPage> {
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = false;
  String _searchText = '';
  final List<AccountModel> _accounts = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Assuming AccountService is registered with your service locator (locator)
  final _accountService = locator<AccountService>();

  bool get _hasMore => _currentPage < _totalPages;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchAccounts(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoading) {
        _fetchAccounts();
      }
    }
  }

  Future<void> _fetchAccounts({bool reset = false}) async {
    if (_isLoading && !reset) return;

    setState(() => _isLoading = true);

    if (reset) {
      _currentPage = 0;
      _accounts.clear();
    }

    final response = await _accountService.fetchAccounts(
      page: _currentPage,
      size: 20,
      search: _searchText.isNotEmpty ? _searchText : null,
    );

    if (mounted) {
      if (response != null) {
        setState(() {
          // Assuming API's currentPage is 0-indexed, and we use it as such for the next page call.
          // If your API returns 1-indexed pages, adjust accordingly.
          _currentPage = response.currentPage + 1;
          _totalPages = response.totalPages;
          _accounts.addAll(response.accounts);
        });
      } else {
        debugPrint("Failed to fetch accounts or null response from service");
      }
      setState(() => _isLoading = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchText = '';
    _fetchAccounts(reset: true);
  }

  void _submitSearch(String val) {
    _searchText = val.trim();
    _fetchAccounts(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    // General formatter, symbol might be overridden per item
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      decimalDigits: 2,
      symbol: '₺',
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Hesaplar'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Hesap ara...',
                  suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSearch,
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: _submitSearch,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchAccounts(reset: true),
                child: _buildAccountList(currencyFormatter),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountList(NumberFormat defaultCurrencyFormatter) {
    if (_isLoading && _accounts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_accounts.isEmpty && !_isLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Center(
          child: Text(
            'Hiç hesap bulunamadı.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _accounts.length + (_isLoading && _accounts.isNotEmpty ? 1 : 0),
      itemBuilder: (ctx, idx) {
        if (idx < _accounts.length) {
          final account = _accounts[idx];
          // Use a specific formatter for the item if currency codes can vary
          final itemCurrencyFormatter = NumberFormat.currency(
            locale: 'tr_TR', // Or a locale appropriate for the currencyCode
            decimalDigits: 2,
            // Determine symbol based on currencyCode, fallback to currencyCode itself or default
            symbol: account.currencyCode == "TRY" ? "₺" :
            (account.currencyCode == "USD" ? "\$" :
            (account.currencyCode == "EUR" ? "€" : account.currencyCode)),
          );

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(account.accountName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tür: ${account.accountType}'),
                  Text('Bakiye: ${itemCurrencyFormatter.format(account.balance)}'),
                ],
              ),
              // onTap: () {
              //   // TODO: Navigate to an Account Detail Page if needed
              //   // context.push('/accountDetail', extra: account.accountId);
              // },
            ),
          );
        }
        if (_isLoading && _accounts.isNotEmpty) {
          // Loading indicator at the bottom for pagination
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return const SizedBox.shrink(); // Should not be reached if itemCount is correct
      },
    );
  }
}
