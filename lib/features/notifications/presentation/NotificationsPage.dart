
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
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

  static IconData getIconForNotificationType(int notificationType) {
    // Placeholder logic - expand with all your types
    switch (notificationType) {
      case 6:
        return Icons.undo; // Return/Claim
      case 8:
        return Icons.delete_outline; // Delete
      default:
        return Icons.notifications_none;
    }
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
  final IconData Function(int) getIconForNotificationType;

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
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
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
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text("Tekrar Dene")),
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
            const Text('Okunacak bildirim bulunmamaktadır.', style: TextStyle(fontSize: 16)),
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
  final IconData Function(int) getIconForNotificationType;

  const _NotificationListItem({
    super.key,
    required this.notification,
    required this.dateFormatter,
    required this.getIconForNotificationType,
  });

  @override
  Widget build(BuildContext context) {
    final icon = getIconForNotificationType(notification.notificationType);
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Icon(icon, color: Colors.grey.shade800),
      ),
      title: Html(
        data: notification.description,
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(15),
            maxLines: 2,
            textOverflow: TextOverflow.ellipsis,
          ),
           "i": Style(
             // Font Awesome icons are fonts, so we can style them.
             // This is a basic style, might need a custom font if not rendering correctly.
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
        // TODO: Implement navigation to notification detail or action
        debugPrint("Notification tapped: ${notification.id}");
      },
    );
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
