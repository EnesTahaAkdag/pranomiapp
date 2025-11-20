class ProductResponseModel {
  final int productId;
  final String productName;
  final String imageUrl;
  final String stockCode;
  final double stockAmount;
  final double price;
  final double vatRate;
  final String currencyCode;

  ProductResponseModel({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.stockCode,
    required this.stockAmount,
    required this.price,
    required this.vatRate,
    required this.currencyCode,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductResponseModel(
      productId: json['ProductId'],
      productName: json['ProductName'] ?? '',
      imageUrl: json['ImageUrl'] ?? '',
      stockCode: json['StockCode'] ?? '',
      stockAmount: (json['StockAmount'] ?? 0).toDouble(),
      price: (json['Price'] ?? 0).toDouble(),
      vatRate: (json['VatRate'] ?? 0).toDouble(),
      currencyCode: json['CurrencyCode'] ?? '',
    );
  }

  ProductResponseModel copyWtih({
    final int? productId,
    final String? productName,
    final String? imageUrl,
    final String? stockCode,
    final double? stockAmount,
    final double? price,
    final double? vatRate,
    final String? currencyCode,
}) {
    return ProductResponseModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      stockCode: stockCode ?? this.stockCode,
      stockAmount: stockAmount ?? this.stockAmount,
      price: price ?? this.price,
      vatRate: vatRate ?? this.vatRate,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}

class ProductStockUpdateResponseModel {
  final bool success;
  final ProductResponseModel? item;
  final String errorMessages;
  final String successMessages;
  final String warningMessages;

  ProductStockUpdateResponseModel({
    required this.success,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory ProductStockUpdateResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductStockUpdateResponseModel(
      success: json['Success'] ?? false,
      item:
          json['Item'] != null
              ? ProductResponseModel.fromJson(json['Item'])
              : null,
      errorMessages: json['ErrorMessages'] ?? '',
      successMessages: json['SuccessMessages'] ?? '',
      warningMessages: json['WarningMessages'] ?? '',
    );
  }

}
