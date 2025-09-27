import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pranomiapp/Models/TypeEnums/CustomerTypeEnum.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerModel.dart';
import 'package:pranomiapp/services/CustomerService/CustomerService.dart';

import '../../../core/di/Injection.dart';

class CustomerPage extends StatefulWidget {
  final CustomerTypeEnum customerType;

  const CustomerPage({super.key, required this.customerType});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = false;
  String _searchText = '';
  final List<CustomerModel> _customers = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final _customerService = locator<CustomerService>();

  bool get _hasMore => _currentPage < _totalPages;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchCustomers(reset: true);
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
        _fetchCustomers();
      }
    }
  }

  Future<void> _fetchCustomers({bool reset = false}) async {
    if (_isLoading && !reset) return; // Prevent concurrent fetches unless it's a reset

    setState(() => _isLoading = true);

    if (reset) {
      _currentPage = 0;
      _customers.clear();
    }

    final response = await _customerService.fetchCustomers(
      page: _currentPage,
      size: 20,
      customerType: widget.customerType,
      search: _searchText.isNotEmpty ? _searchText : null,
    );

    if (mounted) {
      if (response != null) {
        setState(() {
          _currentPage = (response.currentPage ?? 0) + 1;
          _totalPages = response.totalPages ?? 1;
          _customers.addAll(response.customers ?? []);
        });
      }
      setState(() => _isLoading = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchText = '';
    _fetchCustomers(reset: true);
  }

  void _submitSearch(String val) {
    setState(() => _searchText = val.trim());
    _fetchCustomers(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      decimalDigits: 2,
      symbol: '',
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB00034),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
        onPressed: () async { // Made onPressed async
          final result = await context.push(
            '/${widget.customerType.name}AddPage',
            // Pass the customerType to CustomerAddPage if it needs it
            // For example, if CustomerAddPage constructor takes customerType:
            // extra: widget.customerType, 
          );
          if (result == 'refresh') {
            _fetchCustomers(reset: true);
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            AccountSearchBar(
              searchController: _searchController,
              clearSearch: _clearSearch,
              submitSearch: _submitSearch,
            ),
            Expanded(
              child: AccountListView(
                customers: _customers,
                isLoading: _isLoading,
                scrollController: _scrollController,
                currencyFormatter: currencyFormatter,
                fetchCustomers: () => _fetchCustomers(reset: true),
                onTapCustomer: (customer) async {
                  final result = await context.push(
                    '/CustomerEditPage',
                    extra: customer.customerId,
                  );
                  if (result == true || result == 'refresh') {
                    _fetchCustomers(reset: true);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback clearSearch;
  final ValueChanged<String> submitSearch;

  const AccountSearchBar({
    Key? key,
    required this.searchController,
    required this.clearSearch,
    required this.submitSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search),
          hintText: 'Müşteri ara...',
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onSubmitted: submitSearch,
      ),
    );
  }
}

class AccountListView extends StatelessWidget {
  final List<CustomerModel> customers;
  final bool isLoading;
  final ScrollController scrollController;
  final NumberFormat currencyFormatter;
  final Future<void> Function() fetchCustomers;
  final Future<void> Function(CustomerModel) onTapCustomer;

  const AccountListView({
    Key? key,
    required this.customers,
    required this.isLoading,
    required this.scrollController,
    required this.currencyFormatter,
    required this.fetchCustomers,
    required this.onTapCustomer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchCustomers,
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: customers.isEmpty && !isLoading
            ? 1
            : customers.length + (isLoading ? 1 : 0),
        itemBuilder: (ctx, idx) {
          if (customers.isEmpty && !isLoading) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Text(
                  'Hiç müşteri bulunamadı.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            );
          }

          if (idx < customers.length) {
            final customer = customers[idx];
            return GestureDetector(
              onTap: () => onTapCustomer(customer),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customer.customerName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.edit,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (customer.customerCode.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              'Müşteri Kodu: ${customer.customerCode}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Ödenen Tutar: ${currencyFormatter.format(customer.balance)} ₺',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
