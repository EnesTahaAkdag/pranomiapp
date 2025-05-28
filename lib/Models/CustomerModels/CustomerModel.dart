class CustomerResponseModel {
  final int count;
  final int currentPage;
  final int currentSize;
  final int totalPages;
  final List<CustomerModel> customer;

  CustomerResponseModel({
    required this.count,
    required this.currentPage,
    required this.currentSize,
    required this.totalPages,
    required this.customer,
  });

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerResponseModel(
      count: json['Count'] ?? 0,
      currentPage: json['CurrentPage'] ?? 0,
      currentSize: json['CurrentSize'] ?? 0,
      totalPages: json['TotalPage'] ?? 0,
      customer:
          (json['Customer'] as List<dynamic>?)
              ?.map((e) => CustomerModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CustomerModel {
  final int customerId;
  final String customerName;
  final int taxNumber;
  final int phone;
  final String mail;
  final int balance;

  CustomerModel({
    required this.customerId,
    required this.customerName,
    required this.taxNumber,
    required this.phone,
    required this.mail,
    required this.balance,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: json['CustomerId'] ?? 0,
      customerName: json['CustomerName'] ?? "",
      taxNumber: json['TaxNumber'] ?? 0,
      phone: json['Phone'] ?? 0,
      mail: json['Mail'] ?? "",
      balance: json['Balance'] ?? 0,
    );
  }
}
