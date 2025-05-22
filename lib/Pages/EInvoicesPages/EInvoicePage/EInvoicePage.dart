import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pranomiapp/Models/EInvoiceModels/EInvocieModel.dart';
import 'package:pranomiapp/services/EInvoiceService/EInvoiceOpenAsPdfService.dart';
import 'package:pranomiapp/services/EInvoiceService/EInvoiceService.dart';

class EInvoicesPage extends StatefulWidget {
  final String invoiceType;
  final String recordType;

  const EInvoicesPage({
    super.key,
    required this.invoiceType,
    required this.recordType,
  });

  @override
  State<EInvoicesPage> createState() => _EInvoicesPageState();
}

class _EInvoicesPageState extends State<EInvoicesPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<EInvoiceModel> _eInvoices = [];

  bool _isLoading = false;
  bool _hasMore = true;

  int _page = 0;
  final int _size = 20;
  String _searchText = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchEInvoices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) _fetchEInvoices();
    }
  }

  Future<void> _fetchEInvoices({bool reset = false}) async {
    if (reset) {
      _page = 0;
      _eInvoices.clear();
      _hasMore = true;
    }

    setState(() => _isLoading = true);

    try {
      final response = await EInvoiceService().fetchEInvoices(
        page: _page,
        size: _size,
        eInvoiceDate: _selectedDate,
        eInvoiceType: widget.invoiceType,
        recordType: widget.recordType,
        search: _searchText.isNotEmpty ? _searchText : null,
      );

      if (!mounted) return;

      setState(() {
        if (response != null && response.invoices.isNotEmpty) {
          _eInvoices.addAll(response.invoices);
          _page++;
          if (response.invoices.length < _size) _hasMore = false;
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Belge numarası ara...',
                        suffixIcon:
                            _searchText.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchText = '');
                                    _fetchEInvoices(reset: true);
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (val) => setState(() => _searchText = val),
                      onSubmitted: (_) => _fetchEInvoices(reset: true),
                    ),
                  ),

                  const SizedBox(width: 12),

                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterModal(),
                    tooltip: 'Filtrele',
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchEInvoices(reset: true),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      _eInvoices.isEmpty && !_isLoading
                          ? 1
                          : _eInvoices.length + (_isLoading ? 1 : 0),
                  itemBuilder: (ctx, idx) {
                    if (_eInvoices.isEmpty && !_isLoading) {
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

                    if (idx < _eInvoices.length) {
                      return _buildInvoiceItem(_eInvoices[idx]);
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

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Filtreleme",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? 'Tarih: ${DateFormat('dd.MM.yyyy', 'tr_TR').format(_selectedDate!)}'
                          : 'Tarih seçilmedi',
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,

                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        _fetchEInvoices(reset: true);
                      }
                    },
                    icon: const Icon(Icons.date_range),
                    label: const Text("Tarih Seç"),
                  ),
                ],
              ),
              if (_selectedDate != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() => _selectedDate = null);
                      Navigator.pop(context);
                      _fetchEInvoices(reset: true);
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text("Tarihi Temizle"),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvoiceItem(EInvoiceModel invoice) {
    final dateFormatted =
        invoice.date != null
            ? DateFormat('dd.MM.yyyy').format(invoice.date!)
            : "Tarih Yok";

    final isCancelled =
        invoice.status.toLowerCase() == "iptal" ||
        invoice.status.toLowerCase() == "cancelled";

    // final currencyFormatter = NumberFormat.currency(
    //   locale: 'tr_TR',
    //   decimalDigits: 2,
    //   symbol: '',
    // );

    final baseColor = isCancelled ? Colors.grey[500] : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black12,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration:
                            isCancelled ? TextDecoration.lineThrough : null,
                        color: baseColor,
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
              const SizedBox(height: 4),

              Text(
                'Müşteri: ${invoice.customerName}',
                style: TextStyle(color: baseColor),
              ),
              Text('Tarih: $dateFormatted', style: TextStyle(color: baseColor)),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openBase64Pdf(String base64Str) async {
    try {
      final bytes = base64Decode(base64Str);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    } catch (e) {
      _showSnackBar('PDF gösterilemedi: $e', Colors.red);
    }
  }

  void _showSimpleBottomSheet(EInvoiceModel invoice) {
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
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Fatura Çıktısı Al'),
                  onTap: () async {
                    Navigator.pop(context);

                    setState(() => _isLoading = true);

                    final response = await EInvoiceOpenAsPdfService()
                        .fetchEInvoicePdf(invoice.uuId);

                    setState(() => _isLoading = false);

                    if (response != null &&
                        response.success &&
                        response.item.isNotEmpty) {
                      await _openBase64Pdf(response.item);
                    } else {
                      _showSnackBar("PDF alınamadı.", Colors.red);
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }
}
