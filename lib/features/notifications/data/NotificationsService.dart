import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';

import 'NotificationModel.dart';

class NotificationsService extends ApiServiceBase {
  Future<NotificationItem?> fetchNotifications({
    required int page,
    required int size,
    // Type enum eklenecek
  }) async {
    try {
      final headers = await getAuthHeaders();

      String path = '/Notifications';

      final response = await dio.get(
        path = path,
        queryParameters: {'page': page, 'size': size},
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
         return NotificationItem.fromJson(response.data);
      } else {
        debugPrint("Veri alınamadı: ${response.statusCode}");
        return null;
      }
    } on DioException catch (dioError) {
      debugPrint(
        'DioException: ${dioError.response?.data ?? dioError.message}',
      );
      return null;
    } catch (e) {
      debugPrint('Genel Hata: $e');
      return null;
    }
  }
}
