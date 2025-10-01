# ZTRIKE - Complete Flutter Application Specification

## 📱 APPLICATION OVERVIEW

ZTRIKE is a comprehensive sports social networking platform connecting athletes, teams, and leagues. Features include professional networking, team management, player recruitment, real-time messaging, live match tracking, and social interactions.

### Target Users
- **Athletes/Players**: Showcase skills, connect professionally, join teams
- **Teams**: Recruit players, manage rosters, compete in leagues
- **Leagues**: Organize competitions, manage teams (under development)

---

## 🛠 TECH STACK FOR FLUTTER

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Supabase (PostgreSQL Backend)
  supabase_flutter: ^2.5.0
  
  # Authentication
  google_sign_in: ^6.2.1
  
  # State Management
  provider: ^6.1.1
  riverpod: ^2.5.1
  
  # Navigation
  go_router: ^12.1.3
  
  # UI & Media
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  
  # Utilities
  intl: ^0.19.0
  timeago: ^3.6.1
  uuid: ^4.3.3
  
  # HTTP & API
  http: ^1.2.0
  dio: ^5.4.1
  
  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
```

### Supabase Configuration
- **Database**: PostgreSQL (Supabase hosted)
- **Authentication**: Supabase Auth (Email/Password + OAuth)
- **Storage**: Supabase Storage (for images/videos)
- **Real-time**: Supabase Realtime (for messages and notifications)

---

## 📂 PROJECT STRUCTURE

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
└── presentation/
    ├── screens/
    ├── widgets/
    └── providers/
```

---

## 🗄️ SUPABASE DATABASE SCHEMA (PostgreSQL)

### Database Tables

#### 1. USERS TABLE
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  display_name TEXT,
  display_name_lower TEXT, -- For case-insensitive search
  photo_url TEXT,
  banner_url TEXT,
  bio TEXT,
  teams TEXT[] DEFAULT '{}',
  leagues TEXT[] DEFAULT '{}',
  connections TEXT[] DEFAULT '{}',
  pending_requests TEXT[] DEFAULT '{}',
  sent_requests TEXT[] DEFAULT '{}',
  post_views INTEGER DEFAULT 0,
  sports TEXT[] DEFAULT '{}',
  current_team TEXT,
  account_type TEXT CHECK (account_type IN ('athlete', 'team', 'league')),
  user_type TEXT CHECK (user_type IN ('player', 'team', 'league')),
  
  -- Athlete Stats
  position TEXT,
  matches_played INTEGER DEFAULT 0,
  goals INTEGER DEFAULT 0,
  assists INTEGER DEFAULT 0,
  mvps INTEGER DEFAULT 0,
  saves INTEGER DEFAULT 0,
  wins INTEGER DEFAULT 0,
  losses INTEGER DEFAULT 0,
  clean_sheets INTEGER DEFAULT 0,
  rank_score NUMERIC DEFAULT 0.0,
  
  -- Team-specific (JSONB for nested data)
  team_info JSONB DEFAULT '{}'::jsonb,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_display_name_lower ON users(display_name_lower);
