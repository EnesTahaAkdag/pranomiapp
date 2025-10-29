# FCM Testing - All App States

## Quick Test Guide for All 3 States

### Before You Start

1. **Get your FCM token:**
   ```bash
   flutter run
   # Look for: FCM Token: [YOUR_TOKEN]
   # Copy it!
   ```

2. **Open Firebase Console:**
   - https://console.firebase.google.com/
   - Project: pranomi-6a648
   - Navigate to: Messaging

---

## Test 1: Foreground (App Open) ✅

### What to expect:
Notification appears as **overlay** while you're using the app

### Steps:

1. **Open your app** on device
2. **Keep app visible** on screen
3. **Send test from Firebase Console:**
   ```
   Messaging → Send test message
   Notification title: Foreground Test
   Notification text: This should appear as overlay
   Paste your FCM token → Test
   ```
4. **Watch your device screen**

### ✅ Success Indicators:

**On Device:**
- Small notification appears at top of screen
- Can see notification while app is open
- Notification has sound/vibration

**In Console Logs:**
```
📱 FOREGROUND notification received
Title: Foreground Test
Body: This should appear as overlay
Local notification shown: Foreground Test
```

### ❌ If It Fails:

- Check logs for "✅ FCM handlers initialized"
- Verify "Local notifications initialized"
- Try `flutter clean && flutter run`
- Check notification permissions

---

## Test 2: Background (App Minimized) ✅

### What to expect:
Notification appears in **system tray**, app still running

### Steps:

1. **Open your app**
2. **Press home button** (app goes to background but still running)
3. **Send test from Firebase Console:**
   ```
   Notification title: Background Test
   Notification text: Tap to open app

   Custom Data (for navigation test):
     notificationType: 1
     referenceNumber: 12345

   Paste token → Test
   ```
4. **Check notification tray**

### ✅ Success Indicators:

**On Device:**
- Notification appears in system tray
- Shows app icon
- Shows title and body

**When you tap notification:**
- App comes to foreground
- Navigates to invoice detail page (if data included)

**In Console Logs (after tap):**
```
👆 Notification TAPPED
Data: {notificationType: 1, referenceNumber: 12345}
Navigation - Type: 1, Ref: 12345
```

### ❌ If It Fails:

- Notification not appearing → Check device notification settings
- Tap doesn't navigate → Check custom data format
- App doesn't open → Check background handler

---

## Test 3: Terminated (App Completely Closed) ✅

### What to expect:
Notification appears in **system tray**, app launches when tapped

### Steps:

1. **Force stop your app:**
   - Android: Settings → Apps → Pranomi → Force Stop
   - Or: Swipe away from recent apps

2. **Verify app is closed:**
   - Check recent apps list (should be empty)

3. **Send test from Firebase Console:**
   ```
   Notification title: Terminated Test
   Notification text: Tap to launch app

   Custom Data:
     notificationType: 5
     (This will go to announcements page)

   Paste token → Test
   ```

4. **Check notification tray**
5. **Tap notification**

### ✅ Success Indicators:

**On Device:**
- Notification appears even though app was closed
- Tapping launches the app
- App navigates to announcements page

**In Console Logs (after tap and app launch):**
```
App launched from notification
👆 Notification TAPPED
Data: {notificationType: 5}
Navigation - Type: 5
```

### ❌ If It Fails:

- Notification not appearing → Check google-services.json
- App doesn't launch → Normal, try tapping again
- No navigation → Check initial message handler

---

## Test 4: Navigation Testing

Test different notification types to ensure navigation works:

### Invoice Notification

**Custom Data:**
```
notificationType: 1
referenceNumber: 12345
```

**Expected:** Navigate to `/invoice/detail/12345`

### E-Invoice Notification

**Custom Data:**
```
notificationType: 2
referenceNumber: 67890
```

**Expected:** Navigate to `/e-invoice/detail/67890`

### Customer Notification

**Custom Data:**
```
notificationType: 3
referenceNumber: 100
```

**Expected:** Navigate to `/customer/detail/100`

### Credit Notification

**Custom Data:**
```
notificationType: 4
```

**Expected:** Navigate to `/credit`

