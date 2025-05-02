// lib/pages/IncomeInvoicePage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceModel.dart';
import 'package:pranomiapp/Pages/IncomesPage/IncomeInvoicePage/IncomeInvoiceDetails';
import 'package:pranomiapp/services/InvoiceServices/invoiceservice.dart';

class IncomeInvoicePage extends StatefulWidget {
  const IncomeInvoicePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IncomeInvoicePageState createState() => _IncomeInvoicePageState();
}

class _IncomeInvoicePageState extends State<IncomeInvoicePage> {
  final ScrollController _scrollController = ScrollController();
  final List<IncomeInvoiceModel> _invoices = [];
  bool _isLoading = false, _hasMore = true;
  // ignore: prefer_final_fields
  int _page = 0, _size = 20;
  String _searchText = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        if (!_isLoading && _hasMore) _fetchInvoices();
      }
    });
  }

  Future<void> _fetchInvoices({bool reset = false}) async {
    if (reset) {
      _page = 0;
      _invoices.clear();
      _hasMore = true;
    }
    setState(() => _isLoading = true);
    try {
      final resp = await IncomeInvoiceService().fetchIncomeInvoice(
        page: _page,
        size: _size,
        invoiceType: 1,
        search: _searchText.isNotEmpty ? _searchText : null,
      );
      if (resp.invoices.isNotEmpty) {
        _invoices.addAll(resp.invoices);
        _page++;
        if (resp.invoices.length < _size) _hasMore = false;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veri çekme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSimpleBottomSheet(IncomeInvoiceModel invoice) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Fatura Detayı'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => InvoiceDetailPage(invoiceId: invoice.id),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Faturayı İptal Et'),
                  onTap: () {
                    Navigator.pop(context);
                    // İptal işlemi
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.send),
                  title: const Text('E-Fatura Gönder'),
                  onTap: () {
                    Navigator.pop(context);
                    // Gönderme işlemi
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInvoiceItem(IncomeInvoiceModel invoice) {
    final dateFormatted = DateFormat('dd.MM.yyyy').format(invoice.date);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          invoice.documentNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text("Müşteri: ${invoice.customerName}"),
            Text("Tarih: $dateFormatted"),
            Text("Tutar: ₺${invoice.totalAmount.toStringAsFixed(2)}"),
            Text("Ödenen: ₺${invoice.paidAmount.toStringAsFixed(2)}"),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showSimpleBottomSheet(invoice),
        ),
        onTap: () => _showSimpleBottomSheet(invoice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Ara...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              _searchText = value;
              _fetchInvoices(reset: true);
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _fetchInvoices(reset: true),
            child:
                _invoices.isEmpty && !_isLoading
                    ? const Center(child: Text('Hiç fatura bulunamadı.'))
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount: _invoices.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, idx) {
                        if (idx < _invoices.length) {
                          return _buildInvoiceItem(_invoices[idx]);
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                    ),
          ),
        ),
      ],
    );
  }
}
