# ZTRIKE - Deployment Checklist

## ✅ Pre-Deployment Verification

### 1. Development Environment
- [x] Flutter SDK installed (3.0+)
- [x] All dependencies in pubspec.yaml
- [x] No compilation errors
- [x] App runs successfully in development

### 2. Database Configuration
- [x] Supabase project created
- [x] All tables created (9 tables)
- [x] Row Level Security (RLS) enabled
- [x] Storage buckets configured
- [x] Database indexes added
- [x] Connection tested

### 3. Authentication Setup
- [x] Email/Password authentication working
- [ ] Google OAuth configured (Optional - needs client IDs)
- [x] Session management implemented
- [x] Password validation
- [x] Auto-login functionality

### 4. Core Features Testing
- [x] User registration
- [x] User login
- [x] Profile creation
- [x] Post creation
- [x] Image upload
- [x] Like/comment functionality
- [x] Connection requests
- [x] Messaging
- [x] Notifications

### 5. UI/UX Verification
- [x] Responsive design (mobile/tablet/desktop)
- [x] Loading states
- [x] Error messages
- [x] Form validation
- [x] Navigation working
- [x] Bottom navigation bar
- [x] Tab navigation

### 6. Performance
- [x] Image caching
- [x] Pagination implemented
- [x] Database queries optimized
- [x] Real-time subscriptions working

---

## 🚀 Deployment Steps

### For Android (Google Play)

#### 1. Update App Configuration
```yaml
# pubspec.yaml
version: 1.0.0+1
```

#### 2. Create Keystore
```bash
keytool -genkey -v -keystore ~/ztrike-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ztrike
```

#### 3. Configure Signing
Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=ztrike
storeFile=<path-to-keystore>
```

Update `android/app/build.gradle`:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

#### 4. Build APK/App Bundle
```bash
# APK
flutter build apk --release

# App Bundle (Recommended for Play Store)
flutter build appbundle --release
```

#### 5. Upload to Google Play Console
1. Go to https://play.google.com/console
2. Create new application
3. Upload app bundle
4. Fill in store listing
5. Submit for review

---

### For iOS (App Store)

#### 1. Xcode Configuration
```bash
open ios/Runner.xcworkspace
```

1. Set Team in Signing & Capabilities
2. Update Bundle Identifier
3. Configure App Icons
4. Set deployment target (iOS 12.0+)

#### 2. Build Archive
```bash
flutter build ios --release
```

Or in Xcode:
- Product > Archive
- Distribute App
- Upload to App Store Connect

#### 3. Upload to App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Create new app
3. Upload build
4. Fill in app information
5. Submit for review

---

### For Web (Firebase Hosting / Netlify / Vercel)

#### 1. Build Web App
```bash
flutter build web --release
```

#### 2. Deploy to Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init hosting

# Deploy
firebase deploy --only hosting
```

#### 3. Deploy to Netlify
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --dir=build/web --prod
```

#### 4. Deploy to Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod build/web
```

---

## 🔒 Security Checklist

### Environment Variables
- [ ] Move Supabase credentials to environment variables
- [ ] Use flutter_dotenv or similar for secrets
- [ ] Never commit API keys to git

### API Security
- [x] RLS policies enabled on all tables
- [x] Authentication required for sensitive operations
- [x] Input validation on all forms
- [ ] Rate limiting configured (Supabase)

### Data Protection
- [x] User passwords hashed (Supabase Auth)
- [x] Secure storage for tokens
- [ ] HTTPS enforced in production
- [ ] Privacy policy created

---

## 📱 Platform-Specific Requirements

### Android
- [x] Permissions in AndroidManifest.xml
- [x] Min SDK 21
- [x] Target SDK 34
- [ ] Privacy policy link
- [ ] App icon (all densities)
- [ ] Splash screen
- [ ] Proguard rules (if using)

### iOS
- [x] Permissions in Info.plist
- [x] iOS 12.0+ deployment target
- [ ] App icon (all sizes)
- [ ] Launch screen
- [ ] Privacy policy link
- [ ] App Store screenshots

### Web
- [x] Manifest.json configured
- [x] Service worker (optional)
- [x] PWA ready
- [ ] SEO meta tags
- [ ] Favicon
- [ ] Open Graph tags

---

## 🧪 Pre-Launch Testing

