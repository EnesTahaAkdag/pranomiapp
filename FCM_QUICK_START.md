# FCM Quick Start Guide

## 🚀 Get Started in 3 Minutes

### Step 1: Run the App

```bash
flutter run
```

### Step 2: Get Your FCM Token

Look in the console output for:

```
FCM Token: eXampleT0kenHere...
```

**Copy this entire token!**

### Step 3: Send a Test Notification

1. **Open Firebase Console:**
   - Go to: https://console.firebase.google.com/
   - Select project: **pranomi-6a648**

2. **Navigate to Messaging:**
   - Click "Messaging" in left sidebar
   - Click "Send your first message" or "New campaign"

3. **Fill in Notification:**
   ```
   Title: Test Notification
   Text: Hello from Firebase!
   ```

4. **Send Test:**
   - Click "Send test message"
   - Paste your FCM token
   - Click "Test"

5. **Check Your App:**
   - You should see the notification!
   - Tap it to test (will go to notifications page)

## 📱 Test Navigation

To test navigation to specific screens:

1. **In Firebase Console notification:**
   - Scroll to "Additional options"
   - Expand "Custom data"

2. **Add these keys:**

   **For Invoice (example):**
   ```
   Key: notificationType    Value: 1
   Key: referenceNumber     Value: 12345
   ```

3. **Send the notification**

4. **Tap notification** → Should navigate to invoice detail page

## 🎯 Notification Types

| Want to test | notificationType | referenceNumber | Goes to |
|--------------|------------------|-----------------|---------|
| Invoice | `1` | `12345` | Invoice details |
| E-Invoice | `2` | `67890` | E-Invoice details |
| Customer | `3` | `100` | Customer details |
| Credit | `4` | _(not needed)_ | Credit page |
| Announcements | `5` | _(not needed)_ | Announcements |
| Products | `6` | `200` | Product details |

## ✅ Testing Checklist

- [ ] App runs without errors
- [ ] FCM token appears in console
- [ ] Notification received (app open)
- [ ] Notification received (app background)
- [ ] Notification tap works
- [ ] Navigation to screen works

## 🐛 Troubleshooting

**No token in console?**
- Check internet connection
- Restart the app
- Check permissions

**Notification not appearing?**
- Check FCM token is correct
- Verify app is running
- Try with app in background

**Navigation not working?**
- Check `notificationType` value (must be string "1", not number 1)
- Verify `referenceNumber` is included
- Check console for error messages

## 📚 More Information

- **Full Testing Guide:** `FCM_TESTING_GUIDE.md`
- **Implementation Details:** `FCM_IMPLEMENTATION_SUMMARY.md`

## 💡 Quick Tips

1. **Keep the app running** to see foreground notifications
2. **Background test:** Press home button, then send notification
3. **Terminated test:** Close app completely, send notification, tap to open
4. **Use different IDs** for `referenceNumber` to test various screens

## 🎉 That's It!

You're now ready to test FCM notifications! For advanced testing and backend integration details, see the full guides.

---

**Need Help?** Check the console logs for detailed error messages.
