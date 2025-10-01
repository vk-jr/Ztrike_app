# ZTRIKE - Features Documentation

## 📋 Complete Feature List

### 🔐 Authentication & Onboarding

#### Sign Up
- **Email/Password Registration**
  - Email validation
  - Strong password requirements (8+ chars, uppercase, lowercase, number)
  - Confirm password validation
  - Account type selection (Athlete/Team/League)
  
- **Google Sign-In**
  - OAuth integration with Google
  - Auto-profile creation
  - Profile photo sync from Google

- **User Types**
  - **Athlete**: Individual players with performance stats
  - **Team**: Organizations managing rosters
  - **League**: Competition organizers

#### Sign In
- Email/password authentication
- Google OAuth
- "Remember me" (session persistence)
- Forgot password link (placeholder)

#### Onboarding (Athletes)
- Sports selection (multi-select)
  - Soccer, Basketball, Baseball, Tennis, Cricket, Volleyball, Hockey, Rugby, Others
- Position input
- Current team (optional)
- Social media links (optional)
  - Instagram, Twitter, Facebook, YouTube, TikTok, Strava
- Skip option available

---

### 👤 Profile Management

#### View Profile
- **Banner Image**
  - Custom upload or gradient default
  - Full-width display (240px height)
  
- **Profile Photo**
  - Circular avatar
  - Upload from gallery
  - Default icon fallback
  
- **User Information**
  - Display name
  - Account type badge
  - Email address
  - Bio/description
  
- **Statistics Grid**
  - Connections count
  - Teams count
  - Leagues count
  - Post views
  
- **Action Buttons**
  - Share profile
  - Edit profile

#### Profile Tabs

**1. Posts Tab**
- All user's posts
- Like/comment on own posts
- Delete own posts
- Post creation widget

**2. Performance Tab**
- **Achievements Section**
  - Title, description, year
  - Trophy icons
  - Add new achievements
  
- **Performance Statistics**
  - Current team
  - Position
  - Matches played
  - Goals scored
  - Assists
  - MVP awards
  - Saves
  - Wins/Losses
  - Win rate percentage
  - Clean sheets
  - Rank score (calculated)

**3. Connections Tab**
- List of all connections
- Connection profiles
- Quick message option

#### Edit Profile
- Update display name
- Change bio
- Upload profile photo
- Upload banner image
- Update sports
- Edit position
- Change current team
- Update performance stats
- Add achievements

---

### 📝 Posts & Feed

#### Create Post
- **Text Posts**
  - Multi-line text input
  - "What's on your mind?" prompt
  - Character limit (reasonable)
  
- **Image Posts**
  - Select from gallery
  - Image preview before posting
  - Remove image option
  - Upload to Supabase Storage
  
- **Video Posts** (Placeholder)
  - Video selection button
  - Future implementation ready

#### View Feed
- **Home Feed**
  - All public posts
  - Reverse chronological order
  - Pagination (20 posts per page)
  - Pull to refresh
  
- **Post Card Display**
  - Author avatar
  - Author name
  - Post timestamp (relative: "2h ago")
  - Post content
  - Image/video display
  - Like count
  - Comment count
  
#### Interact with Posts
- **Like**
  - Heart icon (filled when liked)
  - Real-time count update
  - Toggle like/unlike
  
- **Comment**
  - View all comments
  - Add new comment
  - Comment author info
  - Comment timestamp
  
- **Delete**
  - Delete own posts only
  - Confirmation required
  - Cascading delete (comments removed)

---

### 🤝 Social Networking

#### Connection System
- **Send Connection Request**
  - One-click send
  - Appears in recipient's pending requests
  - Notification created
  
- **Receive Requests**
  - View all pending requests
  - Accept or reject options
  - Notification sent on acceptance
  
- **My Connections**
  - Grid/list of all connections
  - View connection profiles
  - Send direct message
  - Connection count displayed

#### People Discovery
- **People You May Know**
  - Algorithm-based suggestions
  - Exclude existing connections
  - Exclude sent/received requests
  - Based on sports/interests (future)
  
- **Search Users**
  - Search by name (case-insensitive)
  - Real-time results
  - Filter by account type
  - View search results

#### User Profiles
- View any user's public profile
- See their posts
- View their stats
- Send connection request
- Start conversation (if connected)

---

### 💬 Messaging

#### Conversations
- **Conversation List**
  - All active chats
  - Last message preview
  - Timestamp (relative)
  - Unread indicator (dot)
  - Sorted by most recent
  
- **Search Conversations**
  - Find specific chat
  - Search by user name

