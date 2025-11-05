import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/core/widgets/app_loading_indicator.dart';
import 'package:pranomiapp/core/widgets/custom_search_bar.dart';
import 'package:pranomiapp/features/customers/domain/customer_type_enum.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_constants.dart';
import '../../data/models/employees_model.dart';
import '../../data/services/employees_service.dart';

class EmployeesPage extends StatefulWidget {
  final CustomerTypeEnum customerType;

  const EmployeesPage({super.key, required this.customerType});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = false;
  String _searchText = '';
  final List<Employee> _employees = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final _employeeService = locator<EmployeesService>();

  bool get _hasMore => _currentPage < _totalPages;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchEmployees(reset: true);
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
        _fetchEmployees();
      }
    }
  }

  Future<void> _fetchEmployees({bool reset = false}) async {
    if (_isLoading && !reset) return;

    setState(() => _isLoading = true);

    if (reset) {
      _currentPage = 0;
      _employees.clear();
    }

    final response = await _employeeService.fetchEmployees(
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
          _employees.addAll(response.employees ?? []);
        });
      }
      setState(() => _isLoading = false);

      setState(() => _isLoading = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchText = '';
    _fetchEmployees(reset: true);
  }

  void _submitSearch(String val) {
    setState(() => _searchText = val.trim());
    _fetchEmployees(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      decimalDigits: 2,
      symbol: '',
    );

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundLight,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: AppConstants.spacing30, color: AppTheme.white),
        onPressed: () async {
          /// Made onPressed async and that's help us to refresh the page with navigation result
          final result = await context.push(
            '/${widget.customerType.name}AddPage',
          );
          if (result == 'refresh') {
            _fetchEmployees(reset: true);
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: CustomSearchBar(
                controller: _searchController,
                onClear: _clearSearch,
                onSubmitted: _submitSearch,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchEmployees(reset: true),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount:
                      _employees.isEmpty && !_isLoading
                          ? 1
                          : _employees.length + (_isLoading ? 1 : 0),
                  itemBuilder: (ctx, idx) {
                    if (_employees.isEmpty && !_isLoading) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Text(
                            'Hiç çalışan bulunamadı.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    }

                    if (idx < _employees.length) {
                      final employee = _employees[idx];
                      return GestureDetector(
                        onTap: () async {
                          final result = await context.push(
                            '/CustomerEditPage',
                            extra: employee.employeeId,
                          );
                          if (result == true || result == 'refresh') {
                            // Also refresh if edit page indicates a change

                            _fetchEmployees(reset: true);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                            vertical: AppConstants.spacingS,
                          ),
                          child: Card(
                            elevation: AppConstants.elevationMedium,
                            shadowColor: Colors.black12,
                            color: AppTheme.white,
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
                                          employee.employeeName,
                                          style: const TextStyle(
                                            fontSize: AppConstants.fontSizeL,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.edit,
                                        color: AppTheme.iconGray,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppConstants.spacingXs),
                                  // Display Customer Code if it's available and not empty
                                  if (employee.employeeCode != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppConstants.spacingXs,
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Müşteri Kodu: ',
                                              style: TextStyle(
                                                color: AppTheme.textMedium,
                                                fontSize: AppConstants.fontSizeM,
                                              ),
                                            ),
                                            TextSpan(
                                              text: employee.employeeCode,
                                              style: const TextStyle(
                                                color: AppTheme.textMedium2,
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
                                        const TextSpan(
                                          text: 'Ödenen Tutar: ',
                                          style: TextStyle(
                                            color: AppTheme.textMedium,
                                            fontSize: AppConstants.fontSizeM,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${currencyFormatter.format(employee.balance)} ₺',
                                          style: TextStyle(
                                            color: employee.balance > 0
                                                ? AppTheme.positiveAmountColor // Green for positive
                                                : employee.balance < 0
                                                ? AppTheme.negativeAmountColor // Red for negative
                                                : AppTheme.neutralAmountColor, // Gray for zero
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
                    return const Padding(
                      padding: EdgeInsets.all(AppConstants.spacingM),
                      child: Center(child: AppLoadingIndicator()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
