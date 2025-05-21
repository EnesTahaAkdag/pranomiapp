import 'package:pranomiapp/Models/TypeEnums/EInvoiceTypeEnums.dart';

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

class EInvoiceModel {
  final String documentNumber;
  final EInvoiceTypeEnum type;
  final int id;
  final String customerName;
  final DateTime? date;
  final String uuId;
  final String status;
  final String invoiceSales;
  final String invoiceProfileId;
  final String resultData;
  final String taxNumber;
  final String taxOffice;
  final String recordType;

  EInvoiceModel({
    required this.documentNumber,
    required this.type,
    required this.id,
    required this.customerName,
    required this.date,
    required this.uuId,
    required this.status,
    required this.invoiceSales,
    required this.invoiceProfileId,
    required this.resultData,
    required this.taxNumber,
    required this.taxOffice,
    required this.recordType,
  });

  factory EInvoiceModel.fromJson(Map<String, dynamic> json) {
    return EInvoiceModel(
      documentNumber: json['DocumentNumber'] ?? '',
      type: parseEInvoceType(json['Type']),
      id: json['Id'],
      customerName: json['CustomerName'] ?? '',
      date: json['Date'] != null ? DateTime.parse(json['Date']) : null,
      uuId: json['UUID'] ?? '',
      status: json['Status'] ?? '',
      invoiceSales: json['InvoiceSales'] ?? '',
      invoiceProfileId: json['InvoiceProfileId'] ?? '',
      resultData: json['ResultData'] ?? '',
      taxNumber: json['TaxNumber'] ?? '',
      taxOffice: json['TaxOffice'] ?? '',
      recordType: json['RecordType'] ?? '',
    );
  }
}