#### Chat Interface
- **Real-time Messaging**
  - Supabase Realtime integration
  - Instant message delivery
  - Message streaming
  
- **Message Display**
  - Sender bubbles (right, lime green)
  - Receiver bubbles (left, gray)
  - Message timestamp
  - Read status
  
- **Send Messages**
  - Text input field
  - Send button
  - Enter to send
  - Character limit
  
- **Mark as Read**
  - Auto-mark when viewing
  - Update unread count

#### Notifications Integration
- New message notification
- Unread count badge
- Notification on receive

---

### 🔔 Notifications

#### Notification Types
1. **Connection Request**
   - "X wants to connect with you"
   - Person icon
   - Orange color
   
2. **Connection Accepted**
   - "X accepted your connection request"
   - Check icon
   - Green color
   
3. **New Message**
   - "X sent you a message"
   - Message icon
   - Lime green color

#### Notification Management
- **View All Notifications**
  - Reverse chronological order
  - Unread highlighted
  - New badge indicator
  
- **Mark as Read**
  - Swipe to dismiss
  - Tap to mark read
  - Auto-mark on view
  
- **Mark All as Read**
  - Single action
  - Clear all badges
  
- **Unread Count**
  - Badge on Alerts tab
  - Real-time updates

#### Real-time Updates
- Instant notification delivery
- Supabase Realtime subscription
- No refresh needed
- Push notification ready (future)

---

### 🏆 Teams & Leagues

#### Browse Teams
- **Team List**
  - Grid/card layout
  - Team logo display
  - Team name
  - Sport type
  - Win/Loss record
  
- **Filter by Sport**
  - Sport filter chips
  - All Sports option
  - Dynamic filtering
  
- **Team Details** (Future)
  - Full team info
  - Player roster
  - Match history
  - Statistics

#### Browse Leagues
- **League List**
  - League name
  - Sport type
  - Number of teams
  - Status (active/inactive)
  
- **Filter Options**
  - Sport-based filtering
  - Status filtering

#### Matches
- **Live Matches**
  - Live indicator (pulsing)
  - Team names and logos
  - Current score
  - Match time/quarter
  - "Watch Now" button
  - Red accent border
  
- **Upcoming Matches**
  - Match schedule
  - Team matchups
  - Start time
  - Location
  - "Remind Me" option
  - "Add to Calendar" option
  
- **Match Details** (Future)
  - Live updates
  - Play-by-play
  - Team stats
  - Player stats

#### Team Management (Team Accounts)
- **Recruitment Dashboard**
  - Available players
  - Active recruitments
  - Recent joins
  
- **Player Search**
  - Filter by sport
  - Filter by position
  - Filter by status
  - Experience level
  - Has achievements
  
- **Player Rankings**
  - Rank score display
  - Sort by performance
  - MVP count, goals, assists
  - "Start Recruitment" button

---

### 📊 Performance Tracking

#### Athlete Statistics
- **Match Data**
  - Matches played
  - Goals scored
  - Assists
  - Saves (goalkeepers)
  
- **Performance Metrics**
  - MVP awards
  - Clean sheets
  - Win/Loss record
  - Win rate calculation
  
- **Rank Score Calculation**
  - Formula: MVPs × 100 + Goals × 50 + Assists × 30
  - Auto-calculated
  - Displayed prominently
  - Used for player rankings

#### Achievements
- **Add Achievement**
  - Title
  - Description
  - Year
  - Trophy icon
  
- **Display**
  - Performance tab
  - Trophy list
  - Chronological order

#### Team Statistics (Team Accounts)
- Wins/Losses/Draws
- Matches played
- Player count
- Active recruitments
- Team ranking (future)

---

### 🎨 UI/UX Features

#### Responsive Design
- **Mobile** (< 600px)
  - Single column layout
  - Stacked navigation
  - Full-width cards
  
- **Tablet** (600-900px)
  - Two-column layout
  - Side navigation
  - Optimized spacing
  
- **Desktop** (> 900px)
  - Three-column layout
  - Fixed sidebars
  - Maximum content width

#### Theme System
- **Colors**
  - Primary: #D6FF3F (Lime Green)
  - Black text on white background
  - Consistent color usage
  
- **Typography**
  - Clear hierarchy
  - Readable font sizes
  - Proper line heights
  
- **Components**
  - Material Design 3
  - Consistent styling
  - Smooth animations

#### Loading States
- Circular progress indicators
- Skeleton screens (future)
- Pull to refresh
- Loading overlays

