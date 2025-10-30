// lib/features/announcement/AnnouncementService.dart
import 'package:pranomiapp/features/announcement/data/announcement_model.dart';

import '../../../core/services/api_service_base.dart';

class AnnouncementService extends ApiServiceBase {
  Future<List<AnnouncementModel>?> fetchAnnouncements() {
    return getRequest<List<AnnouncementModel>>(
      path: '/pranomihelper/announcement',
      fromJson: (data) {
        if (data is List) {
          return data
              .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }
}
