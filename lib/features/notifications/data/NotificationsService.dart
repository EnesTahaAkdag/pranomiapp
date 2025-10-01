// lib/features/notifications/data/NotificationsService.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';import 'NotificationModel.dart';

class NotificationsService extends ApiServiceBase {
  Future<NotificationItem?> fetchNotifications({
    required int page,
    required int size,
  }) async {
    try {
      final headers = await getAuthHeaders();
      const String path = '/Notifications'; // Simplified path definition

      final response = await dio.get(
        path, // Use const path
        queryParameters: {'page': page, 'size': size},
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data != null) {
        // --- THIS IS THE FIX ---
        // Parse the full response, then return the 'item' from it.
        return NotificationResponse.fromJson(response.data).item;
      } else {
        debugPrint("Veri alınamadı: ${response.statusCode}");
        return null;
      }
    } on DioException catch (dioError) {
      debugPrint('DioException: ${dioError.response?.data ?? dioError.message}');
      return null;
    } catch (e) {
      debugPrint('Genel Hata: $e');
      return null;
    }
  }
}