#### Error Handling
- User-friendly messages
- Form validation feedback
- Network error handling
- Retry options

#### Empty States
- "No posts yet" messages
- "No connections" placeholders
- Helpful suggestions
- Call-to-action buttons

---

### 🔧 Technical Features

#### Real-time Updates
- **Supabase Realtime**
  - Messages stream
  - Notifications stream
  - Live match updates
  
- **Auto-refresh**
  - New messages appear instantly
  - Notifications in real-time
  - No manual refresh needed

#### Image Management
- **Upload**
  - Supabase Storage integration
  - Automatic compression
  - Progress indication
  
- **Caching**
  - Cached Network Image
  - Reduced bandwidth
  - Faster loading
  
- **Display**
  - Placeholder while loading
  - Error fallback
  - Responsive sizing

#### Pagination
- **Posts Feed**
  - 20 posts per page
  - Load more on scroll
  - Efficient data fetching
  
- **Search Results**
  - Limit results
  - Progressive loading

#### Search
- **User Search**
  - Case-insensitive
  - Partial matching
  - Real-time results
  - Debounced (300ms)

#### Database Optimization
- Indexed columns
- Efficient queries
- Array operations
- JSONB for flexible data

---

### 🔐 Security Features

#### Authentication Security
- Secure password hashing (Supabase)
- Session management
- Secure token storage
- Auto-logout on session expire

#### Row Level Security (RLS)
- **Users Table**
  - View: All users
  - Update: Own profile only
  - Insert: Own profile only
  
- **Posts Table**
  - View: All posts
  - Create: Authenticated users
  - Update/Delete: Own posts only
  
- **Messages Table**
  - View: Sender or receiver only
  - Create: Authenticated users
  - Update: Receiver only (mark read)
  
- **Notifications Table**
  - View: Own notifications only
  - Update: Own notifications only

#### Data Validation
- Form input validation
- Email format checking
- Password strength requirements
- Required field validation
- Server-side validation (Supabase)

---

### 📱 Platform-Specific Features

#### Android
- Back button handling
- Material Design components
- Camera/gallery access
- Push notifications ready

#### iOS
- iOS design guidelines
- Native feel
- Camera/photo library access
- Push notifications ready

#### Web
- PWA capabilities
- Responsive layouts
- Browser compatibility
- Keyboard shortcuts

---

### 🚀 Future Feature Ideas

#### Planned Enhancements
- [ ] Video upload and playback
- [ ] Live streaming matches
- [ ] Story feature (24-hour posts)
- [ ] Video calls
- [ ] Advanced analytics
- [ ] Payment integration
- [ ] Verified badges
- [ ] Sponsorship system
- [ ] Match scheduling
- [ ] Calendar integration
- [ ] Push notifications (FCM)
- [ ] Deep linking
- [ ] Share to social media
- [ ] Export stats/resume
- [ ] Dark mode
- [ ] Multiple languages
- [ ] Accessibility features

#### Community Features
- [ ] Team chat groups
- [ ] League forums
- [ ] Event creation
- [ ] Tournament brackets
- [ ] Fan engagement
- [ ] Polls and voting

#### Monetization Ideas
- [ ] Premium profiles
- [ ] Featured listings
- [ ] Recruitment tools (paid)
- [ ] Analytics dashboard (paid)
- [ ] Ad-free experience
- [ ] Verified accounts

---

## 🎯 Feature Matrix

| Feature | Athlete | Team | League | Status |
|---------|---------|------|--------|--------|
| Sign Up/In | ✅ | ✅ | ✅ | Complete |
| Profile | ✅ | ✅ | ✅ | Complete |
| Posts | ✅ | ✅ | ✅ | Complete |
| Connections | ✅ | ✅ | ✅ | Complete |
| Messaging | ✅ | ✅ | ✅ | Complete |
| Notifications | ✅ | ✅ | ✅ | Complete |
| Performance Stats | ✅ | ❌ | ❌ | Complete |
| Achievements | ✅ | ❌ | ❌ | Complete |
| Team Browsing | ✅ | ✅ | ✅ | Complete |
| League Browsing | ✅ | ✅ | ✅ | Complete |
| Match Viewing | ✅ | ✅ | ✅ | Complete |
| Player Search | ❌ | ✅ | ❌ | Complete |
| Recruitment | ❌ | ✅ | ❌ | Placeholder |
| Match Creation | ❌ | ❌ | ✅ | Future |
| League Management | ❌ | ❌ | ✅ | Future |

---

**Last Updated**: October 2025
**Version**: 1.0.0
