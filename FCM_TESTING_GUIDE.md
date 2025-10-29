# Firebase Cloud Messaging (FCM) Testing Guide

## Overview

This guide explains how to test Firebase Cloud Messaging (FCM) notifications for the Pranomi app using Firebase Console before the backend is ready.

## Prerequisites

- Firebase project configured (`pranomi-6a648`)
- App running on a physical device or emulator
- Firebase Console access: https://console.firebase.google.com/

## Quick Start

### 1. Get Your FCM Token

When you run the app, the FCM token will be printed in the console. Look for:

```
FCM Token: [YOUR_DEVICE_TOKEN_HERE]
```

**How to find it:**
1. Run the app: `flutter run`
2. Look in the console output for `FCM Token:`
3. Copy the entire token (it's a long string)

### 2. Send a Test Notification from Firebase Console

#### Method 1: Using Firebase Console (Recommended for Testing)

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Select project: `pranomi-6a648`

2. **Navigate to Cloud Messaging**
   - Click "Messaging" in the left sidebar
   - Click "Send your first message" or "New campaign"

3. **Configure Notification**

   **Notification Tab:**
   ```
   Title: Test Notification
   Text: This is a test notification from Firebase Console
   ```

   **Target Tab:**
   - Select "Send test message"
   - Paste your FCM token
   - Click "Test"

4. **Check Your App**
   - If app is in foreground: You'll see a notification appear
   - If app is in background: Notification appears in system tray
   - Tap the notification to test navigation

## Notification Formats

### Basic Notification (Display Only)

Send this from Firebase Console:

**Notification fields:**
- Title: `Invoice Updated`
- Body: `Your invoice #12345 has been updated`
- Image: (optional)

**Result:** Shows notification, no special navigation

### Notification with Data (Navigation)

To test navigation features, you need to include custom data:

**Notification fields:**
- Title: `New Invoice`
- Body: `Invoice #12345 requires your attention`

**Additional Options → Custom Data:**

| Key | Value | Description |
|-----|-------|-------------|
| `notificationType` | `1` | Invoice notification |
| `referenceNumber` | `12345` | Invoice ID |

### Notification Types

Use these `notificationType` values for different navigation:

| Type | Value | Navigation Target | Example Data |
|------|-------|-------------------|--------------|
| Invoice | `1` | `/invoice/detail/{referenceNumber}` | `notificationType=1`, `referenceNumber=12345` |
| E-Invoice | `2` | `/e-invoice/detail/{referenceNumber}` | `notificationType=2`, `referenceNumber=67890` |
| Customer | `3` | `/customer/detail/{referenceNumber}` | `notificationType=3`, `referenceNumber=100` |
| Credit | `4` | `/credit` | `notificationType=4` |
| Announcement | `5` | `/announcements` | `notificationType=5` |
| Product | `6` | `/product/detail/{referenceNumber}` | `notificationType=6`, `referenceNumber=200` |

## Testing Scenarios

### Scenario 1: App in Foreground

**Expected Behavior:**
1. Notification appears as a local notification overlay
2. User can tap to navigate
3. Notification is logged in console

**Test Steps:**
1. Open the app
2. Send notification from Firebase Console
3. Verify notification appears
4. Tap notification
5. Verify navigation works

### Scenario 2: App in Background

**Expected Behavior:**
1. Notification appears in system tray
2. Tapping opens app and navigates
3. Notification logged in console

**Test Steps:**
1. Open app, then press home button
2. Send notification from Firebase Console
3. Verify notification in system tray
4. Tap notification
5. Verify app opens and navigates

### Scenario 3: App Terminated

**Expected Behavior:**
1. Notification appears in system tray
2. Tapping launches app and navigates
3. Notification handled on launch

**Test Steps:**
1. Close app completely
2. Send notification from Firebase Console
3. Verify notification in system tray
4. Tap notification
5. Verify app launches and navigates

## Using Firebase Console UI

### Step-by-Step: Send Test Message

1. **Access Messaging:**
   ```
   Firebase Console → Project "pranomi-6a648" → Messaging
   ```

2. **Click "Send your first message" or "New campaign"**

3. **Notification Tab:**
   ```
   Notification title: New Invoice
   Notification text: Invoice #12345 needs your attention
   Notification image: (optional - leave empty)
   Notification name: test-invoice-notification
   ```

4. **Target Tab:**
   - Select: "Send test message"
   - Add FCM registration token: [Paste your device token]
   - Click "Test"

5. **Additional Options (for navigation testing):**
   - Expand "Additional options"
   - Scroll to "Custom data"
   - Add key-value pairs:
     ```
     Key: notificationType
     Value: 1

     Key: referenceNumber
     Value: 12345
     ```

6. **Click "Test"**

### Send to Multiple Devices

Instead of "Send test message", you can:
1. Select "User segment"
2. Choose criteria (e.g., "All users")
3. Click "Next" → "Review" → "Publish"

## Advanced Testing

### Test Notification Payload Examples

#### Example 1: Invoice Notification
```json
{
  "notification": {
    "title": "Invoice Created",
    "body": "Invoice #12345 has been created"
  },
  "data": {
    "notificationType": "1",
    "referenceNumber": "12345",
    "invoiceType": "purchase"
  }
}
```

#### Example 2: E-Invoice Notification
```json
{
  "notification": {
    "title": "E-Invoice Ready",
    "body": "E-Invoice #67890 is ready for review"
  },
  "data": {
    "notificationType": "2",
    "referenceNumber": "67890"
  }
}
```

#### Example 3: Customer Alert
```json
{
  "notification": {
    "title": "Customer Updated",
    "body": "Customer profile has been updated"
  },
  "data": {
    "notificationType": "3",
    "referenceNumber": "100"
  }
}
```

## Testing with curl (Alternative Method)

If you prefer command line testing, you can use curl with your Firebase Server Key:

### Get Server Key

1. Go to Firebase Console
2. Project Settings → Cloud Messaging
3. Copy "Server key"

### Send Test Notification

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "YOUR_DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Test Invoice",
      "body": "Invoice #12345 created"
    },
    "data": {
      "notificationType": "1",
      "referenceNumber": "12345"
    }
  }'