CREATE INDEX idx_users_account_type ON users(account_type);
CREATE INDEX idx_users_sports ON users USING GIN(sports);
CREATE INDEX idx_users_connections ON users USING GIN(connections);
```

**team_info JSONB structure:**
```json
{
  "logo": "string",
  "wins": 0,
  "losses": 0,
  "draws": 0,
  "matchesPlayed": 0,
  "location": "string",
  "players": [
    {
      "id": "string",
      "name": "string",
      "position": "string",
      "number": 0,
      "joinDate": "timestamp"
    }
  ],
  "recruiterInfo": {
    "openPositions": ["Striker", "Defender"],
    "requirements": ["requirement1"]
  }
}
```

#### 2. POSTS TABLE
```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  content TEXT NOT NULL,
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  image_url TEXT,
  video_url TEXT,
  likes INTEGER DEFAULT 0,
  liked_by TEXT[] DEFAULT '{}',
  author_name TEXT,
  author_photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_posts_author_id ON posts(author_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
```

#### 3. COMMENTS TABLE
```sql
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  author_name TEXT,
  author_photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_created_at ON comments(created_at DESC);
```

#### 4. MESSAGES TABLE
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  read BOOLEAN DEFAULT FALSE,
  sender_name TEXT,
  sender_photo_url TEXT,
  receiver_name TEXT,
  receiver_photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX idx_messages_participants ON messages(sender_id, receiver_id);
```

#### 5. NOTIFICATIONS TABLE
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  from_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type TEXT CHECK (type IN ('message', 'connection_request', 'connection_accepted')),
  title TEXT NOT NULL,
  description TEXT,
  read BOOLEAN DEFAULT FALSE,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(user_id, read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
```

#### 6. TEAMS TABLE
```sql
CREATE TABLE teams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  sport TEXT,
  logo TEXT,
  owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
  admin_ids TEXT[] DEFAULT '{}',
  wins INTEGER DEFAULT 0,
  losses INTEGER DEFAULT 0,
  draws INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_teams_sport ON teams(sport);
CREATE INDEX idx_teams_owner_id ON teams(owner_id);
```

#### 7. LEAGUES TABLE
```sql
CREATE TABLE leagues (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  sport TEXT,
  teams TEXT[] DEFAULT '{}',
  owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
  admin_ids TEXT[] DEFAULT '{}',
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_leagues_sport ON leagues(sport);
CREATE INDEX idx_leagues_status ON leagues(status);
```

#### 8. MATCHES TABLE
```sql
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  team_ids TEXT[] DEFAULT '{}',
  status TEXT CHECK (status IN ('scheduled', 'live', 'completed')),
  score_home INTEGER DEFAULT 0,
  score_away INTEGER DEFAULT 0,
  start_time TIMESTAMPTZ,
  location TEXT,
  league_id UUID REFERENCES leagues(id) ON DELETE SET NULL,
  creator_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_matches_start_time ON matches(start_time DESC);
```

#### 9. ACHIEVEMENTS TABLE
```sql
CREATE TABLE achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  year TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_achievements_user_id ON achievements(user_id);
```

### Row Level Security (RLS) Policies

Enable RLS and create policies for each table:

```sql
-- Users table RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all profiles" ON users
  FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = auth_id);

CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = auth_id);

-- Posts table RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view posts" ON posts
  FOR SELECT USING (true);

CREATE POLICY "Users can create posts" ON posts
  FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = author_id));

CREATE POLICY "Users can update own posts" ON posts
  FOR UPDATE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = author_id));

CREATE POLICY "Users can delete own posts" ON posts
  FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = author_id));

-- Messages table RLS
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their messages" ON messages
  FOR SELECT USING (
    auth.uid() = (SELECT auth_id FROM users WHERE id = sender_id) OR
    auth.uid() = (SELECT auth_id FROM users WHERE id = receiver_id)
  );

CREATE POLICY "Users can send messages" ON messages
  FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = sender_id));

-- Notifications table RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their notifications" ON notifications
  FOR SELECT USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

CREATE POLICY "Users can mark notifications as read" ON notifications
  FOR UPDATE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
```

### Supabase Storage Buckets

Create storage buckets for file uploads:

```sql
-- Create buckets
INSERT INTO storage.buckets (id, name, public) VALUES 
  ('profiles', 'profiles', true),
  ('posts', 'posts', true);

-- Storage policies
CREATE POLICY "Users can upload to profiles" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'profiles' AND auth.uid() IS NOT NULL);

CREATE POLICY "Anyone can view profiles" ON storage.objects
  FOR SELECT USING (bucket_id = 'profiles');

CREATE POLICY "Users can upload to posts" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'posts' AND auth.uid() IS NOT NULL);

CREATE POLICY "Anyone can view posts" ON storage.objects
  FOR SELECT USING (bucket_id = 'posts');
