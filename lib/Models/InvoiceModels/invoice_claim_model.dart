import 'package:pranomiapp/Models/TypeEnums/invoice_type_enums.dart';

class InvoiceClaimResponseModel {
  final int count;
  final int currentPage;
  final int currentSize;
  final int totalPages;
  final List<InvoiceClaimModel> claims;

  InvoiceClaimResponseModel({
    required this.count,
    required this.currentPage,
    required this.currentSize,
    required this.totalPages,
    required this.claims,
  });
  factory InvoiceClaimResponseModel.fromJson(Map<String, dynamic> json) {
    final List invoiceClaimsJson = json['Claims'] ?? [];
    return InvoiceClaimResponseModel(
      count: json['Count'],
      currentPage: json['CurrentPage'],
      currentSize: json['CurrentSize'],
      totalPages: json['TotalPages'],
      claims:
          invoiceClaimsJson.map((e) => InvoiceClaimModel.fromJson(e)).toList(),
    );
  }
}

class InvoiceClaimModel {
  final int claimId;
  final String documentNumber;
  final DateTime claimDate;
  final String customerFullName;
  final InvoiceTypeEnum invoiceType;
  final String claimNote;
  final bool invoicePrinted;
  final double paidAmount;
  final double totalAmount;
  final bool isEInvoiced;

  InvoiceClaimModel({
    required this.claimId,
    required this.documentNumber,
    required this.claimDate,
    required this.customerFullName,
    required this.invoiceType,
    required this.claimNote,
    required this.invoicePrinted,
    required this.isEInvoiced,
    required this.paidAmount,
    required this.totalAmount,
  });

  factory InvoiceClaimModel.fromJson(Map<String, dynamic> json) {
    return InvoiceClaimModel(
      claimId: json['ClaimId'],
      documentNumber: json['DocumentNumber'],
      claimDate: DateTime.parse(json['ClaimDate']),
      customerFullName: json['CustomerFullName'],
      invoiceType: parseInvoiceType(json['InvoiceType']),
      claimNote: json['ClaimNote'] ?? '',
      invoicePrinted: json['InvoicePrinted'] ?? false,
      isEInvoiced: json['IsEInvoiced'] ?? false,
      paidAmount: (json['PaidAmount'] as num).toDouble(),
      totalAmount: (json['TotalAmount'] as num).toDouble(),
    );
  }
}
