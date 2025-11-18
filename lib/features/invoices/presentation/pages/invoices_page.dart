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

const int typeIncomeOrder = 3;
const int typeExpenseOrder = 4;

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

  // ============================================================================
  // HELPER METHODS - Belge Tipi Kontrolleri
  // ============================================================================

  /// Belge sipariş mi?
  bool _isOrder(String typeName) {
    return typeName == 'expenseOrder' || typeName == 'incomeOrder';
  }

  /// Belge irsaliye mi?
  bool _isWayBill(String typeName) {
    return typeName == 'incomeWayBill' || typeName == 'expenseWayBill';
  }

  /// Belge iptal edilebilir mi? (İrsaliyeler iptal edilemez)
  bool _canCancel(InvoicesModel invoice) {
    return !_isWayBill(invoice.type.name);
  }

  /// E-Fatura gönderilebilir mi? (Sipariş ve irsaliyeler gönderilemez)
  bool _canSendEInvoice(InvoicesModel invoice) {
    return widget.invoiceType != typeIncomeOrder &&
        widget.invoiceType != typeExpenseOrder &&
        !_isWayBill(invoice.type.name);
  }

  /// Belge başlığını döndürür
  String _getDocumentTitle(String typeName) {
    if (_isOrder(typeName)) return "Sipariş Detayı";
    if (_isWayBill(typeName)) return "İrsaliye Detayı";
    return "Fatura Detayı";
  }

  /// İptal buton başlığını döndürür
  String _getCancelTitle(String typeName) {
    return _isOrder(typeName) ? 'Siparişi İptal Et' : 'Faturayı İptal Et';
  }

  // ============================================================================
  // PAGINATION & SEARCH
  // ============================================================================

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
      _showSnackBar('Veri çekme hatası: $e', AppTheme.buttonErrorColor);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================================
  // UI BUILDERS
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildInvoiceList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: CustomSearchBar(
        controller: _searchController,
        hintText: 'Belge numarası ara...',
        onClear: _clearSearch,
        onChanged: (val) => setState(() => _searchText = val),
        onSubmitted: (_) => _fetchInvoices(reset: true),
      ),
    );
  }

  Widget _buildInvoiceList() {
    return RefreshIndicator(
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
            return _buildEmptyState();
          }

          if (idx < _invoices.length) {
            return _buildInvoiceItem(_invoices[idx]);
          }

          return _buildLoadingIndicator();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height *
          AppConstants.screenHeightMultiplierHalf,
      child: Center(
        child: Text(
          'Hiç fatura bulunamadı.',
          style: TextStyle(color: AppTheme.getTextSecondary(context)),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(AppConstants.spacingM),
      child: Center(child: AppLoadingIndicator()),
    );
  }

  Widget _buildInvoiceItem(InvoicesModel invoice) {
    final dateFormatted = AppFormatters.dateShort.format(invoice.date);
    final isCancelled = invoice.invoiceStatus == "Cancelled";
    final eCommerceImageUrl = ApiConstants.eCommerceLogoUrl(
      invoice.eCommerceCode,
    );

    return Opacity(
      opacity: isCancelled ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        child: Card(
          elevation: AppConstants.elevationMedium,
          shadowColor: AppTheme.getShadowColor(context),
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceHeader(invoice, isCancelled),
                const SizedBox(height: AppConstants.spacingXs),
                _buildInvoiceInfo(invoice, dateFormatted),
                const SizedBox(height: AppConstants.spacingS),
                _buildInvoiceAmount(invoice),
                const SizedBox(height: AppConstants.spacingXs),
                _buildInvoiceFooter(invoice, eCommerceImageUrl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader(InvoicesModel invoice, bool isCancelled) {
    return Row(
      children: [
        Expanded(
          child: Text(
            invoice.documentNumber,
            style: TextStyle(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.bold,
              decoration: isCancelled ? TextDecoration.lineThrough : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showBottomSheet(invoice),
        ),
      ],
    );
  }

  Widget _buildInvoiceInfo(InvoicesModel invoice, String dateFormatted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Müşteri: ${invoice.customerName}'),
        Text('Tarih: $dateFormatted'),
      ],
    );
  }

  Widget _buildInvoiceAmount(InvoicesModel invoice) {
    return Text(
      'Toplam Tutar: ${AppFormatters.currency.format(invoice.totalAmount)} ₺',
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppConstants.fontSizeM,
      ),
    );
  }

  Widget _buildInvoiceFooter(InvoicesModel invoice, String eCommerceImageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Ödenen Tutar: ${AppFormatters.currency.format(invoice.paidAmount)} ₺',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            if (invoice.isEInvoiced)
              Image.asset(
                "lib/assets/icons/pdficon.png",
                height: AppConstants.iconSizeXl,
                color: Colors.red,
              ),
            Image.network(
              eCommerceImageUrl,
              height: AppConstants.iconSizeXl,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================================
  // BOTTOM SHEET & ACTIONS
  // ============================================================================

  void _showBottomSheet(InvoicesModel invoice) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusBottomSheet),
        ),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            _buildDetailTile(invoice),
            if (_canCancel(invoice)) _buildCancelOrReversalTile(invoice),
            if (_canSendEInvoice(invoice)) _buildSendEInvoiceTile(invoice),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(InvoicesModel invoice) {
    return ListTile(
      leading: const Icon(Icons.receipt_long),
      title: Text(_getDocumentTitle(invoice.type.name)),
      onTap: () {
        Navigator.pop(context);
        context.push('/invoice-detail/${invoice.id}');
      },
    );
  }

  Widget _buildCancelOrReversalTile(InvoicesModel invoice) {
    final isCancelled = invoice.invoiceStatus == "Cancelled";

    return isCancelled
        ? ListTile(
      leading: const Icon(Icons.undo),
      title: const Text('İptali Geri Al'),
      onTap: () => _handleReversal(invoice),
    )
        : ListTile(
      leading: const Icon(Icons.cancel),
      title: Text(_getCancelTitle(invoice.type.name)),
      onTap: () => _handleInvoiceCancel(invoice),
    );
  }

  Widget _buildSendEInvoiceTile(InvoicesModel invoice) {
    return ListTile(
      leading: const Icon(Icons.send),
      title: const Text('E-Fatura Gönder'),
      onTap: () => _showSendDialog(invoice),
    );
  }

  // ============================================================================
  // ACTION HANDLERS
  // ============================================================================

  Future<void> _handleInvoiceCancel(InvoicesModel invoice) async {
    Navigator.pop(context);

    final confirm = await _showConfirmDialog(
      title: 'Belge İptali',
      content: 'Belgeyi iptal etmek istediğinize emin misiniz?',
    );

    if (confirm != true) return;

    try {
      final result = await _invoiceCancelService.invoiceCancel(
        InvoiceCancelModel(documentNumber: invoice.documentNumber),
      );

      _showSnackBar(
        result != null ? 'Belge başarıyla iptal edildi.' : 'Belge iptal edilemedi.',
        result != null ? AppTheme.buttonSuccessColor : AppTheme.buttonErrorColor,
      );

      if (result != null) _fetchInvoices(reset: true);
    } catch (e) {
      _showSnackBar('Hata oluştu: $e', AppTheme.buttonErrorColor);
    }
  }

  Future<void> _handleReversal(InvoicesModel invoice) async {
    Navigator.pop(context);

    final confirm = await _showConfirmDialog(
      title: 'İptal Geri Alma',
      content: 'Belge iptalini geri almak istediğinize emin misiniz?',
    );

    if (confirm != true) return;

    try {
      final result = await _invoiceCancellationReversalService.invoiceCancel(
        InvoiceCancellationReversalModel(
          documentNumber: invoice.documentNumber,
        ),
      );

      _showSnackBar(
        result != null ? 'İptal geri alındı.' : 'İptal geri alınamadı.',
        result != null ? AppTheme.buttonSuccessColor : AppTheme.buttonErrorColor,
      );

      if (result != null) _fetchInvoices(reset: true);
    } catch (e) {
      _showSnackBar('Hata oluştu: $e', AppTheme.buttonErrorColor);
    }
  }

  // ============================================================================
  // DIALOGS
  // ============================================================================

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
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
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
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
      builder: (c) => AlertDialog(
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
            onPressed: () => _handleSendEInvoice(
              c,
              invoice,
              emailController,
              noteController,
            ),
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendEInvoice(
      BuildContext dialogContext,
      InvoicesModel invoice,
      TextEditingController emailController,
      TextEditingController noteController,
      ) async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Lütfen e-posta girin.', AppTheme.buttonErrorColor);
      return;
    }

    Navigator.pop(dialogContext);

    try {
      final response = await _sendEInvoiceService.sendEinvoiceFullResponse(
        SendEInvoiceModel(
          invoiceId: invoice.id,
          email: email,
          invoiceNote: noteController.text.trim(),
        ),
      );

      if (!mounted) return;

      if (response != null) {
        for (final msg in response.successMessages) {
          _showSnackBar(msg, AppTheme.buttonSuccessColor);
        }
        for (final msg in response.warningMessages) {
          _showSnackBar(msg, AppTheme.buttonWarningColor);
        }
        for (final msg in response.errorMessages) {
          _showSnackBar(msg, AppTheme.buttonErrorColor);
        }
      } else {
        _showSnackBar('E-Fatura gönderilemedi.', AppTheme.buttonErrorColor);
      }
    } catch (e) {
      _showSnackBar('Gönderim hatası: $e', AppTheme.buttonErrorColor);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}