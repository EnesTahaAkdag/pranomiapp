import '../domain/e_invoice_type_enums.dart';

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
  EInvoiceModel copyWith({
    String? documentNumber,
    EInvoiceTypeEnum? type,
    int? id,
    String? customerName,
    DateTime? date,
    String? uuId,
    String? status,
    String? invoiceSales,
    String? invoiceProfileId,
    String? resultData,
    String? taxNumber,
    String? taxOffice,
    String? recordType,
  }) {
    return EInvoiceModel(
      documentNumber: documentNumber ?? this.documentNumber,
      type: type ?? this.type,
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      date: date ?? this.date,
      uuId: uuId ?? this.uuId,
      status: status ?? this.status,
      invoiceSales: invoiceSales ?? this.invoiceSales,
      invoiceProfileId: invoiceProfileId ?? this.invoiceProfileId,
      resultData: resultData ?? this.resultData,
      taxNumber: taxNumber ?? this.taxNumber,
      taxOffice: taxOffice ?? this.taxOffice,
      recordType: recordType ?? this.recordType,
    );
  }

}
