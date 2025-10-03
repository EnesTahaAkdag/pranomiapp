// lib/features/notifications/data/NotificationsService.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';import 'NotificationModel.dart';

class NotificationsService extends ApiServiceBase {
  Future<NotificationItem?> fetchNotifications({
    required int page,
    required int size,
  }) {
    return getRequest<NotificationItem?>(
      path: 'Notifications',
      queryParameters: {
        'page': page,
        'size': size,
      },
      fromJson: (data) => NotificationResponse.fromJson(data).item,
    );
  }
}