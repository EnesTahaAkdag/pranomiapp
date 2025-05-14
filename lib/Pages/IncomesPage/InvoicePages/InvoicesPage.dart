import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceModel.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceService.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceCancelModel.dart';
import 'package:pranomiapp/services/InvoiceServices/SendEInvoiceService.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceSendEInvoiceModel.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceCancelledService.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceCancellationReversalModel.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceCancellationReversalService.dart';

class InvoicesPage extends StatefulWidget {
  final int invoiceType;

  const InvoicesPage({super.key, required this.invoiceType});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
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
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) _fetchInvoices();
    }
  }

  Future<void> _fetchInvoices({bool reset = false}) async {
    int type = widget.invoiceType;
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
        invoiceType: type,
        search: _searchText.isNotEmpty ? _searchText : null,
      );

      if (!mounted) return;

      setState(() {
        if (resp != null && resp.invoices.isNotEmpty) {
          _invoices.addAll(resp.invoices);
          _page++;
          if (resp.invoices.length < _size) _hasMore = false;
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
      body: SafeArea(
        child:
            _isLoading && _invoices.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Fatura numarası veya müşteri ara...',
                          suffixIcon:
                              _searchText.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchText = '');
                                      _fetchInvoices(reset: true);
                                    },
                                  )
                                  : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) => setState(() => _searchText = val),
                        onSubmitted: (_) => _fetchInvoices(reset: true),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => _fetchInvoices(reset: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              _invoices.isEmpty
                                  ? 1
                                  : _invoices.length + (_isLoading ? 1 : 0),
                          itemBuilder: (ctx, idx) {
                            if (_invoices.isEmpty) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: const Center(
                                  child: Text('Hiç fatura bulunamadı.'),
                                ),
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
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR ',
      decimalDigits: 2,
    );
    final textStyle = TextStyle(
      decoration: isCancelled ? TextDecoration.lineThrough : null,
      color: isCancelled ? Colors.grey.shade600 : Colors.black87,
      fontSize: 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      invoice.documentNumber,
                      style: textStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showSimpleBottomSheet(invoice),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Müşteri: ${invoice.customerName}', style: textStyle),
              Text('Tarih: $dateFormatted', style: textStyle),
              const SizedBox(height: 6),
              Text(
                'Toplam Tutar: ${currencyFormatter.format(invoice.totalAmount)}₺',
                style: textStyle.copyWith(fontWeight: FontWeight.w500),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ödenen Tutar: ${currencyFormatter.format(invoice.paidAmount)}₺',
                    style: textStyle.copyWith(fontWeight: FontWeight.w500),
                  ),
                  if (invoice.isEInvoiced)
                    Image.asset("lib/assets/icons/pdficon.png", height: 50),
                ],
              ),
            ],
          ),
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
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Fatura Detayı'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/invoice-detail/${invoice.id}');
                  },
                ),

                invoice.invoiceStatus == "Cancelled"
                    ? ListTile(
                      leading: const Icon(Icons.undo),
                      title: const Text('Fatura iptalini geri al'),
                      onTap: () => _handleReversal(invoice),
                    )
                    : ListTile(
                      leading: const Icon(Icons.cancel),
                      title: const Text('Faturayı İptal Et'),
                      onTap: () => _handleInvoiceCancel(invoice),
                    ),
                ListTile(
                  leading: const Icon(Icons.send),
                  title: const Text('E-Fatura Gönder'),
                  onTap: () => _showSendDialog(invoice),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _handleInvoiceCancel(IncomeInvoiceModel invoice) async {
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
      _showSnackBar(
        result != null
            ? 'Fatura başarıyla iptal edildi.'
            : 'Fatura iptal edilemedi.',
        result != null ? Colors.green : Colors.red,
      );
      if (result != null) _fetchInvoices(reset: true);
    } catch (e) {
      _showSnackBar('Hata oluştu: $e', Colors.red);
    }
  }

  Future<void> _handleReversal(IncomeInvoiceModel invoice) async {
    Navigator.pop(context);
    final confirm = await _showConfirmDialog(
      title: 'Fatura İptali Geri Alma',
      content: 'Faturayı iptalini geri almak istediğinize emin misiniz?',
    );
    if (confirm != true) return;

    try {
      final result = await InvoiceCancellationReversalService().invoiceCancel(
        InvoiceCancellationReversalModel(
          documentNumber: invoice.documentNumber,
        ),
      );
      _showSnackBar(
        result != null
            ? 'Fatura iptali geri alındı.'
            : 'Fatura iptali geri alınamadı.',
        result != null ? Colors.green : Colors.red,
      );
      if (result != null) _fetchInvoices(reset: true);
    } catch (e) {
      _showSnackBar('Hata oluştu: $e', Colors.red);
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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

                    if (response != null) {
                      for (final msg in response.successMessages) {
                        _showSnackBar(msg, Colors.green);
                      }
                      for (final msg in response.warningMessages) {
                        _showSnackBar(msg, Colors.orange);
                      }
                      for (final msg in response.errorMessages) {
                        _showSnackBar(msg, Colors.red);
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
