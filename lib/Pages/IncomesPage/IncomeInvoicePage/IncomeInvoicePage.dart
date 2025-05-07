import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceModel.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceService.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceCancelModel.dart';
import 'package:pranomiapp/services/InvoiceServices/SendEInvoiceService.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceSendEInvoiceModel.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceCancelledService.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceCancellationReversalModel.dart';
import 'package:pranomiapp/Pages/IncomesPage/IncomeInvoicePage/IncomeInvoiceDetails.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceCancellationReversalService.dart';

class IncomeInvoicePage extends StatefulWidget {
  const IncomeInvoicePage({super.key});

  @override
  State<IncomeInvoicePage> createState() => _IncomeInvoicePageState();
}

class _IncomeInvoicePageState extends State<IncomeInvoicePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<IncomeInvoiceModel> _invoices = [];

  bool _isLoading = false;
  bool _hasMore = true;

  int _page = 0;
  final int _size = 20;
  String _searchText = '';

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
        _scrollController.position.maxScrollExtent - 300) {
      if (!_isLoading && _hasMore) {
        _fetchInvoices();
      }
    }
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

      if (!mounted) return;

      if (resp != null && resp.invoices.isNotEmpty) {
        setState(() {
          _invoices.addAll(resp.invoices);
          _page++;
          if (resp.invoices.length < _size) _hasMore = false;
        });
      } else {
        setState(() => _hasMore = false);
      }
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Ara...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (val) {
                  _searchText = val;
                  _fetchInvoices(reset: true);
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchInvoices(reset: true),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount:
                      _invoices.isEmpty
                          ? 1
                          : _invoices.length + (_isLoading ? 1 : 0),
                  itemBuilder: (ctx, idx) {
                    if (_invoices.isEmpty) {
                      return const SizedBox(
                        height: 300,
                        child: Center(child: Text('Hiç fatura bulunamadı.')),
                      );
                    }

                    if (idx < _invoices.length) {
                      return _buildInvoiceItem(_invoices[idx]);
                    }

                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
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

  Widget _buildInvoiceItem(IncomeInvoiceModel invoice) {
    final dateFormatted = DateFormat('dd.MM.yyyy').format(invoice.date);
    final isCancelled = invoice.invoiceStatus == "Cancelled";

    final textStyle = TextStyle(
      decoration:
          isCancelled ? TextDecoration.lineThrough : TextDecoration.none,
      color: isCancelled ? Colors.grey : null,
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
      ),
    );
  }

  void _showSimpleBottomSheet(IncomeInvoiceModel invoice) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
            child: Wrap(children: _buildBottomSheetOptions(invoice)),
          ),
    );
  }

  List<Widget> _buildBottomSheetOptions(IncomeInvoiceModel invoice) {
    final List<Widget> options = [
      ListTile(
        leading: const Icon(Icons.receipt_long),
        title: const Text('Fatura Detayı'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceDetailPage(invoiceId: invoice.id),
            ),
          );
        },
      ),
    ];

    invoice.invoiceStatus == "Cancelled"
        ? options.add(_buildReversalTile(invoice))
        : options.add(_buildCancelTile(invoice));

    options.add(_buildSendTile(invoice));
    return options;
  }

  Widget _buildReversalTile(IncomeInvoiceModel invoice) {
    return ListTile(
      leading: const Icon(Icons.undo),
      title: const Text('Fatura iptalini geri al'),
      onTap: () async {
        Navigator.pop(context);
        final confirm = await _showConfirmDialog(
          title: 'Fatura İptali Geri Alma',
          content: 'Faturayı iptalini geri almak istediğinize emin misiniz?',
        );
        if (confirm != true) return;

        try {
          final result = await InvoiceCancellationReversalService()
              .invoiceCancel(
                InvoiceCancellationReversalModel(
                  documentNumber: invoice.documentNumber,
                ),
              );

          if (result != null) {
            _showSnackBar('Fatura iptali geri alındı.', Colors.green);
            _fetchInvoices(reset: true);
          } else {
            _showSnackBar('Fatura iptali geri alınamadı.', Colors.red);
          }
        } catch (e) {
          _showSnackBar('Hata oluştu: $e', Colors.red);
        }
      },
    );
  }

  Widget _buildCancelTile(IncomeInvoiceModel invoice) {
    return ListTile(
      leading: const Icon(Icons.cancel),
      title: const Text('Faturayı İptal Et'),
      onTap: () async {
        Navigator.pop(context);
        final confirm = await _showConfirmDialog(
          title: 'Fatura İptali',
          content: 'Faturayı iptal etmek istediğinize emin misiniz?',
        );
        if (confirm != true) return;

        try {
          final result = await InvoiceCancelService().invoiceCancel(
            InvoiceCancelModel(documentNumber: invoice.documentNumber),
          );

          if (result != null) {
            _showSnackBar('Fatura başarıyla iptal edildi.', Colors.green);
            _fetchInvoices(reset: true);
          } else {
            _showSnackBar('Fatura iptal edilemedi.', Colors.red);
          }
        } catch (e) {
          _showSnackBar('Hata oluştu: $e', Colors.red);
        }
      },
    );
  }

  Widget _buildSendTile(IncomeInvoiceModel invoice) {
    return ListTile(
      leading: const Icon(Icons.send),
      title: const Text('E-Fatura Gönder'),
      onTap: () {
        Navigator.pop(context);
        _showSendDialog(invoice);
      },
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Hayır'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Evet'),
              ),
            ],
          ),
    );
  }

  void _showSendDialog(IncomeInvoiceModel invoice) {
    final emailController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('E-Fatura Gönder'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-Posta',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Not',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  if (email.isEmpty) {
                    _showSnackBar('Lütfen e-posta girin.', Colors.red);
                    return;
                  }

                  Navigator.pop(c);

                  try {
                    final response = await SendEInvoiceService()
                        .sendEinvoiceFullResponse(
                          SendEInvoiceModel(
                            invoiceId: invoice.id,
                            email: email,
                            invoiceNote: noteController.text.trim(),
                          ),
                        );

                    if (!mounted) return;

                    void showMessages(List<String>? messages, Color color) {
                      if (messages != null) {
                        for (final msg in messages) {
                          _showSnackBar(msg, color);
                        }
                      }
                    }

                    if (response != null) {
                      showMessages(response.warningMessages, Colors.amber);
                      showMessages(response.errorMessages, Colors.red);
                      showMessages(response.successMessages, Colors.green);

                      if (response.success) {
                        _showSnackBar(
                          'E-Fatura başarıyla gönderildi. ID: ${response.item}',
                          Colors.green,
                        );
                      }
                    } else {
                      _showSnackBar('E-Fatura gönderilemedi.', Colors.red);
                    }
                  } catch (e) {
                    _showSnackBar('Gönderim hatası: $e', Colors.red);
                  }
                },
                child: const Text('Gönder'),
              ),
            ],
          ),
    );
  }
}
