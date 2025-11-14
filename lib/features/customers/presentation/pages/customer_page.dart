import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../data/models/customer_model.dart';
import '../../data/services/customer_service.dart';
import '../../domain/customer_type_enum.dart';

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
        _scrollController.position.maxScrollExtent - AppConstants.paginationScrollThreshold) {
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
      size: AppConstants.defaultPageSize,
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: AppConstants.spacing30, color: AppTheme.white),
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
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child:
              CustomSearchBar(
                controller: _searchController,
                hintText: 'Cari hesap ara...',
                onClear: _clearSearch,
                onSubmitted: _submitSearch,
              ),
            ),
            Expanded(
              child: AccountListView(
                customers: _customers,
                isLoading: _isLoading,
                scrollController: _scrollController,
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

class AccountListView extends StatelessWidget {
  final List<CustomerModel> customers;
  final bool isLoading;
  final ScrollController scrollController;
  final Future<void> Function() fetchCustomers;
  final Future<void> Function(CustomerModel) onTapCustomer;

  const AccountListView({
    Key? key,
    required this.customers,
    required this.isLoading,
    required this.scrollController,
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
                  style: TextStyle(color: AppTheme.getTextSecondary(context)),
                ),
              ),
            );
          }

          if (idx < customers.length) {
            final customer = customers[idx];
            return CustomerListItem(
              key: ValueKey(customer.customerId),
              customer: customer,
              onTap: () => onTapCustomer(customer),
            );
          }
          return const Padding(
            padding: EdgeInsets.all(AppConstants.spacingM),
            child: Center(child: AppLoadingIndicator()),
          );
        },
      ),
    );
  }
}

/// Optimized Customer List Item Widget
/// Extracted to separate StatelessWidget for better performance and reusability
class CustomerListItem extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;

  const CustomerListItem({
    super.key,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        child: Card(
          elevation: AppConstants.elevationMedium,
          shadowColor: AppTheme.getShadowColor(context),
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.customerName,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeL,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextPrimary(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.edit,
                      color: AppTheme.getTextSecondary(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingXs),
                if (customer.customerCode.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Müşteri Kodu: ',
                            style: TextStyle(
                              color: AppTheme.getTextSecondary(context),
                              fontSize: AppConstants.fontSizeM,
                            ),
                          ),
                          TextSpan(
                            text: customer.customerCode,
                            style: TextStyle(
                              color: AppTheme.getTextPrimary(context),
                              fontSize: AppConstants.fontSizeM,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppConstants.spacingS),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Ödenen Tutar: ',
                        style: TextStyle(
                          color: AppTheme.getTextSecondary(context),
                          fontSize: AppConstants.fontSizeM,
                        ),
                      ),
                      TextSpan(
                        text: '${AppFormatters.formatCurrency(customer.balance)} ₺',
                        style: TextStyle(
                          color: customer.balance > 0
                              ? AppTheme.positiveAmountColor // Green for positive
                              : customer.balance < 0
                              ? AppTheme.negativeAmountColor // Red for negative
                              : AppTheme.getTextPrimary(context), // Theme color for zero
                          fontSize: AppConstants.fontSizeM,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