### Functional Testing
- [ ] Create account flow
- [ ] Login flow
- [ ] Post creation
- [ ] Image upload
- [ ] Connection requests
- [ ] Messaging
- [ ] Notifications
- [ ] Profile editing
- [ ] Logout

### Cross-Platform Testing
- [ ] Test on Android device
- [ ] Test on iOS device
- [ ] Test on Chrome (web)
- [ ] Test on Safari (web)
- [ ] Test on different screen sizes

### Performance Testing
- [ ] Load time < 3 seconds
- [ ] Smooth scrolling
- [ ] No memory leaks
- [ ] Image loading optimized
- [ ] Database queries fast

### Edge Cases
- [ ] Poor internet connection
- [ ] No internet connection
- [ ] Invalid inputs
- [ ] Large data sets
- [ ] Empty states

---

## 📊 Analytics & Monitoring

### Setup Analytics
```dart
// Add to pubspec.yaml
firebase_analytics: ^10.8.0

// Initialize in main.dart
FirebaseAnalytics analytics = FirebaseAnalytics.instance;
```

### Crash Reporting
```dart
// Add to pubspec.yaml
firebase_crashlytics: ^3.4.0

// Initialize
FirebaseCrashlytics.instance.crash(); // Test crash
```

### Performance Monitoring
```dart
// Add to pubspec.yaml
firebase_performance: ^0.9.3

// Track custom traces
final trace = FirebasePerformance.instance.newTrace('post_creation');
await trace.start();
// ... operation ...
await trace.stop();
```

---

## 📝 App Store Assets

### Screenshots Required
- **Android**: 2-8 screenshots (16:9 ratio)
  - Phone: 1080x1920
  - Tablet: 2048x2732

- **iOS**: 3-10 screenshots
  - iPhone 6.5": 1284x2778
  - iPhone 5.5": 1242x2208
  - iPad Pro: 2048x2732

### Promotional Graphics
- Android: Feature Graphic (1024x500)
- iOS: App Preview video (optional)

### App Description
- Short description (80 characters)
- Full description (4000 characters)
- Keywords
- Category: Social Networking / Sports

### Privacy Policy
Must include:
- Data collection practices
- How data is used
- Third-party services (Supabase)
- User rights
- Contact information

---

## 🔄 Post-Launch

### Monitoring
- [ ] Set up error tracking
- [ ] Monitor analytics
- [ ] Track user feedback
- [ ] Monitor server costs

### Updates
- [ ] Plan feature updates
- [ ] Bug fix schedule
- [ ] Version control
- [ ] Changelog

### Marketing
- [ ] Social media presence
- [ ] App Store Optimization (ASO)
- [ ] User reviews management
- [ ] Community building

---

## 📋 Environment Configuration

### Development
```dart
const String supabaseUrl = 'https://xpxvezrjqfgxqghehwnr.supabase.co';
const String supabaseAnonKey = 'your-dev-key';
```

### Production (Recommended)
Create `lib/core/constants/environment.dart`:
```dart
class Environment {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
```

Run with:
```bash
flutter run --dart-define=SUPABASE_URL=your-url --dart-define=SUPABASE_ANON_KEY=your-key
```

---

## ✅ Final Checks

Before submission:
- [ ] App name is correct
- [ ] Version number updated
- [ ] All features working
- [ ] No debug code left
- [ ] No console.log statements
- [ ] Icons and splash screens set
- [ ] Privacy policy linked
- [ ] Terms of service created
- [ ] Support email configured
- [ ] App store listing complete
- [ ] Screenshots uploaded
- [ ] App description compelling
- [ ] Keywords optimized
- [ ] Test accounts created
- [ ] Demo video prepared (optional)

---

## 🎯 Launch Day

1. **Submit to App Stores**
   - Android: 1-3 days review
   - iOS: 1-7 days review
   - Web: Immediate

2. **Monitor**
   - Watch for crashes
   - Check error logs
   - Monitor user feedback

3. **Respond**
   - Answer user reviews
   - Fix critical bugs quickly
   - Release updates

4. **Promote**
   - Announce launch
   - Share on social media
   - Reach out to users

---

## 📞 Support

### User Support Channels
- Email: support@ztrike.app
- In-app feedback
- Social media
- Help center / FAQ

### Developer Resources
- Supabase Dashboard
- Firebase Console
- App Store Connect
- Google Play Console

---

**Good luck with your launch! 🚀**
