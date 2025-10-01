# ZTRIKE - Sports Social Network App

A comprehensive sports social networking platform built with Flutter and Supabase, connecting athletes, teams, and leagues.

## Features

✅ **Authentication**
- Email/Password Sign Up & Sign In
- Google Sign-In Integration
- Account Types: Athlete, Team, League
- Onboarding Flow for Athletes

✅ **Profile Management**
- View & Edit Profile
- Performance Statistics
- Achievements
- Profile Banner & Photo
- Account Type Badges

✅ **Social Networking**
- Send & Accept Connection Requests
- View Connections
- People You May Know Suggestions
- Global User Search

✅ **Posts & Feed**
- Create Text, Image, and Video Posts
- Like & Comment on Posts
- View Public Feed
- User-Specific Post History

✅ **Messaging**
- Direct Messaging
- Real-time Chat Updates
- Conversation List
- Unread Message Indicators

✅ **Notifications**
- Connection Request Notifications
- Message Notifications
- Mark as Read/Mark All as Read
- Unread Count Badges

✅ **Teams & Leagues**
- Browse Teams & Leagues
- Filter by Sport
- View Team Details
- Live & Upcoming Matches

## Tech Stack

- **Framework**: Flutter 3.0+
- **Backend**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth + Google OAuth
- **Storage**: Supabase Storage
- **Real-time**: Supabase Realtime
- **State Management**: Provider
- **Navigation**: Go Router
- **Image Caching**: Cached Network Image

## Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode (for mobile development)
- Supabase Account

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Ztrike.app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Supabase Configuration

The app is already configured with a Supabase project. The database schema has been created with all necessary tables:

- ✅ Users Table
- ✅ Posts Table
- ✅ Comments Table
- ✅ Messages Table
- ✅ Notifications Table
- ✅ Teams Table
- ✅ Leagues Table
- ✅ Matches Table
- ✅ Achievements Table

All Row Level Security (RLS) policies and storage buckets are already set up.

**Supabase Project Details:**
- URL: `https://xpxvezrjqfgxqghehwnr.supabase.co`
- The configuration is in `lib/core/constants/supabase_constants.dart`

### 4. Google Sign-In Configuration (Optional)

To enable Google Sign-In, you need to:

#### For Android:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create OAuth 2.0 credentials
3. Add the SHA-1 fingerprint of your app
4. Download `google-services.json` and place it in `android/app/`

#### For iOS:
1. Add your OAuth client ID to `ios/Runner/Info.plist`
2. Configure URL schemes

#### For Web:
1. Add your web client ID to the app

### 5. Run the App

```bash
# For development
flutter run

# For specific platform
flutter run -d chrome      # Web
flutter run -d android     # Android
flutter run -d ios         # iOS
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   └── supabase_constants.dart    # Supabase configuration
│   ├── theme/
│   │   └── app_theme.dart             # Theme & styling
│   └── utils/
│       └── validators.dart            # Form validators
├── data/
│   ├── models/                        # Data models
│   │   ├── user_model.dart
│   │   ├── post_model.dart
│   │   ├── message_model.dart
│   │   ├── notification_model.dart
│   │   └── team_model.dart
│   ├── repositories/                  # Data repositories
│   │   ├── user_repository.dart
│   │   ├── post_repository.dart
│   │   ├── message_repository.dart
│   │   ├── notification_repository.dart
│   │   └── team_repository.dart
│   └── services/
│       └── auth_service.dart          # Authentication service
└── presentation/
    ├── providers/
    │   └── auth_provider.dart         # State management
    ├── screens/
    │   ├── auth/                      # Authentication screens
    │   ├── home/                      # Home & feed
    │   ├── profile/                   # User profile
    │   ├── network/                   # Connections
    │   ├── teams/                     # Teams
    │   ├── messages/                  # Messaging
    │   ├── alerts/                    # Notifications
    │   └── leagues/                   # Leagues & matches
    └── widgets/
        ├── profile_card_widget.dart
        └── post_card_widget.dart
```

## Key Features Implementation

### Authentication Flow
1. Users can sign up with email/password or Google
2. Select account type (Athlete, Team, League)
3. Athletes complete onboarding (sports, position, team)
4. Auto-login with stored session

### Post Creation
- Text, images, and videos supported
- Image upload to Supabase Storage
- Real-time feed updates
- Like and comment functionality

### Messaging System
- Real-time chat using Supabase Realtime
- Conversation list with last message preview
- Unread message indicators
- Mark messages as read

### Connection System
- Send connection requests
- Accept/reject requests
- View all connections
- Suggested users based on interests

### Performance Stats
- Track matches played, goals, assists, MVPs
- Calculate rank score: MVPs × 100 + Goals × 50 + Assists × 30
- Win rate calculation
- Achievement system

## Database Schema

All tables are created in Supabase with proper indexes and RLS policies:

### Users Table
- Profile information
- Performance statistics
- Connection arrays
- Team info (JSONB)

### Posts Table
- Content with media URLs
- Like counts and liked_by array
- Author information

### Messages Table
- Sender/receiver relationship
- Read status
- Real-time updates

### Notifications Table
- Multiple notification types
- Metadata (JSONB)
- Read status

## Color Scheme

- **Primary**: `#D6FF3F` (Lime Green) - Buttons, highlights
- **Secondary**: `#000000` (Black) - Text, icons
- **Background**: `#FFFFFF` (White)
- **Surface**: `#F9FAFB` (Light Gray)
- **Error**: `#EF4444` (Red)
- **Success**: `#10B981` (Green)
- **Warning**: `#F59E0B` (Amber)

## Testing

To test the app:

1. Sign up with a new account
2. Complete the onboarding
3. Create a post with image
4. Search for other users
5. Send connection requests
6. Test messaging functionality
7. Check notifications

## Known Limitations

- Video upload not fully implemented (placeholder)
- Google Sign-In requires additional OAuth configuration
- Map view for leagues needs Google Maps API key
- Push notifications require additional setup

## Future Enhancements

- [ ] Push notifications with FCM
- [ ] Video playback in posts
- [ ] Live match streaming
- [ ] Calendar integration
- [ ] Image cropping for profile/banner
- [ ] Advanced search filters
- [ ] Team analytics dashboard
- [ ] Payment integration for leagues

## Troubleshooting

### Common Issues

**Issue**: Supabase connection error
- **Solution**: Check your internet connection and Supabase project status

**Issue**: Image upload fails
- **Solution**: Verify storage bucket policies in Supabase dashboard

**Issue**: Google Sign-In not working
- **Solution**: Configure OAuth credentials properly for each platform

**Issue**: Build errors
- **Solution**: Run `flutter clean` then `flutter pub get`

## Support

For issues or questions:
1. Check the [Supabase Documentation](https://supabase.com/docs)
2. Review the [Flutter Documentation](https://docs.flutter.dev/)
3. Check existing GitHub issues

## License

This project is created for educational and development purposes.

---

**Built with ❤️ using Flutter and Supabase**