### Announcement Notification

**Custom Data:**
```
notificationType: 5
```

**Expected:** Navigate to `/announcements`

### Product Notification

**Custom Data:**
```
notificationType: 6
referenceNumber: 200
```

**Expected:** Navigate to `/product/detail/200`

---

## Complete Test Sequence

Run all tests in this order:

### Step 1: Verify Setup
- [ ] App runs without errors
- [ ] FCM token logged in console
- [ ] See "✅ FCM handlers initialized" in logs
- [ ] See "Local notifications initialized" in logs

### Step 2: Test Foreground
- [ ] App open
- [ ] Send test notification
- [ ] Notification appears as overlay
- [ ] Tap notification
- [ ] Navigation works

### Step 3: Test Background
- [ ] Minimize app (home button)
- [ ] Send test notification with data
- [ ] Notification appears in tray
- [ ] Tap notification
- [ ] App comes to foreground and navigates

### Step 4: Test Terminated
- [ ] Force stop app
- [ ] Send test notification with data
- [ ] Notification appears in tray
- [ ] Tap notification
- [ ] App launches and navigates

### Step 5: Test All Navigation Types
- [ ] Invoice (type 1) navigation works
- [ ] E-Invoice (type 2) navigation works
- [ ] Customer (type 3) navigation works
- [ ] Credit (type 4) navigation works
- [ ] Announcement (type 5) navigation works
- [ ] Product (type 6) navigation works

---

## Debug Logs Reference

### Good Logs (Everything Working):

```
✅ FCM handlers initialized
📱 FOREGROUND notification received
Title: Test
Body: Hello
Local notification shown: Test
👆 Local notification TAPPED
Payload: notificationType=1&referenceNumber=12345&
Navigation - Type: 1, Ref: 12345
```

### Bad Logs (Something Wrong):

```
❌ No "FCM handlers initialized"
  → Handler not set up, foreground won't work

❌ "FOREGROUND notification received" but no "Local notification shown"
  → Local notification service issue

❌ "Notification TAPPED" but no "Navigation"
  → Navigation logic problem
```

---

## Common Issues & Quick Fixes

### Issue: Foreground notifications not showing

**Quick Fix:**
```bash
flutter clean
flutter pub get
flutter run
```

Look for "✅ FCM handlers initialized" in logs.

### Issue: Navigation not working

**Check custom data format in Firebase Console:**
- Keys must be exact: `notificationType`, `referenceNumber`
- Values must be strings: `"1"` not `1`

### Issue: Background/Terminated not showing

**Check:**
1. Notification permissions granted
2. google-services.json in android/app/
3. Package name matches everywhere

---

## Quick Firebase Console Setup

### 1. Navigate to Messaging
```
Firebase Console → pranomi-6a648 → Messaging
```

### 2. Click "Send test message"

### 3. Fill Notification
```
Notification title: [Your title]
Notification text: [Your message]
```

### 4. Add Custom Data (for navigation)
Scroll to "Additional options" → "Custom data"

**For Invoice:**
```
Key: notificationType    Value: 1
Key: referenceNumber     Value: 12345
```

### 5. Send Test
```
Add FCM registration token: [Paste your token]
Click: Test
```

---

## Expected Results Summary

| App State | Notification Shows | On Tap | Console Logs |
|-----------|-------------------|---------|--------------|
| **Foreground** | ✅ Overlay | Navigate | 📱 FOREGROUND |
| **Background** | ✅ System Tray | Open + Navigate | 👆 TAPPED |
| **Terminated** | ✅ System Tray | Launch + Navigate | 👆 TAPPED |

---

## Final Checklist

Before considering FCM complete:

- [ ] All 3 app states tested and working
- [ ] All 6 notification types tested
- [ ] Navigation works in all scenarios
- [ ] Logs show proper emojis (📱, 👆, ✅)
- [ ] No errors in console
- [ ] Permissions granted
- [ ] Token is valid and current

---

**TL;DR:**
1. Run app → Get token
2. Test foreground (app open)
3. Test background (minimized)
4. Test terminated (force closed)
5. Verify navigation with custom data

All three states should now work! 🎉
