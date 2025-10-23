import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pranomiapp/core/widgets/custom_search_bar.dart';
import 'package:pranomiapp/features/employees/employees_model.dart';
import 'package:pranomiapp/features/employees/employees_service.dart';

import '../../Models/TypeEnums/customer_type_enum.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';

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
        _scrollController.position.maxScrollExtent - 200) {
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
      size: 20,
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
      backgroundColor: Color(0xFFF5F7FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB00034),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
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
              padding: const EdgeInsets.all(16.0),
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
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Card(
                            elevation: 4,
                            shadowColor: Colors.black12,
                            color: const Color(0xFFFFFFFF),
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
                                          employee.employeeName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF212121)
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.edit,
                                        color: Color(0xFFA89494),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Display Customer Code if it's available and not empty
                                  if (employee.employeeCode != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Müşteri Kodu: ',
                                              style: TextStyle(
                                                color: Color(0xFF424141),
                                                fontSize: 14,
                                              ),
                                            ),
                                            TextSpan(
                                              text: employee.employeeCode,
                                              style: const TextStyle(
                                                color: Color(0xFF424242),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Ödenen Tutar: ',
                                          style: TextStyle(
                                            color: Color(0xFF424141),
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${currencyFormatter.format(employee.balance)} ₺',
                                          style: TextStyle(
                                            color: employee.balance > 0
                                                ? const Color(0xFF4CAF50) // Green for positive
                                                : employee.balance < 0
                                                ? const Color(0xFFE53935) // Red for negative
                                                : const Color(0xFF757575), // Gray for zero
                                            fontSize: 14,
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
                    return  Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child:  LoadingAnimationWidget.staggeredDotsWave(
                        // LoadingAnimationwidget that call the
                        color: AppTheme.accentColor, // staggereddotwave animation
                        size: 50,
                      )),
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
