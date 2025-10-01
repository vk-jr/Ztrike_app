# ZTRIKE Setup Guide

This guide will help you set up and run the ZTRIKE Flutter application.

## Quick Start (5 Minutes)

### Step 1: Install Flutter

If you haven't installed Flutter yet:

1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extract the zip file
3. Add Flutter to your PATH
4. Run `flutter doctor` to verify installation

```bash
flutter doctor
```

### Step 2: Get Dependencies

Navigate to the project directory and get dependencies:

```bash
cd Ztrike.app
flutter pub get
```

### Step 3: Run the App

Run on your preferred platform:

```bash
# Chrome (Web)
flutter run -d chrome

# Android Emulator (make sure emulator is running)
flutter run -d android

# iOS Simulator (macOS only)
flutter run -d ios
```

## Database Setup (Already Done!)

✅ The Supabase database is **already configured** with all tables, policies, and storage buckets:

- Users, Posts, Comments
- Messages, Notifications
- Teams, Leagues, Matches
- Achievements
- Row Level Security (RLS) enabled
- Storage buckets for profiles and posts

**No additional database setup required!**

## Configuration Details

### Supabase Connection

The app connects to: `https://xpxvezrjqfgxqghehwnr.supabase.co`

Configuration file: `lib/core/constants/supabase_constants.dart`

### Available Features

1. **Authentication**
   - Email/Password sign up and sign in
   - Google Sign-In (requires OAuth setup)
   - Session management

2. **User Profiles**
   - Athlete, Team, or League accounts
   - Profile photos and banners
   - Bio and statistics
   - Achievements

3. **Social Features**
   - Post creation with images
   - Like and comment on posts
   - Connection requests
   - Direct messaging
   - Notifications

4. **Teams & Leagues**
   - Browse teams by sport
   - View leagues
   - Live and upcoming matches

## Testing the App

### Test Accounts

You can create test accounts directly in the app:

1. **Athlete Account**
   - Sign up as "Athlete"
   - Complete onboarding with sports selection
   - Test performance stats and connections

2. **Team Account**
   - Sign up as "Team"
   - Browse available players
   - Manage team roster

3. **League Account**
   - Sign up as "League"
   - View matches and standings

### Test Scenarios

1. **Create Post**
   - Sign in
   - Go to Home
   - Write a post and add an image
   - Post should appear in feed

2. **Connect with Users**
   - Go to Network tab
   - View "People You May Know"
   - Send connection request
   - Switch to another account to accept

3. **Send Messages**
   - Connect with a user first
   - Go to Messages tab
   - Start a conversation

4. **View Profile**
   - Tap profile icon
   - View stats and achievements
   - Edit profile information

## Platform-Specific Setup

### Android

**Minimum Requirements:**
- Android Studio installed
- Android SDK 21 or higher
- Android emulator or physical device

**Run on Android:**
```bash
flutter run -d android
```

### iOS (macOS only)

**Requirements:**
- Xcode installed
- iOS Simulator or physical device
- CocoaPods installed

**Run on iOS:**
```bash
cd ios
pod install
cd ..
flutter run -d ios
```

### Web

**Run on Chrome:**
```bash
flutter run -d chrome
```

**Build for production:**
```bash
flutter build web
```

## Optional: Google Sign-In Setup

Google Sign-In requires additional OAuth configuration:

### Android
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google Sign-In API
4. Create OAuth 2.0 credentials
5. Add SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
6. Download `google-services.json`
7. Place in `android/app/`

### iOS
1. Get iOS OAuth client ID from Google Cloud Console
2. Add to `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```

### Web
1. Get Web OAuth client ID
2. Add to `index.html`

## Troubleshooting

### Issue: "No connected devices"
**Solution:**
- For Android: Start an emulator or connect a device
- For iOS: Open Simulator from Xcode
- For Web: Use `-d chrome` flag

### Issue: "Package dependencies error"
**Solution:**
```bash
flutter clean
flutter pub get
```

### Issue: "Supabase connection failed"
**Solution:**
- Check internet connection
- Verify Supabase URL in constants file
- Check Supabase project status

### Issue: "Image picker not working"
**Solution:**
- For Android: Add permissions to `AndroidManifest.xml`
- For iOS: Add permissions to `Info.plist`

### Issue: "Build fails on iOS"
**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run -d ios
```

## Development Tips

### Hot Reload
Press `r` in terminal while app is running to hot reload changes.

### Hot Restart
Press `R` for full restart.

### Debug Mode
The app runs in debug mode by default. For production:
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
flutter build web --release  # Web
```

### Debugging
- Use Chrome DevTools for web
- Use Android Studio debugger for Android
- Use Xcode debugger for iOS

## App Structure Overview

```
lib/
├── main.dart                    # Entry point
├── core/                        # Core utilities
│   ├── constants/              # App constants
│   ├── theme/                  # Styling
│   └── utils/                  # Helpers
├── data/                        # Data layer
│   ├── models/                 # Data models
│   ├── repositories/           # Data access
│   └── services/               # External services
└── presentation/                # UI layer
    ├── providers/              # State management
    ├── screens/                # App screens
    └── widgets/                # Reusable widgets
```

## Next Steps

1. ✅ Run the app
2. ✅ Create a test account
3. ✅ Explore all features
4. 🔧 Customize theme colors
5. 🔧 Add your own features
6. 🔧 Deploy to production

## Need Help?

- Check `README.md` for detailed documentation
- Review Supabase Dashboard for database insights
- Check Flutter documentation: [docs.flutter.dev](https://docs.flutter.dev)
- Review Supabase docs: [supabase.com/docs](https://supabase.com/docs)

## Production Checklist

Before deploying to production:

- [ ] Configure proper OAuth credentials
- [ ] Set up environment variables
- [ ] Enable analytics
- [ ] Set up crash reporting
- [ ] Configure push notifications
- [ ] Test on real devices
- [ ] Optimize images and assets
- [ ] Run performance profiling
- [ ] Review security policies
- [ ] Create privacy policy
- [ ] Test all user flows

---

**Happy Coding! 🚀**
