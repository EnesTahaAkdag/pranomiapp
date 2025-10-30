import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';

/// Widget to check and request FCM permissions
/// Add this temporarily to your dashboard or main screen to debug
class FcmPermissionChecker extends StatefulWidget {
  const FcmPermissionChecker({super.key});

  @override
  State<FcmPermissionChecker> createState() => _FcmPermissionCheckerState();
}

class _FcmPermissionCheckerState extends State<FcmPermissionChecker> {
  String? _status;
  String? _token;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);

    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      final token = await FirebaseMessaging.instance.getToken();

      if (mounted) {
        setState(() {
          _status = 'Authorization: ${settings.authorizationStatus.name}\n'
              'Alert: ${settings.alert.name}\n'
              'Sound: ${settings.sound.name}';
          _token = token;
          _isLoading = false;
        });

        debugPrint('=== FCM PERMISSION CHECK ===');
        debugPrint('Authorization: ${settings.authorizationStatus}');
        debugPrint('Token: $token');
        debugPrint('========================');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _isLoading = true);

    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission: ${settings.authorizationStatus.name}'),
            backgroundColor: settings.authorizationStatus == AuthorizationStatus.authorized
                ? Colors.green
                : Colors.orange,
          ),
        );

        await _checkStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: AppTheme.accentColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active, color: AppTheme.accentColor),
                SizedBox(width: 8),
                Text(
                  'FCM Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
               Center(child:  LoadingAnimationWidget.staggeredDotsWave(
                // LoadingAnimationwidget that call the
                 color: AppTheme.accentColor, // staggereddotwave animation
                size: 50,
              ))
            else ...[
              if (_status != null) ...[
                Text(
                  _status!,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 8),
              ],
              if (_token != null) ...[
                const Text(
                  'Token (tap to copy):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    if (_token != null) {
                      // Copy to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Token copied! (check console)')),
                      );
                      debugPrint('FCM TOKEN: $_token');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_token!.substring(0, 40)}...',
                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _requestPermission,
                      icon: const Icon(Icons.privacy_tip, size: 16),
                      label: const Text('Request Permission'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _checkStatus,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
