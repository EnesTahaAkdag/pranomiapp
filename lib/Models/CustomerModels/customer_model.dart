class CustomerResponseModel {
  int? count;
  int? currentPage;
  int? currentSize;
  int? totalPages;
  List<CustomerModel>? customers;

  CustomerResponseModel({
    this.count,
    this.currentPage,
    this.currentSize,
    this.totalPages,
    this.customers,
  });

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerResponseModel(
      count: json['Count'],
      currentPage: json['CurrentPage'],
      currentSize: json['CurrentSize'],
      totalPages: json['TotalPages'],
      customers:
          (json['Customers'] as List?)
              ?.map((e) => CustomerModel.fromJson(e))
              .toList(),
    );
  }
}

class CustomerModel {
  int customerId;
  String customerName;
  String customerCode;
  String taxNumber;
  String phone;
  String mail;
  double balance;

  CustomerModel({
    required this.customerId,
    required this.customerName,
    required this.customerCode,
    required this.taxNumber,
    required this.phone,
    required this.mail,
    required this.balance,
  });
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: json['CustomerId'] ?? 0,
      customerName: json['CustomerName'] ?? '',
      customerCode: json['CustomerCode'] ?? '',
      taxNumber: json['TaxNumber'] ?? '',
      phone: json['Phone'] ?? '',
      mail: json['Mail'] ?? '',
      balance: (json['Balance'] ?? 0).toDouble(),
    );
  }
}
