# FCM Implementation Summary

## Overview

Firebase Cloud Messaging (FCM) has been fully implemented for the Pranomi app. The system handles push notifications in all app states (foreground, background, terminated) and includes navigation to specific app sections based on notification data.

## What Was Implemented

### 1. Core Services

#### FcmService (`lib/core/services/fcm_service.dart`)
- Manages FCM token lifecycle
- Handles permission requests (iOS/Android)
- Listens for token refresh
- Manages topic subscriptions
- Provides callbacks for message handling
- Background message handler support

**Key Methods:**
- `initialize()` - Initialize FCM and request permissions
- `getFCMToken()` - Get current device token
- `subscribeToTopic(topic)` - Subscribe to notification topics
- `deleteToken()` - Delete token on logout

#### LocalNotificationService (`lib/core/services/local_notification_service.dart`)
- Displays notifications when app is in foreground
- Creates Android notification channels
- Handles notification taps
- Customizable notification appearance

**Key Methods:**
- `initialize()` - Initialize local notifications
- `createNotificationChannel()` - Create Android channel
- `showNotificationFromFirebase(message)` - Display Firebase notification
- `showNotification()` - Show custom notification

### 2. Notification Handler

#### FcmNotificationHandler (`lib/features/notifications/data/fcm_notification_handler.dart`)
- Integrates FCM and local notifications
- Handles navigation based on notification data
- Manages notification tap events
- Supports 6 notification types with routing

**Notification Types:**
1. Invoice (`type: 1`) → Navigate to invoice details
2. E-Invoice (`type: 2`) → Navigate to e-invoice details
3. Customer (`type: 3`) → Navigate to customer details
4. Credit (`type: 4`) → Navigate to credit page
5. Announcement (`type: 5`) → Navigate to announcements
6. Product (`type: 6`) → Navigate to product details

### 3. Integration Points

#### main.dart
- Firebase initialized before app start
- Background message handler registered
- FCM service initialized
- Local notifications initialized
- Notification channel created

#### Dependency Injection (injection.dart)
- `FcmService` registered as singleton
- `LocalNotificationService` registered as singleton

#### Android Configuration (AndroidManifest.xml)
- Required permissions added:
  - `INTERNET`
  - `POST_NOTIFICATIONS`
  - `VIBRATE`
  - `RECEIVE_BOOT_COMPLETED`
- FCM metadata configured:
  - Default notification channel
  - Default notification icon
  - Default notification color

## File Structure

```
lib/
├── core/
│   ├── services/
│   │   ├── fcm_service.dart                    # FCM core service
│   │   └── local_notification_service.dart     # Local notifications
│   └── di/
│       └── injection.dart                      # DI registration
├── features/
│   └── notifications/
│       └── data/
│           └── fcm_notification_handler.dart   # Navigation handler
├── main.dart                                   # FCM initialization
└── firebase_options.dart                       # Firebase config

android/
└── app/
    └── src/
        └── main/
            └── AndroidManifest.xml             # Android permissions
```

## How It Works

### Flow Diagram

```
App Starts
    ↓
Firebase Initialized
    ↓
FCM Service Initialized
    ↓
Token Generated & Logged
    ↓
[Notification Received]
    ↓
┌──────────────────────┐
│  App State?          │
└──────┬───────────────┘
       │
   ┌───┴───┐
   │       │
Foreground Background/Terminated
   │       │
   ↓       ↓
Show Local  System Notification
Notification    │
   │            │
   └────┬───────┘
        ↓
   [User Taps]
        ↓
Parse Notification Data
        ↓
Navigate Based on Type
        ↓
   Show Screen
```

### Notification Processing

1. **Token Generation:**
   ```
   App Launch → FCM Service → Request Permissions → Generate Token → Log to Console
   ```

2. **Foreground Notification:**
   ```
   FCM Message → onForegroundMessage Callback → LocalNotificationService
   → Show Notification → User Taps → Navigate
   ```

3. **Background Notification:**
   ```
   FCM Message → System Tray → User Taps → onNotificationTap Callback → Navigate
   ```

4. **Terminated State Notification:**
   ```
   FCM Message → System Tray → User Taps → App Launches
   → getInitialMessage() → Navigate
   ```

## Configuration

### Current Settings

**Notification Channel:**
- ID: `pranomi_notifications`
- Name: `Pranomi Notifications`
- Importance: High
- Sound: Enabled
- Vibration: Enabled

**Notification Appearance:**
- Icon: App launcher icon
- Color: White
- Priority: High

## Testing

### Get FCM Token

When you run the app, look for this in the console:

```
FCM Token: [LONG_TOKEN_STRING]
```

Copy this token for testing in Firebase Console.

### Send Test Notification

1. Go to Firebase Console
2. Select `pranomi-6a648` project
3. Navigate to **Messaging**
4. Click "Send your first message"
5. Fill in notification details
6. Click "Send test message"
7. Paste your FCM token
8. Click "Test"

### Test Navigation

Include custom data in your test notification:

**Example for Invoice Notification:**
```
Custom Data:
  notificationType = 1
  referenceNumber = 12345
```

This will navigate to `/invoice/detail/12345` when tapped.

## Backend Integration (Future)

### API Endpoints to Implement

#### 1. Register Device Token
```
POST /user/register-device
Body: {
  "fcm_token": "string",
  "platform": "android" | "ios"
}
```

**When to call:** After successful login

