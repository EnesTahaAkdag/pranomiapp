// import 'package:pranomiapp/Models/TypeEnums/EInvoiceTypeEnums.dart';

// class EInvoiceResponseModel {
//   final int count;
//   final int currentPage;
//   final int currentSize;
//   final int totalPages;
//   final List<EinvoceModel> invoices;

//   EInvoiceResponseModel({
//     required this.count,
//     required this.currentPage,
//     required this.currentSize,
//     required this.totalPages,
//     required this.invoices,
//   });

//   factory EInvoiceResponseModel.fromJson(Map<String, dynamic> json) {
//     final List invoicesJson = json['Invoices'] ?? [];
//     return EInvoiceResponseModel(
//       count: json['Count'],
//       currentPage: json['CurrentPage'],
//       currentSize: json['CurrentSize'],
//       totalPages: json['TotalPages'],
//       invoices:
//           invoicesJson
//               .map((e) => EinvoceModel.fromJson(e))
//               .toList(),
//     );
//   }
// }

// class EinvoceModel {
// final String documentNumber;
// final EInvoiceTypeEnum type;
// final int id;
// final String customerName;
// final DateTime date;
// final String uuId;
// final String status;
// final String invoiceSales;
// final String invoiceProfileId;
// final String resultData;
// final String taxNumber;
// final String taxOffice;
// final String recordType;
// }

//       "DocumentNumber": "EEA2025000000001",
//       "Type": "eArchive",
//       "Id": 4173161,
//       "CustomerName": "gülsüm arslan",
//       "Date": "2025-04-27T00:34:00",
//       "UUID": "186c2f36-9f5d-41fd-b49d-8925c603cc13",
//       "Status": "Approved",
//       "InvoiceSales": "Sale",
//       "InvoiceProfileId": "EARSIVFATURA",
//       "ResultData": null,
//       "TaxNumber": null,
//       "TaxOffice": null,
//       "RecordType": "Outgoing"
