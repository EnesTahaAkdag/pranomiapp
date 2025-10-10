class ProductStockUpdateModel {
  final int productId;
  final double stockAmount;
  final String description;

  ProductStockUpdateModel({
    required this.productId,
    required this.stockAmount,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'ProductId': productId,
    'StockAmount': stockAmount,
    'Description': description,
  };
}

class StockUpdateResponseModel {
  final bool success;
  final int item;
  final List<String> errorMessages;
  final List<String> successMessages;
  final List<String> warningMessages;

  StockUpdateResponseModel({
    required this.success,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory StockUpdateResponseModel.fromJson(Map<String, dynamic> json) {
    return StockUpdateResponseModel(
      success: json['Success'] as bool? ?? false,
      item: json['Item'] as int? ?? 0,
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}
