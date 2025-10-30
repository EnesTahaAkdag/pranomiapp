import 'package:flutter/material.dart';

class NotificationResponse {
  final bool success;
  final int statusCode;
  final NotificationItem? item;

  NotificationResponse({
    required this.success,
    required this.statusCode,
    this.item,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['Success'] ?? false,
      statusCode: json['StatusCode'] ?? 0,
      item:
          json['Item'] != null ? NotificationItem.fromJson(json['Item']) : null,
    );
  }
}

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
    // --- THIS IS THE FIX ---
    // Safely parse the list of notifications, defaulting to an empty list if null.
    List<CustomerNotification> notifications = [];
    if (json['customerNotifications'] != null &&
        json['customerNotifications'] is List) {
      notifications =
          (json['customerNotifications'] as List<dynamic>)
              .map(
                (e) => CustomerNotification.fromJson(e as Map<String, dynamic>),
              )
              .toList();
    }

    return NotificationItem(
      count: json['Count'] ?? 0,
      currentPage: json['CurrentPage'] ?? 0,
      currentSize: json['CurrentSize'] ?? 0,
      totalPages: json['TotalPages'] ?? 0,
      customerNotifications: notifications, // Use the safely parsed list
    );
  }
}

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
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['NotificationDate'] as String);
    } catch (e) {
      parsedDate = DateTime.now(); // Fallback to current time on parsing error
      debugPrint(
        "Error parsing NotificationDate: \${json['NotificationDate']}",
      );
    }

    return CustomerNotification(
      id: json['Id'] ?? 0,
      referenceNumber: json['ReferenceNumber'] ?? '',
      notificationDate: parsedDate,
      notificationType: json['NotificationType'] ?? 0,
      eCommerceCode: json['ECommerceCode'],
      description: json['Description'] ?? '',
      invoiceType: json['InvoiceType'] ?? 0,
    );
  }
}
