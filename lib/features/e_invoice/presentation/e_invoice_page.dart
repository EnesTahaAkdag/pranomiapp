import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../data/e_invoice_model.dart';
import 'e_invoice_view_model.dart';

/// Top-level function to decode base64 in background isolate
/// Only decodes the string - file operations stay on main thread
Uint8List _decodeBase64InBackground(String base64String) {
  return base64Decode(base64String);
}

/// E-Invoice Page - MVVM Pattern with Provider
/// Using ChangeNotifierProvider to properly manage ViewModel lifecycle
class EInvoicesPage extends StatelessWidget {
  final String invoiceType;
  final String recordType;

  const EInvoicesPage({
    super.key,
    required this.invoiceType,
    required this.recordType,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EInvoiceViewModel(
        invoiceType: invoiceType,
        recordType: recordType,
      ),
      child: const _EInvoiceView(),
    );
  }
}

/// Main view widget - Listens to ViewModel changes via Provider
class _EInvoiceView extends StatefulWidget {
  const _EInvoiceView();

  @override
  State<_EInvoiceView> createState() => _EInvoiceViewState();
}

class _EInvoiceViewState extends State<_EInvoiceView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final viewModel = context.read<EInvoiceViewModel>();
    viewModel.handleScroll(_scrollController);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EInvoiceViewModel>(
      builder: (context, viewModel, child) {
        // Handle snackbar messages
        if (viewModel.snackBarMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSnackBar(viewModel.snackBarMessage!, viewModel.snackBarColor);
            viewModel.clearSnackBarMessage();
          });
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildSearchBar(viewModel),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => viewModel.fetchEInvoices(reset: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              viewModel.eInvoices.isEmpty && !viewModel.isLoading
                                  ? 1
                                  : viewModel.eInvoices.length +
                                      (viewModel.hasMore ? 1 : 0),
                          itemBuilder: (ctx, idx) {
                            if (viewModel.eInvoices.isEmpty &&
                                !viewModel.isLoading) {
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

                            if (idx < viewModel.eInvoices.length) {
                              return _buildInvoiceItem(viewModel.eInvoices[idx], viewModel);
                            }

                            if (viewModel.hasMore) {
                              return  Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child:  LoadingAnimationWidget.staggeredDotsWave(
                                  // LoadingAnimationwidget that call the
                                  color: AppTheme.accentColor, // staggereddotwave animation
                                  size: 50,
                                )),
                              );
                            }
                            return const SizedBox.shrink(); // No more items and not loading
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                if (viewModel
                    .isActionLoading) // Loading indicator for PDF/Cancel actions
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child:  Center(
                      child:  LoadingAnimationWidget.staggeredDotsWave(
                        // LoadingAnimationwidget that call the
                        color: AppTheme.accentColor, // staggereddotwave animation
                        size: 50,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(EInvoiceViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: viewModel.searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Belge numarası ara...',
                suffixIcon:
                    viewModel.searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => viewModel.clearSearchAndFetch(),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (text) => viewModel.onSearchSubmitted(text),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterModal(viewModel),
            tooltip: 'Filtrele',
          ),
        ],
      ),
    );
  }

  void _showFilterModal(EInvoiceViewModel viewModel) {
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
                          viewModel.selectedDate != null
                              ? 'Tarih: ${AppFormatters.dateShort.format(viewModel.selectedDate!)}'
                              : 'Tarih seçilmedi',
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                viewModel.selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            // No need for modalSetState if the action closes the modal immediately
                            viewModel.selectDateAndFetch(picked, modalContext);
                          }
                        },
                        icon: const Icon(Icons.date_range),
                        label: const Text("Tarih Seç"),
                      ),
                    ],
                  ),
                  if (viewModel.selectedDate != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          viewModel.clearDateAndFetch(modalContext);
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

  Widget _buildInvoiceItem(EInvoiceModel invoice, EInvoiceViewModel viewModel) {
    final dateFormatted =
        invoice.date != null
            ? AppFormatters.dateShort.format(invoice.date!)
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
                    onPressed: () => _showSimpleBottomSheet(invoice, viewModel),
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

  /// Opens a PDF from base64 string
  /// Decodes base64 in background isolate to avoid blocking UI
  Future<void> _openBase64Pdf(String base64Str) async {
    try {
      // Decode base64 in background isolate (CPU-intensive operation)
      // Uses the top-level _decodeBase64InBackground function
      final bytes = await compute(_decodeBase64InBackground, base64Str);

      // File operations must stay on main thread (platform channels)
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      // Write bytes to file (async, won't block UI significantly)
      await file.writeAsBytes(bytes);

      // Open the PDF file
      await OpenFile.open(file.path);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('PDF gösterilemedi: $e', Colors.red);
    }
  }

  void _showSimpleBottomSheet(EInvoiceModel invoice, EInvoiceViewModel viewModel) {
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
                    final base64Pdf = await viewModel.openPdf(invoice.uuId);
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
                      _showCancelReasonDialog(invoice, viewModel);
                    },
                  ),
              ],
            ),
          ),
    );
  }

  void _showCancelReasonDialog(EInvoiceModel invoice, EInvoiceViewModel viewModel) {
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
                    await viewModel.cancelInvoice(
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
