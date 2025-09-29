// lib/features/announcement/AnnouncementService.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart'; // Assuming this is your base class
import 'package:pranomiapp/features/announcement/AnnouncementModel.dart';

class AnnouncementService extends ApiServiceBase {
  // Method to fetch all announcements
  // The API returns a List directly, not a wrapped response object like AccountService.
  Future<List<AnnouncementModel>?> fetchAnnouncements() async {
    try {
      // Get authentication headers if needed by this specific endpoint
      // If 'pranomihelper/announcement' does not require auth, you can omit this
      // or ensure getAuthHeaders() handles optional auth gracefully.
      final headers = await getAuthHeaders();

      final response = await dio.get(
        '/pranomihelper/announcement', // Your specified API endpoint
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data != null) {
        // The response.data is expected to be a List<dynamic>
        if (response.data is List) {
          List<dynamic> responseData = response.data as List<dynamic>;
          return responseData
              .map((data) => AnnouncementModel.fromJson(data as Map<String, dynamic>))
              .toList();
        } else {
          // Handle cases where response.data is not a List, though your example shows it is.
          debugPrint("Error: Expected a List but got ${response.data.runtimeType}");
          return null;
        }
      } else {
        debugPrint("Failed to fetch announcements: ${response.statusCode}, Data: ${response.data}");
        return null;
      }
    } on DioException catch (dioError) {
      debugPrint(
        'DioException fetching announcements: ${dioError.response?.data ?? dioError.message}',
      );
      return null;
    } catch (e) {
      debugPrint('General error fetching announcements: $e');
      return null;
    }
  }
}
