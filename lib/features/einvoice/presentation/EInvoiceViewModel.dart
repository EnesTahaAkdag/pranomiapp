import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pranomiapp/features/einvoice/domain/EInvocieModel.dart';
import 'package:pranomiapp/services/EInvoiceService/EInvoiceService.dart';
import 'package:pranomiapp/features/einvoice/domain/EInvoiceCancelModel.dart';
import 'package:pranomiapp/services/EInvoiceService/EInvoiceCancelService.dart';
import 'package:pranomiapp/services/EInvoiceService/EInvoiceOpenAsPdfService.dart';
import 'package:pranomiapp/core/di/Injection.dart';

import '../data/EInvoiceModel.dart';

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
  Color _snackBarColor = Colors.green;
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
      _showSnackBar('Veri çekme hatası: \$e', Colors.red);
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
        _showSnackBar("PDF alınamadı.", Colors.red);
        return null;
      }
    } catch (e) {
      _showSnackBar('PDF açılırken hata: \$e', Colors.red);
      return null;
    } finally {
      _setActionLoading(false);
    }
  }

  Future<bool> cancelInvoice(EInvoiceModel invoice, String reason) async {
    _setActionLoading(true);
    try {
      final result = await _eInvoiceCancelService.invoiceCancel(
        EInvoiceCancelModel(
          uuId: invoice.uuId,
          rejectedNote: reason,
          answerCode: invoice.status, // Consider if this is always correct
          documentNumber: invoice.documentNumber,
        ),
      );

      if (result != null) { // Assuming result indicates success
        _showSnackBar('Fatura başarıyla iptal edildi.', Colors.green);
        fetchEInvoices(reset: true); // Refresh list
        return true;
      } else {
        _showSnackBar('Fatura iptal edilemedi.', Colors.red);
        return false;
      }
    } catch (e) {
      _showSnackBar('Fatura iptal edilirken hata: \$e', Colors.red);
      return false;
    } finally {
      _setActionLoading(false);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
