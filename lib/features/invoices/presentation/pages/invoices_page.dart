import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/api_constants.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../data/models/invoice_cancel_model.dart';
import '../../data/models/invoice_cancellation_reversal_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/invoice_send_e_invoice_model.dart';
import '../../data/services/invoice_cancellation_reversal_service.dart';
import '../../data/services/invoice_cancelled_service.dart';
import '../../data/services/invoice_service.dart';
import '../../data/services/send_e_invoice_service.dart';

class InvoicesPage extends StatefulWidget {
  final int invoiceType;

  const InvoicesPage({super.key, required this.invoiceType});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<InvoicesModel> _invoices = [];

  final _invoiceService = locator<InvoiceService>();

  final _sendEInvoiceService = locator<SendEInvoiceService>();

  final _invoiceCancelService = locator<InvoiceCancelService>();

  final _invoiceCancellationReversalService =
      locator<InvoiceCancellationReversalService>();

  bool _isLoading = false;
  bool _hasMore = true;

  int _page = 0;
  final int _size = AppConstants.defaultPageSize;
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
        _scrollController.position.maxScrollExtent -
            AppConstants.paginationScrollThreshold) {
      if (!_isLoading && _hasMore) _fetchInvoices();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchText = '';
    _fetchInvoices(reset: true);
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
      final resp = await _invoiceService.fetchInvoice(
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
      backgroundColor: AppTheme.gray100,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: CustomSearchBar(
                controller: _searchController,
                hintText: 'Fatura numarası ara...',
                onClear: _clearSearch,
                onChanged: (val) => setState(() => _searchText = val),
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
                      _invoices.isEmpty && !_isLoading
                          ? 1
                          : _invoices.length + (_isLoading ? 1 : 0),
                  itemBuilder: (ctx, idx) {
                    if (_invoices.isEmpty && !_isLoading) {
                      return SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                            AppConstants.screenHeightMultiplierHalf,
                        child: Center(
                          child: Text(
                            'Hiç fatura bulunamadı.',
                            style: TextStyle(color: AppTheme.gray600),
                          ),
                        ),
                      );
                    }

                    if (idx < _invoices.length) {
                      return _buildInvoiceItem(_invoices[idx]);
                    }

                    return const Padding(
                      padding: EdgeInsets.all(AppConstants.spacingM),
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

  Widget _buildInvoiceItem(InvoicesModel invoice) {
    final dateFormatted = AppFormatters.dateShort.format(invoice.date);
    final isCancelled = invoice.invoiceStatus == "Cancelled";
    final baseColor = isCancelled ? AppTheme.gray500 : AppTheme.textPrimary;
    final eCommerceImageUrl = ApiConstants.eCommerceLogoUrl(
      invoice.eCommerceCode,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      child: Card(
        elevation: AppConstants.elevationMedium,
        shadowColor: AppTheme.shadowColor,
        color: AppTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invoice.documentNumber,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeL,
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
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                'Müşteri: ${invoice.customerName}',
                style: TextStyle(color: baseColor),
              ),
              Text('Tarih: $dateFormatted', style: TextStyle(color: baseColor)),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                'Toplam Tutar: ${AppFormatters.currency.format(invoice.totalAmount)} ₺',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppConstants.fontSizeM,
                  color: baseColor,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ödenen Tutar: ${AppFormatters.currency.format(invoice.paidAmount)} ₺',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: baseColor,
                    ),
                  ),
                  Row(
                    children: [
                      if (invoice.isEInvoiced)
                        Image.asset(
                          "lib/assets/icons/pdficon.png",
                          height: AppConstants.iconSizeXl,
                        ),

                      Image.network(
                        eCommerceImageUrl,
                        height: AppConstants.iconSizeXl,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSimpleBottomSheet(InvoicesModel invoice) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusBottomSheet),
        ),
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

  Future<void> _handleInvoiceCancel(InvoicesModel invoice) async {
    Navigator.pop(context);
    final confirm = await _showConfirmDialog(
      title: 'Fatura İptali',
      content: 'Faturayı iptal etmek istediğinize emin misiniz?',
    );
    if (confirm != true) return;

    try {
      final result = await _invoiceCancelService.invoiceCancel(
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

  Future<void> _handleReversal(InvoicesModel invoice) async {
    Navigator.pop(context);
    final confirm = await _showConfirmDialog(
      title: 'Fatura İptali Geri Alma',
      content: 'Faturayı iptalini geri almak istediğinize emin misiniz?',
    );
    if (confirm != true) return;

    try {
      final result = await _invoiceCancellationReversalService.invoiceCancel(
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
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
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
                  backgroundColor: AppTheme.successColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusS,
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Evet'),
              ),
            ],
          ),
    );
  }

  void _showSendDialog(InvoicesModel invoice) {
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
                const SizedBox(height: AppConstants.spacingS),

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
                    final response = await _sendEInvoiceService
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
