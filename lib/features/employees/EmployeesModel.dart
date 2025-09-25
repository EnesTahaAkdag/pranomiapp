import 'dart:convert';

class EmployeesResponse {
  final int count;
  final int currentPage;
  final int currentSize;
  final int totalPages;
  final List<Employee> employees;

  EmployeesResponse({
    required this.count,
    required this.currentPage,
    required this.currentSize,
    required this.totalPages,
    required this.employees,
  });

  factory EmployeesResponse.fromJson(Map<String, dynamic> json) {
    return EmployeesResponse(
      count: json['Count'] as int,
      currentPage: json['CurrentPage'] as int,
      currentSize: json['CurrentSize'] as int,
      totalPages: json['TotalPages'] as int,
      employees: (json['Customers'] as List<dynamic>) // backend hala Customers dönüyor
          .map((e) => Employee.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Count': count,
      'CurrentPage': currentPage,
      'CurrentSize': currentSize,
      'TotalPages': totalPages,
      // geri gönderirken yine Employees yerine Customers yazıyoruz çünkü backend öyle bekliyor
      'Customers': employees.map((e) => e.toJson()).toList(),
    };
  }

  static EmployeesResponse fromRawJson(String str) =>
      EmployeesResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

class Employee {
  final int employeeId;
  final String employeeName;
  final String? employeeCode;
  final String? taxNumber;
  final String? phone;
  final String? mail;
  final double balance;

  Employee({
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    this.taxNumber,
    this.phone,
    this.mail,
    required this.balance,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['CustomerId'] as int,
      employeeName: json['CustomerName'] as String,
      employeeCode: json['CustomerCode'] as String?,
      taxNumber: json['TaxNumber'] as String?,
      phone: json['Phone'] as String?,
      mail: json['Mail'] as String?,
      balance: (json['Balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CustomerId': employeeId,
      'CustomerName': employeeName,
      'CustomerCode': employeeCode,
      'TaxNumber': taxNumber,
      'Phone': phone,
      'Mail': mail,
      'Balance': balance,
    };
  }
}
