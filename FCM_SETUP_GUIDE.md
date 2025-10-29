# Firebase Cloud Messaging (FCM) Integration Guide

This guide will help you complete the Firebase Cloud Messaging setup for your Pranomi app.

## Current Status

✅ Flutter dependencies added
✅ FCM service class created
✅ Service registered in dependency injection
✅ Main.dart updated with FCM initialization
✅ Notification handler created

## Required Steps

### 1. Set Up Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing project
3. Add your Android and iOS apps to the Firebase project

### 2. Android Configuration

#### 2.1 Download google-services.json

1. In Firebase Console, go to Project Settings
2. Select your Android app
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

#### 2.2 Update android/build.gradle

Add the Google services classpath:

```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### 2.3 Update android/app/build.gradle

At the top of the file, add:

```gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'com.google.gms.google-services'  // Add this line
```

At the bottom, ensure you have:

```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

#### 2.4 Update AndroidManifest.xml

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- ... existing configuration ... -->

        <!-- FCM Service -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <!-- Default notification channel -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="pranomi_notifications" />
    </application>

    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
</manifest>
```

### 3. iOS Configuration

#### 3.1 Download GoogleService-Info.plist

1. In Firebase Console, go to Project Settings
2. Select your iOS app
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`
5. Also place a copy in: `macos/Runner/GoogleService-Info.plist` (if targeting macOS)

#### 3.2 Update ios/Podfile

Ensure your Podfile has:

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

#### 3.3 Enable Push Notifications Capability

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Push Notifications"
6. Add "Background Modes" and enable:
   - Background fetch
   - Remote notifications

#### 3.4 Update Info.plist

No changes needed - permissions are requested at runtime.

### 4. Generate Firebase Options File

Run the FlutterFire CLI to generate configuration:

```bash
# Install FlutterFire CLI if not already installed
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase for your Flutter project
flutterfire configure
```

This will create `lib/firebase_options.dart` with your Firebase configuration.

#### 4.5 Update main.dart to use firebase_options.dart

Update the Firebase initialization in `lib/main.dart`:

```dart
import 'package:pranomiapp/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ... rest of your code
}
```

### 5. Install Dependencies

Run:

```bash
flutter pub get
cd ios && pod install && cd ..
cd macos && pod install && cd ..
```

### 6. Backend Integration

You need to update your backend to send notifications. The FCM token is automatically saved when the app starts.

#### 6.1 Get the FCM Token

The FCM token is printed in the console when the app starts. Look for:
```
FCM Token: [your-token-here]
```

#### 6.2 Send Token to Backend

Update `lib/features/notifications/data/fcm_notification_handler.dart`:

Implement the `sendTokenToBackend()` method to call your API:

```dart
static Future<void> sendTokenToBackend() async {
  final fcmService = locator<FcmService>();
  final token = await fcmService.getFCMToken();

  if (token != null) {
    // Call your Pranomi API
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final apiSecret = prefs.getString('apiSecret');

    final response = await dio.post(
      'https://apitest.pranomi.com/user/register-device',
      data: {
        'fcm_token': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
      },
      options: Options(headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}',
      }),
    );
  }
}
```

#### 6.3 Call Token Registration After Login

In your login success handler (e.g., `lib/features/authentication/`), add:

```dart
import 'package:pranomiapp/features/notifications/data/fcm_notification_handler.dart';

// After successful login
await FcmNotificationHandler.sendTokenToBackend();

// Subscribe to user-specific topic
await FcmNotificationHandler.subscribeToUserTopic(userId);
```

#### 6.4 Handle Logout

In your logout handler, add:

```dart
// Before logout
await FcmNotificationHandler.removeTokenFromBackend();
await FcmNotificationHandler.unsubscribeFromUserTopic(userId);
```

### 7. Backend Notification Format

Your backend should send notifications in this format:

```json
{
  "to": "FCM_TOKEN_HERE",
  "notification": {
    "title": "Yeni Fatura",
    "body": "123456 numaralı faturanız oluşturuldu"
  },
  "data": {
    "notificationType": "1",
    "referenceNumber": "123456",
    "invoiceType": "1"
  },
  "priority": "high"
}
```

Notification types:
- `1`: Invoice notification
- `2`: E-Invoice notification
- `3`: Customer notification
- `4`: Credit notification
- `5`: Announcement notification

### 8. Testing

#### 8.1 Test from Firebase Console

1. Go to Firebase Console > Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Select your app
5. Click "Test on device"
6. Enter the FCM token from your app logs
7. Send test message

#### 8.2 Test with cURL

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "FCM_TOKEN_HERE",
    "notification": {
      "title": "Test Notification",
      "body": "This is a test notification"
    },
    "data": {
      "notificationType": "1",
      "referenceNumber": "123456"
    }
  }'
```

### 9. Usage in App

#### 9.1 Initialize Notification Handler

In your root widget or router initialization, add:

```dart
import 'package:pranomiapp/features/notifications/data/fcm_notification_handler.dart';

@override
void initState() {
  super.initState();
  FcmNotificationHandler.initialize(context);
}
```

#### 9.2 Access FCM Service

Anywhere in your app:

```dart
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/services/fcm_service.dart';

final fcmService = locator<FcmService>();

// Get token
final token = await fcmService.getFCMToken();

// Subscribe to topic
await fcmService.subscribeToTopic('all_users');

// Unsubscribe from topic
await fcmService.unsubscribeFromTopic('all_users');
```

## Notification Permissions

### Android 13+

On Android 13 and later, the app will automatically request notification permission on first launch.

### iOS

On iOS, permission is requested when the app first initializes FCM.

## Troubleshooting

### Android

1. **Build Error**: Make sure `google-services.json` is in the correct location
2. **No Token**: Check that Google Play Services is installed on the device
3. **Notifications Not Showing**: Check notification channel settings

### iOS

1. **Build Error**: Run `pod install` in the ios directory
2. **No Token**: Ensure Push Notifications capability is enabled in Xcode
3. **Background Not Working**: Check Background Modes capability

## Common Issues

### 1. "Default FirebaseApp is not initialized"

Make sure `Firebase.initializeApp()` is called before `runApp()` in main.dart.

### 2. "Missing google-services.json"

Download the file from Firebase Console and place it in `android/app/`.

### 3. "No Firebase App '[DEFAULT]' has been created"

Run `flutterfire configure` to set up Firebase properly.

### 4. iOS not receiving notifications

- Check that APNs certificate is uploaded to Firebase Console
- Ensure Push Notifications capability is enabled
- Test with physical device (not simulator)

## Next Steps

1. Set up Firebase project and download configuration files
2. Update Android and iOS configurations
3. Run `flutterfire configure`
4. Test notifications from Firebase Console
5. Implement backend API to send notifications
6. Integrate with login/logout flows

## Resources

- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [FCM Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
