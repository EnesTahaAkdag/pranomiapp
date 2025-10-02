import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/features/notifications/data/NotificationEnum.dart';
import 'package:pranomiapp/features/notifications/data/NotificationModel.dart';
import 'package:pranomiapp/features/notifications/data/NotificationsService.dart';
import 'package:pranomiapp/core/di/Injection.dart'; // Assuming locator is setup

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsService _notificationsService;
  final List<CustomerNotification> _notifications = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  int _totalPages = 1;
  String? _error;

  static final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _notificationsService = locator<NotificationsService>();
    _scrollController.addListener(_onScroll);
    _fetchNotifications(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _notifications.clear();
        _error = null;
      });
    } else {
      if (_isLoadingMore || _currentPage >= _totalPages) return;
      setState(() {
        _isLoadingMore = true;
        _error = null;
      });
    }

    try {
      final notificationItem = await _notificationsService.fetchNotifications(
        page: _currentPage,
        size: 20,
      );

      if (mounted) {
        if (notificationItem != null) {
          setState(() {
            _notifications.addAll(notificationItem.customerNotifications);
            _currentPage = notificationItem.currentPage + 1;
            _totalPages = notificationItem.totalPages;
          });
        } else if (isRefresh) {
          _error = "Bildirimler yüklenemedi.";
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Bir hata oluştu: ${e.toString()}";
        });
        debugPrint("Error fetching notifications: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _totalPages) {
      _fetchNotifications();
    }
  }

  // MODIFIED: This function is now more robust.
  static Widget? getIconForNotificationType(String? eCommerceCode) {
    // If no code is provided, return null to show nothing.
    if (eCommerceCode == null || eCommerceCode.trim().isEmpty) {
      return null;
    }
    // Return an Image.network widget with a crucial errorBuilder.
    return Image.network(
      "https://panel.pranomi.com/images/eCommerceLogo/${eCommerceCode.toLowerCase()}.png",
      errorBuilder: (context, error, stackTrace) {
        // If the image fails to load (e.g., 404 Not Found),
        // return an empty widget instead of an error icon.
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _NotificationsPageBody(
        isLoading: _isLoading,
        isLoadingMore: _isLoadingMore,
        error: _error,
        notifications: _notifications,
        scrollController: _scrollController,
        onRefresh: () => _fetchNotifications(isRefresh: true),
        dateFormatter: _dateFormatter,
        getIconForNotificationType: getIconForNotificationType,
      ),
    );
  }
}

// --- Extracted Body Widget ---
class _NotificationsPageBody extends StatelessWidget {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final List<CustomerNotification> notifications;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final DateFormat dateFormatter;

  // MODIFIED: The function now returns a Widget? instead of Image?
  final Widget? Function(String?) getIconForNotificationType;

  const _NotificationsPageBody({
    required this.isLoading,
    required this.isLoadingMore,
    required this.error,
    required this.notifications,
    required this.scrollController,
    required this.onRefresh,
    required this.dateFormatter,
    required this.getIconForNotificationType,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && notifications.isEmpty) {
      return const _LoadingView();
    }

    if (error != null && notifications.isEmpty) {
      return _ErrorView(error: error!, onRetry: onRefresh);
    }

    if (notifications.isEmpty) {
      return _EmptyView(onRefresh: onRefresh);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: notifications.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == notifications.length) {
            return const _LoadingMoreIndicator();
          }
          final notification = notifications[index];
          return _NotificationListItem(
            key: ValueKey(notification.id),
            notification: notification,
            dateFormatter: dateFormatter,
            getIconForNotificationType: getIconForNotificationType,
          );
        },
        separatorBuilder:
            (context, index) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
      ),
    );
  }
}

// --- UI Helper Widgets ---

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Tekrar Dene"),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Okunacak bildirim bulunmamaktadır.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRefresh, child: const Text("Yenile")),
          ],
        ),
      ),
    );
  }
}

class _NotificationListItem extends StatelessWidget {
  final CustomerNotification notification;
  final DateFormat dateFormatter;

  // MODIFIED: The function now returns a Widget? instead of Image?
  final Widget? Function(String?) getIconForNotificationType;

  const _NotificationListItem({
    super.key,
    required this.notification,
    required this.dateFormatter,
    required this.getIconForNotificationType,
  });

  @override
  Widget build(BuildContext context) {
    // This now returns a full widget with error handling, or null.
    final iconWidget = getIconForNotificationType(notification.eCommerceCode);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (iconWidget != null)
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: iconWidget,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    getNotificationNameFromType(
                      getNotificationTypeFromValue(
                        notification.notificationType,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tarih: ${dateFormatter.format(notification.notificationDate)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const SizedBox(height: 4),
            Text(
              "Ref No: ${notification.referenceNumber}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 6),
            Html(
              data: "Açıklama: ${notification.description}",
              style: {
                "body": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(15),
                  maxLines: 2,
                  textOverflow: TextOverflow.ellipsis,
                ),
                "i": Style(color: Theme.of(context).primaryColor),
              },
            ),
          ],
        ),
      ),
    );

    /**   return ListTile(
        leading: iconWidget != null
        ? CircleAvatar(
        backgroundColor: Colors.white,
        child: iconWidget,
        )
        : null,
        title: Html(
        data: getNotificationNameFromType(getNotificationTypeFromValue(notification.notificationType)),
        style: {
        "body": Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        fontSize: FontSize(15),
        maxLines: 2,
        textOverflow: TextOverflow.ellipsis,
        ),
        "i": Style(
        color: Theme.of(context).primaryColor,
        ),
        },
        ),
        subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
        dateFormatter.format(notification.notificationDate),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        ),
        onTap: () {
        debugPrint("Notification tapped: ${notification.id}");
        },
        ); **/
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