**Implementation location:**
```dart
FcmNotificationHandler.sendTokenToBackend()
```

#### 2. Unregister Device Token
```
POST /user/unregister-device
Body: {
  "fcm_token": "string"
}
```

**When to call:** On user logout

**Implementation location:**
```dart
FcmNotificationHandler.removeTokenFromBackend()
```

#### 3. Send Notification (Backend)
```
POST /notification/send
Body: {
  "user_id": "string",
  "title": "string",
  "body": "string",
  "data": {
    "notificationType": "1-6",
    "referenceNumber": "string"
  }
}
```

### Integration Steps

1. **Update `FcmNotificationHandler.sendTokenToBackend()`:**
   ```dart
   // Replace TODO with actual API call
   final dio = Dio();
   await dio.post(
     'https://apitest.pranomi.com/user/register-device',
     data: {
       'fcm_token': token,
       'platform': Platform.isAndroid ? 'android' : 'ios',
     },
   );
   ```

2. **Call after Login:**
   ```dart
   // In LoginPageViewModel after successful login
   await FcmNotificationHandler.sendTokenToBackend();
   ```

3. **Call on Logout:**
   ```dart
   // In logout flow
   await FcmNotificationHandler.removeTokenFromBackend();
   ```

## Notification Payload Format

### Expected Backend Format

```json
{
  "notification": {
    "title": "Notification Title",
    "body": "Notification message body"
  },
  "data": {
    "notificationType": "1",
    "referenceNumber": "12345",
    "invoiceType": "purchase"
  }
}
```

### Notification Type Reference

| Type | Value | Target | Data Required |
|------|-------|--------|---------------|
| Invoice | `1` | `/invoice/detail/{ref}` | `referenceNumber` |
| E-Invoice | `2` | `/e-invoice/detail/{ref}` | `referenceNumber` |
| Customer | `3` | `/customer/detail/{ref}` | `referenceNumber` |
| Credit | `4` | `/credit` | None |
| Announcement | `5` | `/announcements` | None |
| Product | `6` | `/product/detail/{ref}` | `referenceNumber` |

## Features

### ✅ Implemented

- [x] FCM token generation
- [x] Token refresh handling
- [x] Permission requests (iOS/Android)
- [x] Foreground notification display
- [x] Background notification handling
- [x] Terminated state notification handling
- [x] Notification tap navigation
- [x] 6 notification types with routing
- [x] Android notification channel
- [x] Local notification service
- [x] Topic subscription support
- [x] Token persistence
- [x] Background message handler

### 🔄 Pending Backend Integration

- [ ] Send token to backend API
- [ ] Remove token on logout API
- [ ] Backend notification sending
- [ ] User-specific topic subscriptions
- [ ] Notification history sync

## Testing Checklist

Use the comprehensive testing guide: `FCM_TESTING_GUIDE.md`

**Quick Test:**
1. ✅ Run app and get FCM token
2. ✅ Send test notification from Firebase Console
3. ✅ Verify notification appears
4. ✅ Tap notification
5. ✅ Verify navigation works

## Debugging

### Common Issues

**Issue: Token not appearing**
- Check internet connection
- Verify Firebase initialization
- Check console for errors

**Issue: Notifications not showing (foreground)**
- Verify local notifications initialized
- Check notification channel created
- Verify permissions granted

**Issue: Navigation not working**
- Check notification data format
- Verify routes exist in app_router.dart
- Check console logs for navigation errors

### Debug Commands

```dart
// Get current token
final token = await FcmNotificationHandler.getCurrentToken();
print('Token: $token');

// Check if notifications enabled
final enabled = await FcmNotificationHandler.areNotificationsEnabled();
print('Enabled: $enabled');

// Show test notification
final localNotif = locator<LocalNotificationService>();
await localNotif.showNotification(
  id: 1,
  title: 'Test',
  body: 'Test notification',
);
```

## Performance Considerations

- FCM token cached in SharedPreferences
- Services registered as singletons
- Background handler uses isolate
- Minimal battery impact
- Efficient notification processing

## Security Notes

- FCM token is device-specific
- Token should be sent securely to backend
- Validate notification data before navigation
- Don't expose sensitive data in notifications
- Use HTTPS for all API calls

## Documentation

- **FCM Testing Guide:** `FCM_TESTING_GUIDE.md`
- **Implementation Summary:** This file
- **Firebase Options:** `firebase_options.dart`
- **Setup Guide:** `FCM_SETUP_GUIDE.md` (if exists)

## Support

### Logging

All FCM operations are logged with `debugPrint`:
- Token generation
- Permission status
- Message reception
- Navigation events
- Topic subscriptions

### Console Output Examples

```
FCM Permission granted: authorized
FCM Token: eXampleT0ken...
Android notification channel created
Local notifications initialized
Foreground message received
Title: New Invoice
Body: Invoice #12345 created
Data: {notificationType: 1, referenceNumber: 12345}
Navigation data - Type: 1, Ref: 12345
```

## Next Steps

1. **Test thoroughly** using Firebase Console
2. **Verify all notification types** navigate correctly
3. **Test on physical devices** (Android & iOS)
4. **Document backend API** requirements
5. **Implement backend integration** when ready
6. **Add analytics** for notification engagement
7. **Consider rich notifications** (images, actions)

---

**Status:** ✅ Complete - Ready for Testing
**Created:** 2025-10-20
**Version:** 1.0
