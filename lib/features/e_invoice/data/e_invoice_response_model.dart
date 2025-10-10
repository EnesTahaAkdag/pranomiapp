
import 'e_invoice_model.dart';

class EInvoiceResponseModel {
  final int count;
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final List<EInvoiceModel> invoices;

  EInvoiceResponseModel({
    required this.count,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.invoices,
  });

  factory EInvoiceResponseModel.fromJson(Map<String, dynamic> json) {
    return EInvoiceResponseModel(
      count: json['Count'] ?? 0,
      currentPage: json['CurrentPage'] ?? 0,
      pageSize: json['PageSize'] ?? 0,
      totalPages: json['TotalPages'] ?? 0,
      invoices:
      (json['Invoices'] as List<dynamic>?)
          ?.map((e) => EInvoiceModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}
