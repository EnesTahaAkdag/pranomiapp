import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/widgets/app_loading_indicator.dart';
import 'package:pranomiapp/features/notifications/data/notification_enum.dart';
import 'package:pranomiapp/features/notifications/data/notification_model.dart';
import 'package:pranomiapp/features/notifications/data/notifications_service.dart';

import '../../../core/theme/app_theme.dart'; // Assuming locator is setup

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
      child: ListView.builder(
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
    ));
  }
}

// --- UI Helper Widgets ---

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: AppLoadingIndicator());
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
    final iconWidget = getIconForNotificationType(notification.eCommerceCode);

    // Bildirim türüne göre renk seçimi
    final notificationType = getNotificationTypeFromValue(notification.notificationType);
    final accentColor = _getColorForNotificationType(notificationType);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              accentColor.withValues(alpha: 0.30),
            ],
          ),
        ),
        child: Column(
          children: [
            // Üst kısım - Renkli header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.8),
                    accentColor,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  if (iconWidget != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: iconWidget,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      getNotificationNameFromType(notificationType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Alt kısım - Bilgiler
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Tarih ve Ref No yan yana
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.calendar_today_rounded,
                          label: 'Tarih',
                          value: dateFormatter.format(notification.notificationDate),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.tag_rounded,
                          label: 'Ref No',
                          value: notification.referenceNumber,
                          color: const Color(0xFF164129),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Açıklama kısmı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_rounded,
                              size: 16,
                              color: accentColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Açıklama',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Html(
                          data: notification.description,
                          style: {
                            "body": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(14),
                              maxLines: 3,
                              textOverflow: TextOverflow.ellipsis,
                              color: Colors.grey[800],
                            ),
                            "i": Style(
                              color: accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getColorForNotificationType(NotificationListTypeEnum notificationType) {
    switch (notificationType) {
    // Yeşil tonları - Olumlu durumlar
      case NotificationListTypeEnum.OrderNew:
        return const Color(0xFF4CAF50); // Yeşil - Yeni sipariş
      case NotificationListTypeEnum.OrderInvoiceOrWaybillAdd:
        return const Color(0xFF66BB6A); // Açık yeşil - Fatura/İrsaliye eklendi

    // Mavi tonları - Bilgilendirme ve güncellemeler
      case NotificationListTypeEnum.StockChange:
        return const Color(0xFF2196F3); // Mavi - Stok değişimi
      case NotificationListTypeEnum.OrderInvoiceOrWaybillUpdate:
        return const Color(0xFF42A5F5); // Açık mavi - Fatura/İrsaliye güncellendi

    // Turuncu tonları - Uyarı ve dikkat
      case NotificationListTypeEnum.ProductOutOfStock:
        return const Color(0xFFFF9800); // Turuncu - Stok tükendi
      case NotificationListTypeEnum.ClaimNew:
        return const Color(0xFFFFB74D); // Açık turuncu - Yeni talep
      case NotificationListTypeEnum.OrderInvoiceOrWaybillCancelled:
        return const Color(0xFFFF9800); // Turuncu - Fatura/İrsaliye iptal
      case NotificationListTypeEnum.EArchiceInvoiceCancel:
        return const Color(0xFFFF8A65); // Mercan turuncu - E-Arşiv iptal

    // Kırmızı tonları - Hata ve iptal durumları
      case NotificationListTypeEnum.OrderCancelled:
        return const Color(0xFFF44336); // Kırmızı - Sipariş iptal
      case NotificationListTypeEnum.OrderInvoiceOrWaybillDelete:
        return const Color(0xFFE53935); // Koyu kırmızı - Fatura/İrsaliye silindi
      case NotificationListTypeEnum.OrderInvoiceOrWaybillError:
        return const Color(0xFFD32F2F); // Daha koyu kırmızı - Fatura/İrsaliye hata
      case NotificationListTypeEnum.EDocumentError:
        return const Color(0xFFC62828); // Çok koyu kırmızı - E-Belge hatası

    // Gri tonları - Silme ve nötr durumlar
      case NotificationListTypeEnum.TransactionDelete:
        return const Color(0xFF757575); // Gri - İşlem silme

      default:
        return const Color(0xFF607D8B); // Gri-Mavi - Diğer durumlar
    }
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child: AppLoadingIndicator()),
    );
  }
}
