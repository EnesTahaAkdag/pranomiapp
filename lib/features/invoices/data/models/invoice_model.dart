import '../../domain/invoice_type_enums.dart';

class InvoicesResponseModel {
  final int count;
  final int currentPage;
  final int currentSize;
  final int totalPages;
  final List<InvoicesModel> invoices;

  InvoicesResponseModel.invoicesResponseModel({
    required this.count,
    required this.currentPage,
    required this.currentSize,
    required this.totalPages,
    required this.invoices,
  });

  factory InvoicesResponseModel.fromJson(Map<String, dynamic> json) {
    final List invoicesJson = json['Invoices'] ?? [];
    return InvoicesResponseModel.invoicesResponseModel(
      count: json['Count'],
      currentPage: json['CurrentPage'],
      currentSize: json['CurrentSize'],
      totalPages: json['TotalPages'],
      invoices: invoicesJson.map((e) => InvoicesModel.fromJson(e)).toList(),
    );
  }
}

class InvoicesModel {
  final String documentNumber;
  final String customerName;
  final DateTime date;
  final InvoiceTypeEnum type;
  final int id;
  final String eCommerceCode;
  final String invoiceStatus;
  final String currencyCode;
  final double paidAmount;
  final double totalAmount;
  final bool? isInvoiced;
  final bool isEInvoiced;

  InvoicesModel({
    required this.documentNumber,
    required this.customerName,
    required this.date,
    required this.type,
    required this.id,
    required this.invoiceStatus,
    required this.eCommerceCode,
    required this.currencyCode,
    required this.paidAmount,
    required this.totalAmount,
    required this.isInvoiced,
    required this.isEInvoiced,
  });

  factory InvoicesModel.fromJson(Map<String, dynamic> json) {
    return InvoicesModel(
      documentNumber: json['DocumentNumber'] ?? '',
      customerName: json['CustomerName'] ?? '',
      date: DateTime.parse(json['Date']),
      type: parseInvoiceType(json['Type']),
      id: json['Id'],
      invoiceStatus: json['InvoiceStatus'] ?? '',
      eCommerceCode: json['ECommerceCode'] ?? '',
      currencyCode: json['CurrencyCode'] ?? '',
      paidAmount: (json['PaidAmount'] ?? 0).toDouble(),
      totalAmount: (json['TotalAmount'] ?? 0).toDouble(),
      isInvoiced: json['IsInvoiced'],
      isEInvoiced: json['IsEInvoiced'] ?? false,
    );
  }
}
