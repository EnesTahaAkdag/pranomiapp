# FCM Troubleshooting Guide

## 🚨 Notifications Not Appearing - Quick Fixes

### Problem: FCM token received, but notifications not showing on device

## IMMEDIATE CHECKS

### 1. ✅ Check Notification Permissions (MOST COMMON ISSUE)

**On Android 13+ (API 33+), you MUST request notification permission at runtime!**

#### Quick Fix:

Add this code to your app to manually request permission:

```dart
// In your main screen or debug page
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  print('Permission status: ${settings.authorizationStatus}');
  // Should print: AuthorizationStatus.authorized
}
```

**Check device settings:**
1. Go to: Settings → Apps → Pranomi → Notifications
2. Make sure "All Pranomi notifications" is **ON**
3. Make sure channel "Pranomi Notifications" is **ON**

### 2. ✅ Verify FCM Token Format

Your FCM token should look like this:

```
eXampleT0ken:APA91bF... (very long string, ~150-200 characters)
```

**NOT like this:**
- ❌ Short string (< 100 chars)
- ❌ Contains only numbers
- ❌ null or undefined

**If token is wrong:**
```dart
// Force refresh token
await FirebaseMessaging.instance.deleteToken();
final newToken = await FirebaseMessaging.instance.getToken();
print('New token: $newToken');
```

### 3. ✅ Check Google Services Configuration

**Verify google-services.json:**

```bash
cat android/app/google-services.json
```

Should contain:
```json
{
  "project_info": {
    "project_number": "593870442889",
    "project_id": "pranomi-6a648"
  }
}
```

**Package name MUST match:**
- In `google-services.json`: `"package_name": "com.example.pranomiapp"`
- In `android/app/build.gradle.kts`: `applicationId = "com.example.pranomiapp"`
- In Firebase Console project settings

### 4. ✅ Test with Local Notification First

This will tell you if the issue is FCM or general notifications:

```dart
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/services/local_notification_service.dart';

final localNotif = locator<LocalNotificationService>();
await localNotif.showNotification(
  id: 1,
  title: 'Test',
  body: 'If you see this, permissions are OK!',
);
```

**If local notification works but FCM doesn't:**
- Problem is with FCM configuration
- Check Firebase Console project
- Verify google-services.json

**If local notification also doesn't work:**
- Problem is with permissions
- Check device notification settings
- Request permissions again

### 5. ✅ Check Firebase Console Notification Format

**IMPORTANT: Use correct format in Firebase Console!**

When sending test notification, Firebase Console has TWO tabs:

#### Notification Tab (Required):
```
Notification title: Test Notification
Notification text: This is a test
```

#### Data Tab (Optional - for navigation):
```
Custom data:
  Key: notificationType    Value: 1
  Key: referenceNumber     Value: 12345
```

### 6. ✅ Verify App State

Try notifications in ALL three states:

| State | How to Test | Expected Result |
|-------|-------------|-----------------|
| **Foreground** | App open and visible | Local notification overlay |
| **Background** | Press home button, app still running | System tray notification |
| **Terminated** | Force close app completely | System tray notification |

**To force close:**
- Android: Settings → Apps → Pranomi → Force Stop
- Or: Swipe away from recent apps

### 7. ✅ Check Build Configuration

**Minimum SDK must be 21+ (Android 5.0)**

Check `android/app/build.gradle.kts`:
```kotlin
defaultConfig {
    minSdk = 21  // Should be at least 21
    targetSdk = 34  // Should be recent
}
```

**If using Android 13+ (API 33+):**
```kotlin
defaultConfig {
    minSdk = 21
    targetSdk = 34  // Or higher
}
```

You MUST have `POST_NOTIFICATIONS` permission in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## DEBUGGING STEPS

### Step 1: Use the Debug Page

I've created an FCM Debug Page for you. Add it to your router or navigate to it:

```dart
import 'package:pranomiapp/features/notifications/presentation/fcm_debug_page.dart';

// Navigate to it
Navigator.push(context, MaterialPageRoute(builder: (context) => FcmDebugPage()));
```

The debug page will show:
- ✅ Current FCM token
- ✅ Permission status
- ✅ Notification settings
- ✅ Test local notifications
- ✅ Real-time message reception

### Step 2: Check Console Logs

Run your app and look for these logs:

**✅ Good Logs (everything working):**
```
FCM Permission granted: authorized
FCM Token: eXampleT0ken...
Android notification channel created
Local notifications initialized
```

**❌ Bad Logs (problems):**
```
FCM Permission granted: denied  ← Permission not granted
Error getting FCM token  ← FCM setup issue
Failed to create notification channel  ← Android config issue
```

### Step 3: Test Notification Delivery

**Send test from Firebase Console:**

1. Copy your FCM token
2. Go to Firebase Console → Messaging
3. Click "Send your first message"
4. Fill in notification
5. Click "Send test message"
6. Paste token
7. Click "Test"

**Check your device:**
- ✅ Notification appears → Everything works!
- ❌ Nothing appears → Continue troubleshooting

### Step 4: Check Device-Specific Issues

**Some devices (Samsung, Xiaomi, Huawei) have aggressive battery optimization:**

