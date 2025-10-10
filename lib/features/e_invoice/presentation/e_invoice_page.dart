import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../data/e_invoice_model.dart';
import 'e_invoice_view_model.dart';

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
  late final EInvoiceViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = EInvoiceViewModel(
      invoiceType: widget.invoiceType,
      recordType: widget.recordType,
    );
    _viewModel.addListener(_onViewModelChanged);
    _scrollController.addListener(
      () => _viewModel.handleScroll(_scrollController),
    );
  }

  void _onViewModelChanged() {
    if (mounted) {
      if (_viewModel.snackBarMessage != null) {
        _showSnackBar(_viewModel.snackBarMessage!, _viewModel.snackBarColor);
        _viewModel.clearSnackBarMessage();
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
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
        child: Stack(
          children: [
            Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _viewModel.fetchEInvoices(reset: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          _viewModel.eInvoices.isEmpty && !_viewModel.isLoading
                              ? 1
                              : _viewModel.eInvoices.length +
                                  (_viewModel.hasMore ? 1 : 0),
                      itemBuilder: (ctx, idx) {
                        if (_viewModel.eInvoices.isEmpty &&
                            !_viewModel.isLoading) {
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

                        if (idx < _viewModel.eInvoices.length) {
                          return _buildInvoiceItem(_viewModel.eInvoices[idx]);
                        }

                        if (_viewModel.hasMore) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return const SizedBox.shrink(); // No more items and not loading
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (_viewModel
                .isActionLoading) // Loading indicator for PDF/Cancel actions
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _viewModel.searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Belge numarası ara...',
                suffixIcon:
                    _viewModel.searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _viewModel.clearSearchAndFetch(),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (text) => _viewModel.onSearchSubmitted(text),
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
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        // Use a StatefulBuilder to manage the local state of the date picker inside the modal
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
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
                          _viewModel.selectedDate != null
                              ? 'Tarih: ${DateFormat('dd.MM.yyyy', 'tr_TR').format(_viewModel.selectedDate!)}'
                              : 'Tarih seçilmedi',
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                _viewModel.selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            // No need for modalSetState if the action closes the modal immediately
                            _viewModel.selectDateAndFetch(picked, modalContext);
                          }
                        },
                        icon: const Icon(Icons.date_range),
                        label: const Text("Tarih Seç"),
                      ),
                    ],
                  ),
                  if (_viewModel.selectedDate != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          _viewModel.clearDateAndFetch(modalContext);
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
      },
    );
  }

  Widget _buildInvoiceItem(EInvoiceModel invoice) {
    final dateFormatted =
        invoice.date != null
            ? DateFormat('dd.MM.yyyy').format(invoice.date!)
            : "Tarih Yok";
    final isCancelled = invoice.status.toLowerCase() == "canceled";
    final baseColor = isCancelled ? Colors.grey[500] : Colors.black87;
    final textDecoration =
        isCancelled ? TextDecoration.lineThrough : TextDecoration.none;
    final baseTextStyle = TextStyle(
      color: baseColor,
      decoration: textDecoration,
    );
    final boldTitleStyle = baseTextStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    final String eInvoiceLinkCopy =
        "https://panel.pranomi.com/e_invoice/geteinvoices?uuids=${invoice.uuId}";

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
                      style: boldTitleStyle,
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
              Text('Müşteri: ${invoice.customerName}', style: baseTextStyle),
              Text('Tarih: $dateFormatted', style: baseTextStyle),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: eInvoiceLinkCopy));
                      _showSnackBar('Fatura Linki kopyalandı', Colors.green);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.copy, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          "Fatura Linki",
                          style: baseTextStyle.copyWith(
                            fontSize: 12,
                            color: Colors.blue[700],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          (modalContext) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Fatura Çıktısı'),
                  onTap: () async {
                    Navigator.pop(modalContext);
                    final base64Pdf = await _viewModel.openPdf(invoice.uuId);
                    if (base64Pdf != null) {
                      await _openBase64Pdf(base64Pdf);
                    }
                  },
                ),
                if (invoice.status.toLowerCase() != "canceled")
                  ListTile(
                    leading: const Icon(Icons.cancel),
                    title: const Text('Faturayı İptal Et'),
                    onTap: () {
                      Navigator.pop(modalContext);
                      _showCancelReasonDialog(invoice);
                    },
                  ),
              ],
            ),
          ),
    );
  }

  void _showCancelReasonDialog(EInvoiceModel invoice) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("İptal Nedeni"),
            content: TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "İptal nedenini giriniz...",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Vazgeç"),
                // Changed from İptal to Vazgeç for clarity
                onPressed: () => Navigator.pop(dialogContext),
              ),
              ElevatedButton(
                child: const Text("Gönder"),
                onPressed: () async {
                  Navigator.pop(dialogContext); // Close dialog first
                  final confirmed = await _showConfirmDialog(
                    title: 'Fatura İptali',
                    content: 'Faturayı iptal etmek istediğinize emin misiniz?',
                  );
                  if (confirmed == true) {
                    await _viewModel.cancelInvoice(
                      invoice,
                      reasonController.text.trim(),
                    );
                  }
                },
              ),
            ],
          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Hayır'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Evet, İptal Et'),
              ),
            ],
          ),
    );
  }
}