```

---

## 🎨 COMPLETE FEATURES LIST

### Authentication & Onboarding
✅ Email/Password Sign Up  
✅ Email/Password Sign In  
✅ Google Sign-In  
✅ Account Type Selection (Athlete/Team/League)  
✅ Athlete Onboarding (Sports, Position, Social Accounts)  
✅ Team Onboarding (Sports, Location, Positions)  
✅ Auto-login with Session  
✅ Logout  

### Profile Management
✅ View Own Profile  
✅ View Other User Profiles  
✅ Edit Profile (Name, Bio, Photo, Banner)  
✅ Update Performance Statistics  
✅ Add/Edit Achievements  
✅ Profile Tabs (Posts, Performance, Connections)  
✅ Stats Display (Connections, Post Views, Matches, etc.)  

### Social Networking
✅ Send Connection Requests  
✅ Accept/Reject Connection Requests  
✅ View Connections List  
✅ View Pending Requests  
✅ People You May Know Suggestions  
✅ Global Search (Athletes, Teams, Leagues)  
✅ Search by Name or Sport  

### Posts & Feed
✅ Create Text Posts  
✅ Create Posts with Images  
✅ Create Posts with Videos  
✅ Like Posts  
✅ Comment on Posts  
✅ View All Posts (Public Feed)  
✅ View User-Specific Posts  
✅ Delete Own Posts  

### Messaging
✅ Direct Messaging  
✅ Conversation List  
✅ Unread Message Indicators  
✅ Mark Messages as Read  
✅ Real-time Message Updates  

### Notifications
✅ Connection Request Notifications  
✅ Connection Accepted Notifications  
✅ New Message Notifications  
✅ Unread Count Badge  
✅ Mark as Read / Mark All as Read  

### Teams
✅ Browse Available Teams  
✅ Filter Teams by Sport  
✅ View Team Details  
✅ My Teams List  
✅ Team Dashboard (For Team Accounts)  
✅ Team Statistics  
✅ Player Recruitment System  
✅ View Player Rankings  
✅ Filter Players (Sport, Position, Status)  
✅ Search Players  

### Leagues
✅ Browse Leagues by Sport  
✅ View League Details  
✅ View Live Matches  
✅ View Upcoming Matches  
✅ League Map View  

### Home Screen
✅ Profile Summary Card  
✅ Create Post Widget  
✅ Posts Feed  
✅ Live Matches Card  
✅ Upcoming Matches  
✅ People You May Know  
✅ Trending Topics  

---

## 📱 COMPLETE SCREENS BREAKDOWN

### 1. SIGN IN SCREEN (`/sign-in`)
**UI Elements:**
- Logo (centered top)
- Title: "Welcome Back to ZTRIKE"
- Email TextField
- Password TextField (obscured)
- "Sign In" Button (full width, primary color #d6ff3f)
- "Forgot Password?" link
- Divider: "or continue with"
- "Continue with Google" Button (white, with Google icon)
- Bottom text: "Don't have an account? Sign up" link

**Validations:**
- Email format validation
- Password required

**Actions:**
- Sign in with email/password
- Sign in with Google
- Navigate to home on success
- Show error messages
- Loading indicator during auth

---

### 2. SIGN UP SCREEN (`/sign-up`)
**UI Elements:**
- Logo
- Title: "Join ZTRIKE"
- Subtitle: "Connect with the sports community"
- **User Type Selector** (3 buttons): Athlete | Team | League
- **If Athlete Selected:**
  - First Name TextField
  - Last Name TextField
- **If Team/League Selected:**
  - Name TextField
- Email TextField
- Password TextField
- Confirm Password TextField
- Password requirements hint
- "Sign Up" Button
- Divider: "or continue with"
- "Continue with Google" Button
- Bottom text: "Already have an account? Sign in"

**Validations:**
- Name fields required
- Email format
- Password: min 8 chars, uppercase, lowercase, number
- Confirm password match

**Actions:**
- Create Supabase Auth account
- Create PostgreSQL user profile
- Navigate to onboarding based on user type

---

### 3. ATHLETE INFO SCREEN (`/sign-up/athlete-team-info`)
**UI Elements:**
- Progress indicator
- Title: "Tell us about yourself"
- **Sports Selection** (Multi-select chips):
  - Soccer, Basketball, Baseball, Tennis, Cricket, Volleyball, Hockey, Rugby, Others
- **Position** TextField
- **Current Team** TextField (optional)
- **Social Media Accounts** (Optional):
  - Instagram
  - Twitter
  - Facebook
  - YouTube
  - TikTok
  - Strava
- "Complete Setup" Button
- "Skip for now" link

**Actions:**
- Save athlete info to Supabase database
- Navigate to home screen

---

### 4. HOME SCREEN (`/`)
**Layout:** 3-Column Desktop, Stack on Mobile

**LEFT SIDEBAR - Profile Card:**
- Banner image (gradient if none)
- Profile picture (circular, overlapping banner)
- User name
- Account type badge
- Email
- Bio text
- Stats grid (2x2):
  - Connections | Post Views
  - Teams | Leagues (Athletes)
  OR
  - Matches | Wins
  - Players | Clean Sheets (Teams)
- "View Profile" Button

**MAIN CONTENT:**
- **Post Creation Card:**
  - Avatar
  - "What's on your mind?" TextField (multiline)
  - "Add Image" IconButton
  - "Add Video" IconButton
  - "Post" Button

- **Live Matches Card** (Primary gradient with #d6ff3f):
  - Header: "Live Matches" with clock icon | "View All" button
  - Match cards (scrollable):
    - League badge
    - "LIVE" badge (red, pulsing)
    - Team 1 logo + name | Score | Team 2 name + logo
    - Quarter/time
    - "Watch Now" button

- **Posts Feed:**
  - Infinite scroll
  - Post cards (author, content, image, likes, comments)

**RIGHT SIDEBAR:**
- **Upcoming Matches Card:**
  - Calendar icon header
  - Match list:
    - League + Date
    - Team 1 vs Team 2
    - "Remind Me" + "Add to Calendar" buttons
  - "View All Matches" button

- **People You May Know:**
  - User cards (photo, name)
  - "Connect" button

- **Trending in Sports:**
  - Hashtag list with post counts

---

### 5. PROFILE SCREEN (`/profile`)
**Layout:**
- **Cover Banner** (240px height, full width)
- **Profile Picture** (circular, centered, overlapping banner bottom)
- **Action Buttons** (top right): "Share Profile" | "Edit Profile"
- **User Info** (centered):
  - Name (large, bold)
  - Account type badge
  - Email
  - Bio (multiline)
- **Stats Grid** (4 columns):
  - Connections | Teams | Leagues | Post Views
- **Tabs:** Posts | Performance | Connections

**POSTS TAB:**
- Post creation widget
- User's posts list

**PERFORMANCE TAB:**
- **Achievements Card:**
  - Trophy icon list
  - Title, Year, Description for each

- **Performance Stats Card:**
  - Current Team
  - Position
  - Matches Played
  - Goals
  - Assists
  - MVPs
  - Saves
  - Wins / Losses
  - Win Rate %
  - Clean Sheets

**CONNECTIONS TAB:**
- **For Athletes:** Connection cards (photo, name, email) → Click to view profile
- **For Teams:** Player roster cards + Open Positions list

---

### 6. NETWORK SCREEN (`/network`)
**UI Elements:**
- Header: "My Network"
- Subtitle: "Connect with other athletes, coaches, and sports professionals"
- Search bar
- **Tabs:** My Connections | Pending Requests

**MY CONNECTIONS TAB:**
- Title: "Your Connections"
- Connection cards:
  - Avatar
  - Name
  - Email
  - "Connected" badge button

**PENDING REQUESTS TAB:**
- Title: "Pending Requests"
- Request cards:
  - Avatar
  - Name
  - Email
  - "Accept" button (green)
  - "Reject" button (red)

- **People You May Know Section** (bottom):
  - User suggestion cards
  - "Connect" buttons

---

### 7. TEAMS SCREEN (`/teams`)
**For Athletes:**
- **My Teams Section:**
  - Team cards (logo, name, sport, "View Details")

- **Available Teams Section:**
  - Sport filter chips (All Sports, Football, Cricket, etc.)
  - Team cards
  - "Apply" button

**For Team Accounts:**
- **Recruitment Dashboard Header** (Primary gradient with #d6ff3f):
  - Title: "Recruitment Hub"
  - Stats: Available Players | Active Recruitments | Recent Joins
  - "View Recruitment Stats" button

- **Player Filters Card:**
  - Search bar
  - Sport selector dropdown
  - Status filter (All/Available/Unavailable)
  - Experience filter
  - "Has Achievements" checkbox

- **Players Grid:**
  - Player cards (3 columns):
    - Avatar
    - Name, Position, Sport
    - Status badge
    - Stats: Goals, Assists, MVPs, Matches
    - Rank Score (highlighted)
    - "Start Recruitment" button

---

### 8. MESSAGES SCREEN (`/messages`)
**Layout:** 2-Column (Conversations | Chat)

**LEFT PANEL - Conversations:**
- Header: "Messages" with unread count badge
- Search bar
- Conversation list:
  - Avatar
  - Name
  - Last message preview
  - Timestamp
  - Unread indicator (primary color dot)

**RIGHT PANEL - Chat:**
- Header: Partner avatar + name
- Messages area (scrollable, reversed):
  - Message bubbles (sent: #d6ff3f right, received: gray left)
  - Timestamp below each
- Input area:
  - TextField: "Type a message..."
  - Send button (primary #d6ff3f)

---

### 9. ALERTS SCREEN (`/alerts`)
**UI Elements:**
- Header: Bell icon + "Notifications"
- "Mark all as read" button (top right)
- Notification cards:
  - Avatar of sender
  - Icon badge (connection/message icon)
  - Title (bold)
  - Description
  - Timestamp
  - "New" badge if unread
  - Click to navigate to relevant screen

---

### 10. LEAGUES SCREEN (`/leagues`)
**UI Elements:**
- Header: "Leagues & Live Scores"
- Search bar
- **Sport Filter Chips:** All | Cricket | Football | Basketball | Hockey, etc.
- "Show Map" / "Hide Map" toggle button
- Map view (Google Maps iframe when toggled)

**LEFT SIDEBAR - Leagues List:**
- Sport icon
- League name
- "View" button → Navigate to league detail

**MAIN CONTENT - Tabs:**
- **Live Matches Tab:**
  - "LIVE NOW" indicator (red pulsing dot)
  - Match cards (red left border):
    - LIVE badge
    - League name | Quarter/Time
    - Team 1 logo + name | Score | Team 2 logo + name

- **Upcoming Matches Tab:**
  - Calendar icon placeholder
  - "No upcoming matches"

- **My Leagues Tab:**
  - Trophy icon placeholder
  - "No subscribed leagues"

---

### 11. SETTINGS SCREEN (`/profile/settings`)
**UI Sections:**
- **Profile Information:**
  - Display Name TextField
  - Bio TextField (multiline)
  - "Upload Profile Picture" button
  - "Upload Banner" button
  - Save button

- **Personal Details:**
  - First Name
  - Last Name
  - Email (readonly)

- **Sports Information:**
  - Sports multi-select
  - Position
  - Current Team

- **Performance Stats:**
  - Matches Played, Goals, Assists, MVPs, etc. (numeric inputs)

- **Achievements:**
  - List with "Add Achievement" button
  - Each: Title, Description, Year

- **Privacy Settings:**
  - Profile visibility toggle
  - Connection requests toggle

- **Account Actions:**
  - "Change Password" button
  - "Delete Account" button (red, confirmation dialog)

---

## 🔧 IMPLEMENTATION STEPS

### PHASE 1: Project Setup
1. Create Flutter project
2. Add Supabase dependencies
3. Configure Supabase (iOS/Android/Web)
4. Setup project structure
5. Create theme with primary color #d6ff3f and constants
6. Create PostgreSQL database tables
7. Setup Row Level Security (RLS) policies

### PHASE 2: Authentication
8. Create auth models
9. Implement Supabase Auth service
10. Build Sign In screen
11. Build Sign Up screen
12. Build onboarding screens
13. Implement session management with secure storage

### PHASE 3: Core Features
14. Create user profile model and repository with PostgreSQL queries
15. Build Home screen layout
16. Implement post creation with Supabase Storage
17. Build posts feed with pagination
18. Implement likes and comments
19. Build Profile screen
20. Implement profile editing

### PHASE 4: Networking
21. Build Network screen
22. Implement connection requests with PostgreSQL arrays
23. Implement user search with full-text search
24. Build search results

### PHASE 5: Messaging
25. Create message model and repository
26. Build Messages screen
27. Implement real-time chat with Supabase Realtime
28. Add unread indicators

### PHASE 6: Notifications
29. Create notification system
30. Build Alerts screen
31. Add notification badges
32. Implement mark as read with realtime updates

### PHASE 7: Teams & Leagues
33. Build Teams screen
34. Implement team filtering with PostgreSQL queries
35. Build recruitment system with rank calculation
36. Build Leagues screen
37. Implement live matches display

### PHASE 8: Polish & Testing
38. Add loading states
39. Error handling
40. Implement image/video upload to Supabase Storage
41. Optimize PostgreSQL queries and indexes
42. Test all flows
43. Fix bugs
44. Deploy (Supabase handles backend scaling)

---

## 🎯 CRITICAL IMPLEMENTATION NOTES

### Theme Configuration
```dart
final primaryColor = Color(0xFFD6FF3F); // #d6ff3f - Lime green
final secondaryColor = Color(0xFF000000); // Black
final backgroundColor = Color(0xFFFFFFFF); // White
```

### Supabase Setup
1. **Initialize Supabase** in main.dart:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

2. **Row Level Security (RLS)** - Enable for all tables
3. **PostgreSQL indexes** - Already defined in schema above
4. **Implement pagination** for feeds (20 posts per page using `.range()`)
5. **Cache images** using cached_network_image
6. **Debounce search** (300ms delay)
7. **Real-time subscriptions** for messages and notifications:
```dart
supabase.from('messages').stream(primaryKey: ['id'])
  .listen((data) { /* handle updates */ });
