import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../data/models/invoice_claim_model.dart';
import '../../data/services/invoice_claim_service.dart';

// Güncellenmiş InvoicesClaimPage (models ve servise göre uyarlanmış)

class InvoicesClaimPage extends StatefulWidget {
  final int claimType;

  const InvoicesClaimPage({super.key, required this.claimType});

  @override
  State<InvoicesClaimPage> createState() => _InvoicesClaimPageState();
}

class _InvoicesClaimPageState extends State<InvoicesClaimPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<InvoiceClaimModel> _incomeClaim = [];

  final _invoiceClaimService = locator<InvoiceClaimService>();

  bool _isLoading = false;
  bool _hasMore = true;

  int _page = 0;
  final int _size = 20;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchInvoices();
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
      if (!_isLoading && _hasMore) _fetchInvoices();
    }
  }

  Future<void> _fetchInvoices({bool reset = false}) async {
    int type = widget.claimType;
    if (reset) {
      _page = 0;
      _incomeClaim.clear();
      _hasMore = true;
    }

    setState(() => _isLoading = true);

    try {
      final resp = await _invoiceClaimService.fetchInvoiceClaim(
        page: _page,
        size: _size,
        invoiceType: type,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (!mounted) return;

      setState(() {
        if (resp.claims.isNotEmpty) {
          _incomeClaim.addAll(resp.claims);
          _page++;
          if (resp.claims.length < _size) _hasMore = false;
        } else {
          _hasMore = false;
        }
      });
    } catch (e) {
      _showSnackBar('Veri çekme hatası: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Belge numarası veya Barkod ara...',
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _fetchInvoices(reset: true);
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
                onSubmitted: (_) => _fetchInvoices(reset: true),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchInvoices(reset: true),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount:
                      _incomeClaim.isEmpty && !_isLoading
                          ? 1
                          : _incomeClaim.length + (_isLoading ? 1 : 0),
                  itemBuilder: (ctx, idx) {
                    if (_incomeClaim.isEmpty && !_isLoading) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Text(
                            'Hiç fatura bulunamadı.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    }

                    if (idx < _incomeClaim.length) {
                      return _buildInvoiceItem(_incomeClaim[idx]);
                    }

                    return const Padding(
                      padding: EdgeInsets.all(16),
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

  Widget _buildInvoiceItem(InvoiceClaimModel invoice) {
    final dateFormatted = DateFormat('dd.MM.yyyy').format(invoice.claimDate);
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      decimalDigits: 2,
      symbol: '',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invoice.documentNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Müşteri: ${invoice.customerFullName}'),
              Text('Tarih: $dateFormatted'),
              const SizedBox(height: 8),
              Text(
                'Toplam Tutar: ${currencyFormatter.format(invoice.totalAmount)} ₺',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              // const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ödenen Tutar: ${currencyFormatter.format(invoice.paidAmount)} ₺',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (invoice.isEInvoiced)
                    Image.asset("lib/assets/icons/pdficon.png", height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
