import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/services/fcm_service.dart';
import 'package:pranomiapp/core/services/local_notification_service.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';

/// FCM Debug Page - Helps identify notification issues
class FcmDebugPage extends StatefulWidget {
  const FcmDebugPage({super.key});

  @override
  State<FcmDebugPage> createState() => _FcmDebugPageState();
}

class _FcmDebugPageState extends State<FcmDebugPage> {
  final fcmService = locator<FcmService>();
  final localNotificationService = locator<LocalNotificationService>();

  String? _fcmToken;
  bool? _notificationsEnabled;
  NotificationSettings? _notificationSettings;
  bool _isLoading = true;
  String _lastMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
    _setupListeners();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoading = true);

    try {
      final token = await fcmService.getFCMToken();
      final enabled = await fcmService.areNotificationsEnabled();
      final settings = await fcmService.getNotificationSettings();

      if (mounted) {
        setState(() {
          _fcmToken = token;
          _notificationsEnabled = enabled;
          _notificationSettings = settings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastMessage = 'Error loading debug info: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _setupListeners() {
    // Listen for foreground messages
    fcmService.onForegroundMessage = (message) {
      setState(() {
        _lastMessage = 'Foreground: ${message.notification?.title ?? "No title"}';
      });
      debugPrint('DEBUG: Foreground message received: ${message.notification?.title}');
    };

    // Listen for notification taps
    fcmService.onNotificationTap = (message) {
      setState(() {
        _lastMessage = 'Tapped: ${message.notification?.title ?? "No title"}';
      });
      debugPrint('DEBUG: Notification tapped: ${message.notification?.title}');
    };
  }

  void _copyTokenToClipboard() {
    if (_fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FCM Token copied to clipboard!')),
      );
    }
  }

  Future<void> _testLocalNotification() async {
    try {
      await localNotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Test Notification',
        body: 'This is a local test notification - ${DateTime.now()}',
      );

      if (mounted) {
        setState(() {
          _lastMessage = 'Local notification sent!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastMessage = 'Error sending local notification: $e';
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (mounted) {
        setState(() {
          _notificationSettings = settings;
          _lastMessage = 'Permission status: ${settings.authorizationStatus}';
        });
        await _loadDebugInfo();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastMessage = 'Error requesting permissions: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Debug'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading
          ?  Center(child:  LoadingAnimationWidget.staggeredDotsWave(
        // LoadingAnimationwidget that call the
        color: AppTheme.accentColor, // staggereddotwave animation
        size: 50,
      ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'FCM Token',
                    _fcmToken != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _fcmToken!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _copyTokenToClipboard,
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy Token'),
                              ),
                            ],
                          )
                        : const Text('No token available'),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Notification Settings',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'Enabled',
                          _notificationsEnabled == true
                              ? '✅ Yes'
                              : '❌ No',
                          _notificationsEnabled == true
                              ? Colors.green
                              : Colors.red,
                        ),
                        if (_notificationSettings != null) ...[
                          _buildInfoRow(
                            'Authorization',
                            _notificationSettings!.authorizationStatus.name,
                            _notificationSettings!.authorizationStatus ==
                                    AuthorizationStatus.authorized
                                ? Colors.green
                                : Colors.orange,
                          ),
                          _buildInfoRow(
                            'Alert',
                            _notificationSettings!.alert.name,
                            null,
                          ),
                          _buildInfoRow(
                            'Sound',
                            _notificationSettings!.sound.name,
                            null,
                          ),
                          _buildInfoRow(
                            'Badge',
                            _notificationSettings!.badge.name,
                            null,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Last Message',
                    Text(
                      _lastMessage.isEmpty ? 'No messages yet' : _lastMessage,
                      style: TextStyle(
                        color: _lastMessage.isEmpty
                            ? Colors.grey
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Test Actions',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _testLocalNotification,
                          icon: const Icon(Icons.notifications),
                          label: const Text('Send Test Local Notification'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _requestPermissions,
                          icon: const Icon(Icons.privacy_tip),
                          label: const Text('Request Permissions Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _loadDebugInfo,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Info'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Troubleshooting Tips',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTip(
                          '1. Check Authorization Status',
                          'Should be "authorized" or "provisional"',
                        ),
                        _buildTip(
                          '2. Copy Token',
                          'Use the copied token in Firebase Console',
                        ),
                        _buildTip(
                          '3. Test Local Notification',
                          'If this works, FCM permissions are OK',
                        ),
                        _buildTip(
                          '4. Check App State',
                          'Try with app in foreground, background, and terminated',
                        ),
                        _buildTip(
                          '5. Device Settings',
                          'Check notification settings in device Settings app',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, size: 20, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
