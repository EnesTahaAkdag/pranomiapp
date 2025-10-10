// lib/Models/InvoiceModels/invoice_details_model.dart

class InvoiceDetailsResponseModel {
  final bool success;
  final InvoiceDetailsModel item;
  final List<String> errorMessages;
  final List<String> successMessages;
  final List<String> warningMessages;

  InvoiceDetailsResponseModel({
    required this.success,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory InvoiceDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailsResponseModel(
      success: json['Success'] as bool? ?? false,
      item: InvoiceDetailsModel.fromJson(
        json['Item'] as Map<String, dynamic>? ?? {},
      ),
      errorMessages:
          (json['ErrorMessages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      successMessages:
          (json['SuccessMessages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      warningMessages:
          (json['WarningMessages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class InvoiceDetailsModel {
  final int invoiceId;
  final String documentNumber;
  final DateTime date;
  final DateTime dueDate;
  final String customerCityName;
  final String customerDistrictName;
  final String customerAddress;
  final String customerName;
  final String? customerPhone;
  final String? taxNumber;
  final String? taxOffice;
  final String? iban;
  final double? fastExpenseTotal;
  final double? fastExpenseVatRate;
  final String email;
  final double vatRateTotalAmount;
  final double consumptionTaxTotalAmount;
  final double communicationTaxTotalAmount;
  final double balanceExcVatRate;
  final double balance;
  final List<InvoiceLineModel> invoiceLines;

  InvoiceDetailsModel({
    required this.invoiceId,
    required this.documentNumber,
    required this.date,
    required this.dueDate,
    required this.customerCityName,
    required this.customerDistrictName,
    required this.customerAddress,
    required this.customerName,
    required this.customerPhone,
    required this.taxNumber,
    required this.taxOffice,
    required this.iban,
    required this.fastExpenseTotal,
    required this.fastExpenseVatRate,
    required this.email,
    required this.vatRateTotalAmount,
    required this.consumptionTaxTotalAmount,
    required this.communicationTaxTotalAmount,
    required this.balanceExcVatRate,
    required this.balance,
    required this.invoiceLines,
  });

  factory InvoiceDetailsModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailsModel(
      invoiceId: json['InvoiceId'] as int? ?? 0,
      documentNumber: json['DocumentNumber'] as String? ?? '',
      date: DateTime.parse(json['Date'] as String),
      dueDate: DateTime.parse(json['DueDate'] as String),
      customerCityName: json['CustomerCityName'] as String? ?? '',
      customerDistrictName: json['CustomerDistrictName'] as String? ?? '',
      customerAddress: json['CustomerAddress'] as String? ?? '',
      customerName: json['CustomerName'] as String? ?? '',
      customerPhone: json['CustomerPhone'] as String?, // JSON'da null olabilir
      taxNumber: json['TaxNumber'] as String?,
      taxOffice: json['TaxOffice'] as String?,
      iban: json['Iban'] as String?,
      fastExpenseTotal: (json['FastExpenseTotal'] as num?)?.toDouble(),
      fastExpenseVatRate: (json['FastExpenseVatRate'] as num?)?.toDouble(),
      email: json['Email'] as String? ?? '',
      vatRateTotalAmount:
          (json['VatRateTotalAmount'] as num?)?.toDouble() ?? 0.0,
      consumptionTaxTotalAmount:
          (json['ConsumptionTaxTotalAmount'] as num?)?.toDouble() ?? 0.0,
      communicationTaxTotalAmount:
          (json['CommunicationTaxTotalAmount'] as num?)?.toDouble() ?? 0.0,
      balanceExcVatRate: (json['BalanceExcVatRate'] as num?)?.toDouble() ?? 0.0,
      balance: (json['Balance'] as num?)?.toDouble() ?? 0.0,
      invoiceLines:
          (json['InvoiceLines'] as List<dynamic>?)
              ?.map((e) => InvoiceLineModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class InvoiceLineModel {
  final int invoiceLineId;
  final int productId;
  final int invoiceId;
  final int currencyId;
  final int vatRateId;
  final double vatRate;
  final int unitTypeId;
  final String unitType;
  final String productName;
  final String stockCode;
  final double quantity;
  final double unitPriceExcVat;
  final double specialCommunicationTax;
  final double specialConsumptionTax;
  final double currencyExchangeRate;
  final String currencyCode;
  final double vatRateLineAmount;
  final double communicationTaxLineAmount;
  final double consumptionTaxLineAmount;
  final double lineAmountIncVatRate;

  InvoiceLineModel({
    required this.invoiceLineId,
    required this.productId,
    required this.invoiceId,
    required this.currencyId,
    required this.vatRateId,
    required this.vatRate,
    required this.unitTypeId,
    required this.unitType,
    required this.productName,
    required this.stockCode,
    required this.quantity,
    required this.unitPriceExcVat,
    required this.specialCommunicationTax,
    required this.specialConsumptionTax,
    required this.currencyExchangeRate,
    required this.currencyCode,
    required this.vatRateLineAmount,
    required this.communicationTaxLineAmount,
    required this.consumptionTaxLineAmount,
    required this.lineAmountIncVatRate,
  });

  factory InvoiceLineModel.fromJson(Map<String, dynamic> json) {
    return InvoiceLineModel(
      invoiceLineId: json['InvoiceLineId'] as int? ?? 0,
      productId: json['ProductId'] as int? ?? 0,
      invoiceId: json['InvoiceId'] as int? ?? 0,
      currencyId: json['CurrencyId'] as int? ?? 0,
      vatRateId: json['VatRateId'] as int? ?? 0,
      vatRate: (json['VatRate'] as num?)?.toDouble() ?? 0.0,
      unitTypeId: json['UnitTypeId'] as int? ?? 0,
      unitType: json['UnitType'] as String? ?? '',
      productName: json['ProductName'] as String? ?? '',
      stockCode: json['StockCode'] as String? ?? '',
      quantity: (json['Quantity'] as num?)?.toDouble() ?? 0.0,
      unitPriceExcVat: (json['UnitPriceExcVat'] as num?)?.toDouble() ?? 0.0,
      specialCommunicationTax:
          (json['SpecialCommunicationTax'] as num?)?.toDouble() ?? 0.0,
      specialConsumptionTax:
          (json['SpecialConsumptionTax'] as num?)?.toDouble() ?? 0.0,
      currencyExchangeRate:
          (json['CurrencyExchangeRate'] as num?)?.toDouble() ?? 0.0,
      currencyCode: json['CurrencyCode'] as String? ?? '',
      vatRateLineAmount: (json['VatRateLineAmount'] as num?)?.toDouble() ?? 0.0,
      communicationTaxLineAmount:
          (json['CommunicationTaxLineAmount'] as num?)?.toDouble() ?? 0.0,
      consumptionTaxLineAmount:
          (json['ConsumptionTaxLineAmount'] as num?)?.toDouble() ?? 0.0,
      lineAmountIncVatRate:
          (json['LineAmountIncVatRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