1. Go to: Settings → Battery → App optimization
2. Find: Pranomi
3. Set to: "Don't optimize" or "No restrictions"

**Also check:**
- Do Not Disturb is OFF
- Battery Saver is OFF
- App has all permissions
- App is not in "Deep sleep" (Samsung)

## COMMON ISSUES & SOLUTIONS

### Issue 1: "Notifications enabled but still not showing"

**Solution:**
```dart
// Request permissions explicitly
final messaging = FirebaseMessaging.instance;
final settings = await messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);

print('Authorization: ${settings.authorizationStatus}');
// Must be: authorized (not denied or notDetermined)
```

### Issue 2: "Token changes every time"

**Normal behavior!** FCM tokens can change when:
- App reinstalled
- App data cleared
- Device restored
- Token manually deleted

**Solution:** Always get fresh token on app start and send to backend.

### Issue 3: "Works in debug but not in release"

**Check ProGuard rules** (if using):

Create `android/app/proguard-rules.pro`:
```
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
```

In `build.gradle.kts`:
```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

### Issue 4: "Foreground notifications not showing"

**This is expected!** By default, FCM doesn't show notifications when app is in foreground.

**Our implementation DOES show them** using Local Notifications.

If not working:
1. Check local notification service is initialized
2. Check notification channel created
3. Test with local notification

### Issue 5: "Background notifications work, foreground doesn't"

**Problem:** Local notification service not initialized or channel missing.

**Solution:**
```dart
// In main.dart, ensure this runs:
final localNotificationService = locator<LocalNotificationService>();
await localNotificationService.initialize();
await localNotificationService.createNotificationChannel();
```

### Issue 6: "notification but no navigation"

**Problem:** Missing custom data in notification.

**Solution:** In Firebase Console, add custom data:
```
Key: notificationType    Value: 1
Key: referenceNumber     Value: 12345
```

## VERIFICATION CHECKLIST

Use this checklist to verify everything:

- [ ] FCM token is generated (check console logs)
- [ ] Token is valid (150+ characters, starts with letters)
- [ ] Notification permission granted (check device settings)
- [ ] Authorization status is "authorized" (not "denied")
- [ ] `google-services.json` exists in `android/app/`
- [ ] Package name matches in all configs
- [ ] `POST_NOTIFICATIONS` permission in AndroidManifest
- [ ] Local notification test works
- [ ] Notification channel created (check logs)
- [ ] Firebase Console uses correct token
- [ ] Firebase Console notification has title AND body
- [ ] App is not force-stopped on device
- [ ] Device Do Not Disturb is OFF
- [ ] Device battery optimization allows notifications
- [ ] Tested in foreground, background, AND terminated states

## ANDROID 13+ SPECIFIC ISSUES

**Android 13 (API 33) introduced runtime notification permission!**

### Quick Fix for Android 13+:

1. **Add permission to AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

2. **Request permission at runtime:**
```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermissionAndroid13() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print('Notification permission granted!');
    } else {
      print('Notification permission denied!');
      // Show dialog explaining why notifications are needed
    }
  }
}
```

Or use Firebase Messaging directly:
```dart
final settings = await FirebaseMessaging.instance.requestPermission();
print('Permission: ${settings.authorizationStatus}');
```

## TESTING COMMANDS

### Get Current FCM Token:
```dart
final token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');
```

### Check Permission Status:
```dart
final settings = await FirebaseMessaging.instance.getNotificationSettings();
print('Authorization: ${settings.authorizationStatus}');
print('Alert: ${settings.alert}');
print('Sound: ${settings.sound}');
```

### Test Local Notification:
```dart
final localNotif = locator<LocalNotificationService>();
await localNotif.showNotification(
  id: DateTime.now().millisecondsSinceEpoch,
  title: 'Test',
  body: 'If you see this, permissions work!',
);
```

### Force Token Refresh:
```dart
await FirebaseMessaging.instance.deleteToken();
final newToken = await FirebaseMessaging.instance.getToken();
print('New token: $newToken');
```

## NEXT STEPS

If none of the above works:

1. **Check Firebase Console:**
   - Is the correct project selected?
   - Is Android app registered?
   - Does package name match?

2. **Rebuild the app:**
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean && cd ..
   flutter run
   ```

3. **Try on different device:**
   - Different Android version
   - Different manufacturer
   - Emulator vs real device

4. **Enable verbose logging:**
   ```bash
   flutter run --verbose
   ```
   Look for FCM-related errors

5. **Check Firebase Console Logs:**
   - Firebase Console → Cloud Messaging → Reports
   - Look for delivery failures

## SUPPORT RESOURCES

- Firebase FCM Documentation: https://firebase.google.com/docs/cloud-messaging
- Flutter Fire Documentation: https://firebase.flutter.dev/docs/messaging/overview
- Android Notification Guide: https://developer.android.com/develop/ui/views/notifications

---

**Most Common Fix:** Request notification permission explicitly on Android 13+!

**Second Most Common:** Check device notification settings (Settings → Apps → Pranomi → Notifications)

**Third Most Common:** Verify google-services.json package name matches your app
