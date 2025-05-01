import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceClaimModel.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceClaimService.dart';

class IncomeClaimPage extends StatefulWidget {
  const IncomeClaimPage({super.key});

  @override
  State<IncomeClaimPage> createState() => _IncomeClaimPageState();
}

class _IncomeClaimPageState extends State<IncomeClaimPage> {
  final ScrollController _scrollController = ScrollController();
  final List<InvoiceClaimModel> _incomeClaim = [];
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
      final services = InvoiceClaimService();
      final response = await services.fetchInvoiceClaim(
        page: _page,
        size: _size,
        invoiceType: 1,
      );

      if (response.claims.isNotEmpty) {
        setState(() {
          _incomeClaim.addAll(response.claims);
          _page++;
          if (response.claims.length < _size) {
            _hasMore = false;
          }
        });
      } else {
        setState(() {
          _hasMore = false;
        });
      }
    } catch (e) {
      debugPrint("Veri Çekme Hatası $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Veri Çekme Hatası: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInvoiceItem(InvoiceClaimModel invoice) {
    final dateFormatted = DateFormat('dd.MM.yyyy').format(invoice.claimDate);

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
            Text("Müşteri: ${invoice.customerFullName}"),
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
            _incomeClaim.clear();
            _hasMore = true;
          });
          await _fetchInvoices();
        },
        child:
            _incomeClaim.isEmpty && !_isLoading
                ? const Center(
                  child: Text(
                    'Hiç fatura bulunamadı.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
                : ListView.builder(
                  controller: _scrollController,
                  itemCount: _incomeClaim.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _incomeClaim.length) {
                      return _buildInvoiceItem(_incomeClaim[index]);
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
