import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceModel.dart';
import 'package:pranomiapp/services/InvoiceServices/invoiceservice.dart';

class ExpenseInvoicePage extends StatefulWidget {
  const ExpenseInvoicePage({super.key});

  @override
  State<ExpenseInvoicePage> createState() => _ExpenseInvoicePageState();
}

class _ExpenseInvoicePageState extends State<ExpenseInvoicePage> {
  final ScrollController _scrollController = ScrollController();
  final List<IncomeInvoiceModel> _invoices = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  final int _size = 20;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        if (!_isLoading && _hasMore) {
          _fetchInvoices();
        }
      }
    });
  }

  Future<void> _fetchInvoices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final service = IncomeInvoiceService();
      final response = await service.fetchIncomeInvoice(
        page: _page,
        size: _size,
        invoiceType: 2,
      );

      if (response.invoices.isNotEmpty) {
        setState(() {
          _invoices.addAll(response.invoices);
          _page++;
          if (response.invoices.length < _size) {
            _hasMore = false;
          }
        });
      } else {
        setState(() {
          _hasMore = false;
        });
      }
    } catch (e) {
      debugPrint("Veri çekme hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veri çekme hatası: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            const SizedBox(height: 4),
            Text("Müşteri: ${invoice.customerName}"),
            Text("Tarih: $dateFormatted"),
            Text("Tutar: ₺${invoice.totalAmount.toStringAsFixed(2)}"),
            Text("Ödenen: ₺${invoice.paidAmount.toStringAsFixed(2)}"),
          ],
        ),
        trailing:
            invoice.isEInvoiced
                ? Image.asset("lib/assets/icons/pdficoncheck.png")
                : Image.asset("lib/assets/icons/pdficon.png"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _page = 0;
            _invoices.clear();
            _hasMore = true;
          });
          await _fetchInvoices();
        },
        child:
            _invoices.isEmpty && !_isLoading
                ? const Center(
                  child: Text(
                    'Hiç fatura bulunamadı.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
                : ListView.builder(
                  controller: _scrollController,
                  itemCount: _invoices.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _invoices.length) {
                      return _buildInvoiceItem(_invoices[index]);
                    } else {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
      ),
    );
  }
}