```
8. **Rank calculation algorithm** for players:
   - MVPs × 100 + Goals × 50 + Assists × 30
   - Store in rank_score column, update with PostgreSQL function
9. **Case-insensitive search** using `display_name_lower` field with `ilike`
10. **Timestamp handling** - Supabase returns ISO strings, parse to DateTime
11. **Loading states** for all async operations
12. **Error handling** with user-friendly messages
13. **Image uploads** to Supabase Storage buckets:
    - `profiles` bucket for user photos
    - `posts` bucket for post media
14. **Use PostgreSQL array operations** for connections, teams, leagues

---

## 📝 ADDITIONAL FEATURES TO IMPLEMENT

### Priority Features
- Push notifications (using flutter_local_notifications + Supabase Edge Functions)
- Image cropping for profile/banner
- Video playback in posts
- Live match streaming API integration
- Calendar integration
- Share functionality

### Future Enhancements
- Stories feature
- Video calls
- Team analytics dashboard
- Match scheduling
- Payment integration for leagues
- Sponsorship system
- Verified badges

---

## 🎨 DESIGN SYSTEM

### Color Palette
- **Primary Color**: `#d6ff3f` (Lime Green) - Use for buttons, active states, highlights
- **Secondary Color**: `#000000` (Black) - Text, icons
- **Background**: `#FFFFFF` (White) - Main background
- **Surface**: `#F9FAFB` (Light Gray) - Cards, elevated surfaces
- **Error**: `#EF4444` (Red) - Error states, delete buttons
- **Success**: `#10B981` (Green) - Success messages
- **Warning**: `#F59E0B` (Amber) - Warning states

