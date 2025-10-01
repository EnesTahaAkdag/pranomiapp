import 'dart:convert';

class NotificationResponse {
  final bool success;
  final int statusCode;
  final NotificationItem item;

  NotificationResponse({
    required this.success,
    required this.statusCode,
    required this.item,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['Success'] ?? false,
      statusCode: json['StatusCode'] ?? 0,
      item: NotificationItem.fromJson(json['Item']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Success': success,
      'StatusCode': statusCode,
      'Item': item.toJson(),
    };
  }
}

/// Item İçeriği
class NotificationItem {
  final int count;
  final int currentPage;
  final int currentSize;
  final int totalPages;
  final List<CustomerNotification> customerNotifications;

  NotificationItem({
    required this.count,
    required this.currentPage,
    required this.currentSize,
    required this.totalPages,
    required this.customerNotifications,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      count: json['Count'] ?? 0,
      currentPage: json['CurrentPage'] ?? 0,
      currentSize: json['CurrentSize'] ?? 0,
      totalPages: json['TotalPages'] ?? 0,
      customerNotifications: (json['customerNotifications'] as List<dynamic>)
          .map((e) => CustomerNotification.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Count': count,
      'CurrentPage': currentPage,
      'CurrentSize': currentSize,
      'TotalPages': totalPages,
      'customerNotifications':
      customerNotifications.map((e) => e.toJson()).toList(),
    };
  }
}

/// customerNotifications Detayı
class CustomerNotification {
  final int id;
  final String referenceNumber;
  final DateTime notificationDate;
  final int notificationType;
  final String? eCommerceCode;
  final String description;
  final int invoiceType;

  CustomerNotification({
    required this.id,
    required this.referenceNumber,
    required this.notificationDate,
    required this.notificationType,
    this.eCommerceCode,
    required this.description,
    required this.invoiceType,
  });

  factory CustomerNotification.fromJson(Map<String, dynamic> json) {
    return CustomerNotification(
      id: json['Id'] ?? 0,
      referenceNumber: json['ReferenceNumber'] ?? '',
      notificationDate: DateTime.parse(json['NotificationDate']),
      notificationType: json['NotificationType'] ?? 0,
      eCommerceCode: json['ECommerceCode'],
      description: json['Description'] ?? '',
      invoiceType: json['InvoiceType'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'ReferenceNumber': referenceNumber,
      'NotificationDate': notificationDate.toIso8601String(),
      'NotificationType': notificationType,
      'ECommerceCode': eCommerceCode,
      'Description': description,
      'InvoiceType': invoiceType,
    };
  }
}