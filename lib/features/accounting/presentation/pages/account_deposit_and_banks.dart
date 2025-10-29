import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/account_models.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../data/services/account_service.dart';
import '../../../../core/di/injection.dart';

import '../widgets/account_list_view.dart'; // Assuming locator is setup for AccountService

class AccountDepositAndBanksPage extends StatefulWidget {
  const AccountDepositAndBanksPage({super.key});

  @override
  State<AccountDepositAndBanksPage> createState() =>
      _AccountDepositAndBanksPageState();
}

class _AccountDepositAndBanksPageState
    extends State<AccountDepositAndBanksPage> {
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomSearchBar(
                controller: _searchController,
                onClear: _clearSearch,
                onSubmitted: _submitSearch,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchAccounts(reset: true),
                child: AccountListView(
                  accounts: _accounts,
                  isLoading: _isLoading,
                  scrollController: _scrollController,
                  defaultCurrencyFormatter: currencyFormatter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
