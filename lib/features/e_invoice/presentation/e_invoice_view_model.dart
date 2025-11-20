import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/features/e_invoice/data/services/e_invoice_cancel_service.dart';
import 'package:pranomiapp/features/e_invoice/data/services/e_invoice_open_as_pdf_service.dart';
import 'package:pranomiapp/features/e_invoice/data/services/e_invoice_service.dart';

import '../data/e_invoice_model.dart';
import '../domain/e_invoice_cancel_model.dart';

class EInvoiceViewModel extends ChangeNotifier {
  final String _invoiceType;
  final String _recordType;

  final EInvoiceService _eInvoiceService = locator<EInvoiceService>();
  final EInvoiceOpenAsPdfService _eInvoiceOpenAsPdfService = locator<EInvoiceOpenAsPdfService>();
  final EInvoiceCancelService _eInvoiceCancelService = locator<EInvoiceCancelService>();

  final TextEditingController searchController = TextEditingController();
  final List<EInvoiceModel> _eInvoices = [];
  List<EInvoiceModel> get eInvoices => _eInvoices;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _page = 0;
  static const int _size = 20;
  String _searchText = '';
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  String? _snackBarMessage;
  String? get snackBarMessage => _snackBarMessage;
  Color _snackBarColor = AppTheme.successColor;
  Color get snackBarColor => _snackBarColor;

  EInvoiceViewModel({required String invoiceType, required String recordType})
      : _invoiceType = invoiceType,
        _recordType = recordType {
    fetchEInvoices();
    searchController.addListener(() {
      _searchText = searchController.text;
      // Debounce or immediate fetch can be decided here. For now, submit will trigger fetch.
      // If immediate search on change is needed, add notifyListeners() and trigger fetch.
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setActionLoading(bool loading) {
    _isActionLoading = loading;
    notifyListeners();
  }
  
  void clearSnackBarMessage() {
    _snackBarMessage = null;
    // notifyListeners(); // Usually called after an action that will trigger a rebuild anyway
  }

  void _showSnackBar(String message, Color color) {
    _snackBarMessage = message;
    _snackBarColor = color;
    notifyListeners();
  }

  Future<void> fetchEInvoices({bool reset = false}) async {
    if (_isLoading && !reset) return; // Prevent multiple simultaneous fetches unless it's a reset

    if (reset) {
      _page = 0;
      _eInvoices.clear();
      _hasMore = true;
    }
    _setLoading(true);

    try {
      final response = await _eInvoiceService.fetchEInvoices(
        page: _page,
        size: _size,
        eInvoiceDate: _selectedDate,
        eInvoiceType: _invoiceType,
        recordType: _recordType,
        search: _searchText.isNotEmpty ? _searchText : null,
      );

      if (response != null && response.invoices.isNotEmpty) {
        _eInvoices.addAll(response.invoices);
        _page++;
        if (response.invoices.length < _size) {
          _hasMore = false;
        }
      } else {
        _hasMore = false;
        if (_eInvoices.isEmpty && reset) {
            // _showSnackBar('Hiç fatura bulunamadı.', Colors.grey); // Let UI handle empty state text
        }
      }
    } catch (e) {
      _hasMore = false; // Stop pagination on error
      _showSnackBar('Veri çekme hatası: \$e', AppTheme.errorColor);
    } finally {
      _setLoading(false);
    }
  }

  void handleScroll(ScrollController scrollController) {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        fetchEInvoices();
      }
    }
  }
  
  void onSearchSubmitted(String text) {
    _searchText = text;
    fetchEInvoices(reset: true);
  }

  void clearSearchAndFetch() {
    searchController.clear();
    _searchText = '';
    fetchEInvoices(reset: true);
  }
  
  void selectDateAndFetch(DateTime? date, BuildContext context) {
    _selectedDate = date;
    Navigator.pop(context); // Close the date picker modal
    fetchEInvoices(reset: true);
  }

  void clearDateAndFetch(BuildContext context) {
    _selectedDate = null;
    Navigator.pop(context); // Close the filter modal
    fetchEInvoices(reset: true);
  }

  Future<String?> openPdf(String uuId) async {
    _setActionLoading(true);
    try {
      final response = await _eInvoiceOpenAsPdfService.fetchEInvoicePdf(uuId);
      if (response != null && response.success && response.item.isNotEmpty) {
        return response.item; // Return base64 string
      } else {
        _showSnackBar("PDF alınamadı.", AppTheme.errorColor);
        return null;
      }
    } catch (e) {
      _showSnackBar('PDF açılırken hata: \$e', AppTheme.errorColor);
      return null;
    } finally {
      _setActionLoading(false);
    }
  }

  Future<bool> cancelInvoice(EInvoiceModel invoice, String reason) async {
    _setActionLoading(true);
    try {
      // Call the service
      await _eInvoiceCancelService.invoiceCancel(
        EInvoiceCancelModel(
          uuId: invoice.uuId,
          rejectedNote: reason,
          answerCode: invoice.status,
          documentNumber: invoice.documentNumber,
        ),
      );

      // If we reach here without exception, assume success
      // Find and update the cancelled invoice in the local list
      final index = _eInvoices.indexWhere((inv) => inv.uuId == invoice.uuId);
      // returns -1 if an element not found with that id
      if (index != -1) {
        _eInvoices[index] = _eInvoices[index].copyWith(status: 'Canceled');
        notifyListeners(); // Update only the changed item
      }

      _showSnackBar('Fatura başarıyla iptal edildi.', AppTheme.successColor);
      return true;

    } catch (e) {
      // Only show error if there was an exception
      _showSnackBar('Fatura iptal edilirken hata: $e', AppTheme.errorColor);
      return false;
    } finally {
      _setActionLoading(false);
    }
  }

// Helper method to create updated invoice
  EInvoiceModel _createUpdatedInvoice(EInvoiceModel original, String newStatus) {
    return EInvoiceModel(
      documentNumber: original.documentNumber,
      type: original.type,
      id: original.id,
      customerName: original.customerName,
      date: original.date,
      uuId: original.uuId,
      status: newStatus,
      invoiceSales: original.invoiceSales,
      invoiceProfileId: original.invoiceProfileId,
      resultData: original.resultData,
      taxNumber: original.taxNumber,
      taxOffice: original.taxOffice,
      recordType: original.recordType,
    );
  }


  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
