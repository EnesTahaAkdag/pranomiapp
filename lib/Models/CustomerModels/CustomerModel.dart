class CustomerResponseModel {
  final int count;
  final int currentPage;
  final int currentSize;
  final int totalPages;
  final List<CustomerModel> customers;

  CustomerResponseModel({
    required this.count,
    required this.currentPage,
    required this.currentSize,
    required this.totalPages,
    required this.customers,
  });

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerResponseModel(
      count: json['Count'] ?? 0,
      currentPage: json['CurrentPage'] ?? 0,
      currentSize: json['CurrentSize'] ?? 0,
      totalPages: json['TotalPages'] ?? 0,
      customers:
          (json['Customers'] as List<dynamic>? ?? [])
              .map((e) => CustomerModel.fromJson(e))
              .toList(),
    );
  }
}

class CustomerModel {
  final int customerId;
  final String customerName;
  final String taxNumber;
  final String phone;
  final String mail;
  final double balance;

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
      customerName: json['CustomerName'] ?? '',
      taxNumber: json['TaxNumber'] ?? '',
      phone: json['Phone'] ?? '',
      mail: json['Mail'] ?? '',
      balance:
          (json['Balance'] is int)
              ? (json['Balance'] as int).toDouble()
              : (double.tryParse(json['Balance'].toString()) ?? 0.0),
    );
  }
}
