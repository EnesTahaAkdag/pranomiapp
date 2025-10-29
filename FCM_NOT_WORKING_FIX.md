# 🚨 FCM Notifications Not Showing - IMMEDIATE FIX

## Problem
You got the FCM token but notifications don't appear on your device.

## MOST LIKELY CAUSE: Android 13+ Permission Issue

Android 13+ requires **runtime notification permission**. Even though you have the permission in AndroidManifest.xml, you MUST request it at runtime.

## ✅ IMMEDIATE SOLUTION

### Option 1: Add Permission Checker Widget (RECOMMENDED)

I've created a widget for you to check and request permissions easily.

**Add this to your dashboard or main screen:**

```dart
import 'package:pranomiapp/features/notifications/widgets/fcm_permission_checker.dart';

// In your dashboard build method:
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      // Your existing dashboard content

      // Add this widget temporarily
      FcmPermissionChecker(),

      // Rest of your content
    ],
  );
}
```

**What it does:**
- ✅ Shows current permission status
- ✅ Shows FCM token
- ✅ Lets you request permission with one tap
- ✅ Refreshes status

### Option 2: Manual Permission Request

Add this code anywhere in your app and call it:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('Permission status: ${settings.authorizationStatus}');

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ Notifications permission granted!');
  } else {
    print('❌ Notifications permission denied!');
  }
}
```

Call this when app starts or from a button:
```dart
// In your main screen or login screen
@override
void initState() {
  super.initState();
  requestNotificationPermission();
}
```

### Option 3: Use Debug Page

I created a full debug page for you:

```dart
import 'package:pranomiapp/features/notifications/presentation/fcm_debug_page.dart';

// Navigate to it
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => FcmDebugPage()),
);
```

This page shows:
- Current FCM token
- Permission status
- Notification settings
- Test notifications button
- Request permissions button

## TESTING STEPS

### Step 1: Request Permission

1. **Add the FcmPermissionChecker widget** to your dashboard
2. **Run the app**
3. **Tap "Request Permission"** button
4. **Allow notifications** when prompted

### Step 2: Verify Permission

You should see:
```
Authorization: authorized
Alert: enabled
Sound: enabled
```

### Step 3: Test Notification

1. **Copy your FCM token** (tap on it or check console)
2. **Go to Firebase Console:**
   - https://console.firebase.google.com/
   - Project: pranomi-6a648
   - Messaging → "Send test message"
3. **Paste your token**
4. **Fill in notification:**
   ```
   Title: Test
   Text: Hello from Firebase!
   ```
5. **Click "Test"**

### Step 4: Check Result

- ✅ **Notification appears** → Fixed!
- ❌ **Still nothing** → Continue to advanced troubleshooting

## ADVANCED TROUBLESHOOTING

### Check 1: Device Notification Settings

**Go to device Settings:**
1. Settings → Apps → Pranomi
2. Notifications → Make sure "All Pranomi notifications" is ON
3. Check "Pranomi Notifications" channel is ON

### Check 2: Test Local Notification

This tests if permissions are really working:

```dart
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/services/local_notification_service.dart';

final localNotif = locator<LocalNotificationService>();
await localNotif.showNotification(
  id: 1,
  title: 'Permission Test',
  body: 'If you see this, permissions work!',
);
```

- ✅ **Appears** → FCM issue, check Firebase config
- ❌ **Doesn't appear** → Permission issue, check device settings

### Check 3: Verify Token Format

Your token should be ~150-200 characters and look like:

```
eXampleT0ken:APA91bF1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ...
```

**NOT:**
- ❌ Short (< 100 chars)
- ❌ Just numbers
- ❌ "null" or empty

### Check 4: Package Name Match

Verify package name matches everywhere:

**In android/app/google-services.json:**
```json
{
  "client": [{
    "client_info": {
      "android_client_info": {
        "package_name": "com.example.pranomiapp"
      }
    }
  }]
}
```

**In android/app/build.gradle.kts:**
```kotlin
defaultConfig {
    applicationId = "com.example.pranomiapp"  // Must match!
}
```

**In Firebase Console:**
- Project Settings → Your apps → Android app
- Package name: `com.example.pranomiapp`

### Check 5: App State

Try notifications in ALL states:

1. **Foreground** (app open):
   - Should show local notification overlay

2. **Background** (app minimized):
   - Press home button
   - Send notification
   - Should appear in system tray

3. **Terminated** (app closed):
   - Force stop app (Settings → Apps → Pranomi → Force stop)
   - Send notification
   - Should appear in system tray

## DEVICE-SPECIFIC ISSUES

### Samsung Devices

1. **Battery Optimization:**
   - Settings → Apps → Pranomi → Battery → Unrestricted

2. **Deep Sleep:**
   - Settings → Device care → Battery → Background usage limits
   - Remove Pranomi from "Sleeping apps" and "Deep sleeping apps"

### Xiaomi Devices

1. **Autostart:**
   - Settings → Apps → Manage apps → Pranomi → Autostart → Enable

2. **Battery Saver:**
   - Settings → Battery & performance → App battery saver → Pranomi → No restrictions

### Huawei Devices

1. **Protected Apps:**
   - Settings → Battery → App launch → Pranomi → Manage manually
   - Enable all options

## REBUILD APP

If nothing works, rebuild:

```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

## QUICK CHECKLIST

Run through this checklist:

- [ ] Notification permission requested at runtime
- [ ] Permission status is "authorized" (check with FcmPermissionChecker)
- [ ] FCM token generated (check console logs)
- [ ] Token is valid (150+ characters)
- [ ] Device notification settings enabled for Pranomi
- [ ] Do Not Disturb is OFF
- [ ] Battery optimization disabled for Pranomi
- [ ] Local notification test works
- [ ] Package name matches in all configs
- [ ] google-services.json exists in android/app/
- [ ] Tested in foreground, background, AND terminated

## FILES I CREATED TO HELP YOU

1. **FCM_TROUBLESHOOTING.md** - Comprehensive troubleshooting guide
2. **fcm_permission_checker.dart** - Widget to check/request permissions
3. **fcm_debug_page.dart** - Full debug page with all info
4. **FCM_NOT_WORKING_FIX.md** - This file

## WHAT TO DO NOW

### Immediate Actions:

1. **Add FcmPermissionChecker widget** to your dashboard:
   ```dart
   import 'package:pranomiapp/features/notifications/widgets/fcm_permission_checker.dart';

   // Add to your screen
   FcmPermissionChecker()
   ```

2. **Run the app**

3. **Tap "Request Permission"** in the widget

4. **Allow notifications** when prompted

5. **Copy your FCM token**

6. **Send test from Firebase Console**

7. **Check if notification appears**

### If Still Not Working:

1. Check device notification settings manually
2. Test local notification to verify permissions
3. Review FCM_TROUBLESHOOTING.md
4. Use FCM Debug Page to see detailed status
5. Try on a different device or emulator

## MOST COMMON ISSUES (90% OF CASES)

1. **Permission not requested** → Use FcmPermissionChecker widget
2. **Device settings block notifications** → Check Settings → Apps → Pranomi → Notifications
3. **Battery optimization kills app** → Disable battery optimization
4. **Package name mismatch** → Verify everywhere (see Check 4 above)

## CONTACT/SUPPORT

If you've tried everything above and notifications still don't work, provide:

1. Permission status (from FcmPermissionChecker)
2. FCM token (from console)
3. Device model and Android version
4. Console logs when sending notification
5. Screenshot of device notification settings

---

**TL;DR:** Add the FcmPermissionChecker widget, tap "Request Permission", allow notifications, and test again!
