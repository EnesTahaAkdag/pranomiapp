import 'package:pranomiapp/Models/TypeEnums/InvoiceTypeEnums.dart';

class IncomeInvoiceResponseModel {
  final int count;
  final int currentPage;
  final int currentSize;
  final int totalPages;
  final List<IncomeInvoiceModel> invoices;

  IncomeInvoiceResponseModel({
    required this.count,
    required this.currentPage,
    required this.currentSize,
    required this.totalPages,
    required this.invoices,
  });

  factory IncomeInvoiceResponseModel.fromJson(Map<String, dynamic> json) {
    final List invoicesJson = json['Invoices'] ?? [];
    return IncomeInvoiceResponseModel(
      count: json['Count'],
      currentPage: json['CurrentPage'],
      currentSize: json['CurrentSize'],
      totalPages: json['TotalPages'],
      invoices:
          invoicesJson.map((e) => IncomeInvoiceModel.fromJson(e)).toList(),
    );
  }
}

class IncomeInvoiceModel {
  final String documentNumber;
  final String customerName;
  final DateTime date;
  final InvoiceTypeEnum type;
  final int id;
  final String currencyCode;
  final double paidAmount;
  final double totalAmount;
  final bool? isInvoiced;
  final bool isEInvoiced;

  IncomeInvoiceModel({
    required this.documentNumber,
    required this.customerName,
    required this.date,
    required this.type,
    required this.id,
    required this.currencyCode,
    required this.paidAmount,
    required this.totalAmount,
    required this.isInvoiced,
    required this.isEInvoiced,
  });

  factory IncomeInvoiceModel.fromJson(Map<String, dynamic> json) {
    return IncomeInvoiceModel(
      documentNumber: json['DocumentNumber'] ?? '',
      customerName: json['CustomerName'] ?? '',
      date: DateTime.parse(json['Date']),
      type: parseInvoiceType(json['Type']),
      id: json['Id'],
      currencyCode: json['CurrencyCode'] ?? '',
      paidAmount: (json['PaidAmount'] ?? 0).toDouble(),
      totalAmount: (json['TotalAmount'] ?? 0).toDouble(),
      isInvoiced: json['IsInvoiced'],
      isEInvoiced: json['IsEInvoiced'] ?? false,
    );
  }
}
