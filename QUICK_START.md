# ZTRIKE - Quick Start Guide

## 🚀 Get Running in 5 Minutes

### Step 1: Prerequisites Check
Make sure you have Flutter installed:
```bash
flutter doctor
```

If you see any issues, visit [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

### Step 2: Get Dependencies
```bash
cd Ztrike.app
flutter pub get
```

### Step 3: Run the App
```bash
# For Web (Recommended for quick testing)
flutter run -d chrome

# For Android
flutter run -d android

# For iOS (macOS only)
flutter run -d ios
```

### Step 4: Create Your First Account

1. Click **"Sign up"**
2. Select **"Athlete"** as account type
3. Fill in:
   - First Name: John
   - Last Name: Doe
   - Email: john@example.com
   - Password: Test1234
4. Click **"Sign Up"**
5. Select sports (e.g., Soccer, Basketball)
6. Optional: Add position and team
7. Click **"Complete Setup"**

### Step 5: Explore Features

✅ **Create a Post**
- Go to Home screen
- Type "My first post on ZTRIKE!"
- Click "Add Image" to upload a photo (optional)
- Click "Post"

✅ **View Profile**
- Click profile icon in top-right
- See your stats, posts, and achievements

✅ **Connect with Users**
- Go to Network tab
- See "People You May Know"
- Click "Connect" to send request

✅ **Browse Teams**
- Go to Teams tab
- Filter by sport
- View team details

✅ **Check Notifications**
- Go to Alerts tab
- View connection requests
- Mark as read

## 🎯 Common Commands

```bash
# Hot reload (press 'r' in terminal)
r

# Hot restart (press 'R' in terminal)
R

# Clean build
flutter clean
flutter pub get

# Run in release mode
flutter run --release

# Build for production
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
```

## 🔧 Troubleshooting

**Problem**: "No connected devices"
```bash
# For Web
flutter devices
# Should show Chrome

# For Android
flutter emulators
flutter emulators --launch <emulator_id>
```

**Problem**: "Package not found"
```bash
flutter clean
flutter pub get
```

**Problem**: "Build failed"
```bash
flutter doctor
# Fix any issues shown
```

## 📱 Test on Different Platforms

### Web (Chrome)
```bash
flutter run -d chrome
```

### Android Emulator
```bash
# List emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_name>

# Run app
flutter run -d android
```

### Physical Android Device
1. Enable Developer Options on your device
2. Enable USB Debugging
3. Connect via USB
4. Run: `flutter run -d <device_id>`

### iOS Simulator (macOS only)
```bash
open -a Simulator
flutter run -d ios
```

## 🎨 Customization

### Change Primary Color
Edit `lib/core/theme/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFFD6FF3F); // Your color here
```

### Change App Name
Edit `pubspec.yaml`:
```yaml
name: your_app_name
```

### Change App Icon
Replace icons in:
- `android/app/src/main/res/mipmap-*/`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- `web/icons/`

## 📚 Learn More

- **Full Documentation**: See `README.md`
- **Setup Guide**: See `SETUP_GUIDE.md`
- **Project Summary**: See `PROJECT_SUMMARY.md`

## 🎯 What's Already Working

✅ User Registration & Login
✅ Post Creation with Images
✅ Like & Comment on Posts
✅ Connection Requests
✅ Direct Messaging
✅ Real-time Notifications
✅ Profile Management
✅ Team Browsing
✅ Leagues & Matches

## 🌟 Pro Tips

1. **Use Hot Reload**: Press 'r' after making UI changes
2. **Check Console**: Watch for errors in terminal
3. **DevTools**: Use Flutter DevTools for debugging
4. **Supabase Dashboard**: View database at https://supabase.com/dashboard
5. **Test Multiple Accounts**: Create 2-3 accounts to test connections

## 🐛 Known Issues

- Google Sign-In needs OAuth setup (email login works)
- Video upload is placeholder (image upload works)
- Some features need real data (create test posts/users)

## 📞 Need Help?

1. Check the error message in terminal
2. Read `README.md` for detailed info
3. Check `SETUP_GUIDE.md` for troubleshooting
4. Run `flutter doctor` for system issues

## ✅ Success Checklist

- [ ] Flutter installed and working
- [ ] Dependencies downloaded (`flutter pub get`)
- [ ] App running on Chrome/device
- [ ] Created test account
- [ ] Created first post
- [ ] Viewed profile
- [ ] Explored all tabs

---

**That's it! You're ready to use ZTRIKE! 🎉**

Happy coding! 🚀