```

Replace:
- `YOUR_SERVER_KEY` with your Firebase server key
- `YOUR_DEVICE_FCM_TOKEN` with your device's FCM token

## Troubleshooting

### Token Not Appearing in Console

**Solution:**
1. Check Firebase initialization in `main.dart`
2. Verify internet connection
3. Check permissions in AndroidManifest.xml
4. Restart the app

**Debug:**
```dart
// Add this to test manually
final token = await FcmNotificationHandler.getCurrentToken();
print('Manual token fetch: $token');
```

### Notifications Not Showing (Foreground)

**Possible Causes:**
1. Local notification service not initialized
2. Channel not created
3. Permission not granted

**Check:**
```bash
flutter run
# Look for:
# "Local notifications initialized"
# "Android notification channel created"
# "FCM Permission granted: authorized"
```

### Notifications Not Showing (Background)

**Possible Causes:**
1. App killed by system
2. FCM token not valid
3. Firebase project misconfigured

**Check:**
1. Verify google-services.json is in `android/app/`
2. Verify package name matches Firebase
3. Test with a different device

### Navigation Not Working

**Debug:**
```dart
// Check logs for:
// "Notification tapped: {data}"
// "Navigation data - Type: X, Ref: Y"
```

**Verify:**
1. Data keys are correct (`notificationType`, `referenceNumber`)
2. Routes exist in app_router.dart
3. Context is mounted when navigating

## Testing Checklist

Before considering FCM implementation complete:

- [ ] FCM token generated and logged
- [ ] Notification received in foreground
- [ ] Notification received in background
- [ ] Notification received when app terminated
- [ ] Local notification shown in foreground
- [ ] Notification tap navigation works
- [ ] Invoice notification (type 1) navigates correctly
- [ ] E-Invoice notification (type 2) navigates correctly
- [ ] Customer notification (type 3) navigates correctly
- [ ] Credit notification (type 4) navigates correctly
- [ ] Announcement notification (type 5) navigates correctly
- [ ] Product notification (type 6) navigates correctly
- [ ] Android permissions granted
- [ ] iOS permissions granted (if testing iOS)

## Next Steps (Backend Integration)

When backend is ready:

1. **Register Device Token:**
   - Endpoint: `POST /user/register-device`
   - Payload: `{ "fcm_token": "...", "platform": "android" }`
   - Location: `FcmNotificationHandler.sendTokenToBackend()`

2. **Unregister on Logout:**
   - Endpoint: `POST /user/unregister-device`
   - Payload: `{ "fcm_token": "..." }`
   - Location: `FcmNotificationHandler.removeTokenFromBackend()`

3. **Topic Subscriptions:**
   - Call `subscribeToUserTopic(userId)` after login
   - Call `unsubscribeFromUserTopic(userId)` on logout

## Debugging Commands

### View FCM Token
```dart
final token = await FcmNotificationHandler.getCurrentToken();
debugPrint('Current FCM Token: $token');
```

### Check Notification Permissions
```dart
final enabled = await FcmNotificationHandler.areNotificationsEnabled();
debugPrint('Notifications enabled: $enabled');
```

### Test Local Notification Directly
```dart
final localNotif = locator<LocalNotificationService>();
await localNotif.showNotification(
  id: 1,
  title: 'Test',
  body: 'Direct local notification test',
);
```

## Support

For issues or questions:
1. Check console logs for error messages
2. Verify Firebase Console configuration
3. Review this guide
4. Check Flutter and Firebase plugin versions

---

**Created:** 2025-10-20
**Version:** 1.0
**Status:** Ready for Testing