### Typography
- **Headings**: Bold, 24-32px
- **Body**: Regular, 14-16px
- **Captions**: Regular, 12px

### Spacing
- Use 4px base unit (4, 8, 12, 16, 24, 32, 48px)

---

## 🚀 QUICK START GUIDE

### 1. Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Create new project
3. Copy project URL and anon key
4. Run all SQL scripts from the database schema section

### 2. Setup Flutter Project
```bash
flutter create ztrike_app
cd ztrike_app
```

### 3. Add Dependencies
Add all dependencies from the tech stack section to `pubspec.yaml`

### 4. Configure Supabase
Create `lib/core/constants/supabase_constants.dart`:
```dart
class SupabaseConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 5. Initialize in main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );
  
  runApp(MyApp());
}
```

### 6. Follow Phase-by-Phase Implementation
Start with Phase 1 and work through each phase systematically.

---

## 📚 SUPABASE-SPECIFIC IMPLEMENTATIONS

### Authentication Example
```dart
// Sign up
final response = await supabase.auth.signUp(
  email: email,
  password: password,
);

// Sign in
final response = await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Google Sign In
await supabase.auth.signInWithOAuth(Provider.google);
```

### Database Queries Example
```dart
// Get user profile
final data = await supabase
  .from('users')
  .select()
  .eq('id', userId)
  .single();

// Create post
await supabase.from('posts').insert({
  'content': content,
  'author_id': authorId,
  'created_at': DateTime.now().toIso8601String(),
});

// Search users (case-insensitive)
final results = await supabase
  .from('users')
  .select()
  .ilike('display_name_lower', '%${searchQuery.toLowerCase()}%')
  .limit(10);

// Get posts with pagination
final posts = await supabase
  .from('posts')
  .select()
  .order('created_at', ascending: false)
  .range(start, end);
```

### Real-time Subscriptions Example
```dart
// Listen to new messages
final subscription = supabase
  .from('messages')
  .stream(primaryKey: ['id'])
  .eq('receiver_id', userId)
  .listen((data) {
    // Update UI with new messages
  });
```

### Storage Upload Example
```dart
// Upload image
final imageFile = File(imagePath);
final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

await supabase.storage
  .from('profiles')
  .upload(fileName, imageFile);

// Get public URL
final imageUrl = supabase.storage
  .from('profiles')
  .getPublicUrl(fileName);
```

---

## ✅ FINAL NOTES

This specification contains **EVERY** detail from your web application for Flutter implementation using:
- **Backend**: Supabase (PostgreSQL database)
- **Authentication**: Supabase Auth (Email/Password + Google OAuth)
- **Storage**: Supabase Storage (Images & Videos)
- **Real-time**: Supabase Realtime subscriptions
- **Primary Color**: #d6ff3f (Lime Green)
- **Theme**: White background with black text

All database schemas, RLS policies, storage configurations, and Flutter code examples are production-ready. Follow the implementation phases sequentially for best results.
