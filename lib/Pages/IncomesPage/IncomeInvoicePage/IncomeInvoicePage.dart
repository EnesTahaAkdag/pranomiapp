import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceCancelModel.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceCancellationReversalModel.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceModel.dart';
import 'package:pranomiapp/Pages/IncomesPage/IncomeInvoicePage/IncomeInvoiceDetails.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceCancellationReversalService.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceCancelledService.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceService.dart';

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
      if (resp!.invoices.isNotEmpty) {
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
                if (invoice.invoiceStatus == "Cancelled") ...[
                  ListTile(
                    leading: const Icon(Icons.cancel),
                    title: const Text('Fatura iptalini geri al'),
                    onTap: () async {
                      Navigator.pop(context);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Fatura İptali Geri Alma'),
                              content: const Text(
                                'Faturayı iptal etmek istediğinize emin misiniz?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Hayır'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Evet'),
                                ),
                              ],
                            ),
                      );

                      if (confirm != true) return;

                      // API çağrısı
                      final cancelModel = InvoiceCancellationReversalModel(
                        documentNumber: invoice.documentNumber,
                      );
                      final result = await InvoiceCancellationReversalService()
                          .invoiceCancel(cancelModel);

                      if (result != null) {
                        // Başarılıysa liste yenilenir
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Fatura iptali geri alındı."),
                            ),
                          );
                          _fetchInvoices(reset: true);
                        }
                      } else {
                        // Hata mesajı
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Fatura iptali geri alınamadı."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.cancel),
                    title: const Text('Faturayı İptal Et'),
                    onTap: () async {
                      Navigator.pop(context); // BottomSheet’i kapat

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Fatura İptali'),
                              content: const Text(
                                'Faturayı iptal etmek istediğinize emin misiniz?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Hayır'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Evet'),
                                ),
                              ],
                            ),
                      );

                      if (confirm != true) return;

                      // API çağrısı
                      final cancelModel = InvoiceCancelModel(
                        documentNumber: invoice.documentNumber,
                      );
                      final result = await InvoiceCancelledService()
                          .invoiceCancel(cancelModel);

                      if (result != null) {
                        // Başarılıysa liste yenilenir
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Fatura başarıyla iptal edildi."),
                            ),
                          );
                          _fetchInvoices(reset: true);
                        }
                      } else {
                        // Hata mesajı
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Fatura iptal edilemedi."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
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
    final isCancelled = invoice.invoiceStatus == "Cancelled";
    final textStyle = TextStyle(
      decoration:
          isCancelled ? TextDecoration.lineThrough : TextDecoration.none,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          invoice.documentNumber,
          style: textStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text("Müşteri: ${invoice.customerName}", style: textStyle),
            Text("Tarih: $dateFormatted", style: textStyle),
            Text(
              "Tutar: ₺${invoice.totalAmount.toStringAsFixed(2)}",
              style: textStyle,
            ),
            Text(
              "Ödenen: ₺${invoice.paidAmount.toStringAsFixed(2)}",
              style: textStyle,
            ),
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
          child:
              _isLoading && _invoices.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                    onRefresh: () => _fetchInvoices(reset: true),
                    child:
                        _invoices.isEmpty
                            ? const Center(
                              child: Text('Hiç fatura bulunamadı.'),
                            )
                            : ListView.builder(
                              controller: _scrollController,
                              itemCount:
                                  _invoices.length + (_isLoading ? 1 : 0),
                              itemBuilder: (context, idx) {
                                if (idx < _invoices.length) {
                                  return _buildInvoiceItem(_invoices[idx]);
                                } else {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
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
