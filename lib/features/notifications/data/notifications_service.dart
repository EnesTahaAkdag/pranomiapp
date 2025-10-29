import '../../../core/services/api_service_base.dart';
import 'notification_model.dart';

class NotificationsService extends ApiServiceBase {
  Future<NotificationItem?> fetchNotifications({
    required int page,
    required int size,
  }) {
    return getRequest<NotificationItem?>(
      path: 'Notifications',
      queryParameters: {'page': page, 'size': size},
      fromJson: (data) => NotificationResponse.fromJson(data).item,
    );
  }
}
