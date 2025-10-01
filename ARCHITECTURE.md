# ZTRIKE - Architecture Documentation

## 🏗️ Application Architecture

ZTRIKE follows a **Clean Architecture** pattern with clear separation of concerns between layers.

### Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens, Widgets, Providers)          │
├─────────────────────────────────────────┤
│          Domain Layer                   │
│       (Business Logic)                  │
├─────────────────────────────────────────┤
│           Data Layer                    │
│  (Models, Repositories, Services)       │
├─────────────────────────────────────────┤
│         Infrastructure                  │
│    (Supabase, Storage, Network)         │
└─────────────────────────────────────────┘
```

---

## 📂 Project Structure

```
lib/
├── main.dart                              # Application entry point
│
├── core/                                  # Core utilities & shared code
│   ├── constants/
│   │   ├── app_constants.dart            # App-wide constants
│   │   └── supabase_constants.dart       # Supabase configuration
│   ├── theme/
│   │   └── app_theme.dart                # Theme & styling definitions
│   └── utils/
│       ├── validators.dart               # Form validation utilities
│       ├── image_helper.dart             # Image picker utilities
│       ├── date_helper.dart              # Date formatting utilities
│       └── string_helper.dart            # String manipulation utilities
│
├── data/                                  # Data layer
│   ├── models/                           # Data models
│   │   ├── user_model.dart               # User entity
│   │   ├── post_model.dart               # Post & Comment entities
│   │   ├── message_model.dart            # Message entity
│   │   ├── notification_model.dart       # Notification entity
│   │   └── team_model.dart               # Team, League, Match, Achievement entities
│   │
│   ├── repositories/                     # Data access layer
│   │   ├── user_repository.dart          # User CRUD & connections
│   │   ├── post_repository.dart          # Post CRUD & interactions
│   │   ├── message_repository.dart       # Messaging operations
│   │   ├── notification_repository.dart  # Notification operations
│   │   └── team_repository.dart          # Team/League operations
│   │
│   └── services/                         # External services
│       └── auth_service.dart             # Authentication service
│
└── presentation/                          # Presentation layer
    ├── providers/                        # State management
    │   └── auth_provider.dart            # Authentication state
    │
    ├── screens/                          # Application screens
    │   ├── auth/
    │   │   ├── sign_in_screen.dart       # Login screen
    │   │   ├── sign_up_screen.dart       # Registration screen
    │   │   └── athlete_onboarding_screen.dart  # Onboarding
    │   ├── home/
    │   │   └── home_screen.dart          # Home feed
    │   ├── profile/
    │   │   └── profile_screen.dart       # User profile
    │   ├── network/
    │   │   └── network_screen.dart       # Connections
    │   ├── teams/
    │   │   └── teams_screen.dart         # Teams browser
    │   ├── messages/
    │   │   └── messages_screen.dart      # Messaging
    │   ├── alerts/
    │   │   └── alerts_screen.dart        # Notifications
    │   └── leagues/
    │       └── leagues_screen.dart       # Leagues & matches
    │
    └── widgets/                          # Reusable widgets
        ├── profile_card_widget.dart      # Profile sidebar card
        └── post_card_widget.dart         # Post display card
```

---

## 🔄 Data Flow

### 1. User Action Flow

```
User Interaction
    ↓
Widget (Screen)
    ↓
Provider (State Management)
    ↓
Repository (Data Access)
    ↓
Supabase Client
    ↓
PostgreSQL Database / Storage
    ↓
Response
    ↓
Model (Data Object)
    ↓
Provider Updates State
    ↓
Widget Rebuilds
    ↓
UI Updates
```

### 2. Example: Creating a Post

```dart
// 1. User taps "Post" button
onPressed: _createPost()

// 2. Screen calls repository
await _postRepository.createPost(
  authorId: userId,
  content: content,
  imageFile: image,
)

// 3. Repository uploads image
final imageUrl = await _supabase.storage
  .from('posts')
  .upload(fileName, imageFile)

// 4. Repository inserts to database
await _supabase.from('posts').insert({...})

// 5. Repository returns model
return PostModel.fromJson(response)

// 6. Screen updates UI
setState(() => _posts.insert(0, newPost))
```

---

## 🗄️ Database Architecture

### Supabase PostgreSQL Schema

```sql
┌────────────────────────────────────────┐
│            auth.users                  │ (Supabase Auth)
│  - id (UUID)                           │
│  - email                               │
│  - encrypted_password                  │
└────────────────────────────────────────┘
                    ↓ references
┌────────────────────────────────────────┐
│              users                     │
│  - id (UUID, PK)                       │
│  - auth_id (UUID, FK → auth.users)     │
│  - email, display_name                 │
│  - photo_url, banner_url               │
│  - connections[] (array)               │
│  - pending_requests[] (array)          │
│  - teams[], leagues[] (arrays)         │
│  - performance stats (integers)        │
│  - team_info (JSONB)                   │
└────────────────────────────────────────┘
         ↓                    ↓
    ┌─────────┐         ┌──────────┐
    │  posts  │         │ messages │
    └─────────┘         └──────────┘
         ↓
    ┌──────────┐
    │ comments │
    └──────────┘
```

### Key Relationships

1. **users ← auth.users** (One-to-One)
   - auth_id links custom profile to Supabase auth

2. **posts → users** (Many-to-One)
   - author_id references users.id

3. **comments → posts** (Many-to-One)
   - post_id references posts.id

4. **messages → users** (Many-to-One × 2)
   - sender_id and receiver_id reference users.id

5. **notifications → users** (Many-to-One × 2)
   - user_id and from_id reference users.id

---

## 🔐 Security Architecture

### Row Level Security (RLS)

**Philosophy**: Users can only access data they're authorized to see.

```sql
-- Users Table
✅ SELECT: All users (public profiles)
✅ UPDATE: Own profile only (auth.uid() = auth_id)
✅ INSERT: Own profile only

-- Posts Table
✅ SELECT: Everyone (public feed)
✅ INSERT: Authenticated users
✅ UPDATE/DELETE: Author only

-- Messages Table
✅ SELECT: Sender OR receiver
✅ INSERT: Authenticated users (as sender)
✅ UPDATE: Receiver only (mark as read)

-- Notifications Table
✅ SELECT: Notification recipient only
✅ UPDATE: Recipient only
✅ INSERT: System (any authenticated user)
```

### Authentication Flow

```
1. User enters credentials
   ↓
2. Supabase Auth validates
   ↓
3. JWT token generated
   ↓
4. Token stored securely (flutter_secure_storage)
   ↓
5. Token sent with all requests
   ↓
6. Supabase validates token
   ↓
7. RLS policies enforce access control
```

---

## 📡 API Architecture

### Supabase Client Integration

```dart
// Singleton pattern
final SupabaseClient _supabase = Supabase.instance.client;

// Query example
final data = await _supabase
  .from('posts')
  .select()
  .order('created_at', ascending: false)
  .range(0, 19);

// Insert example
await _supabase.from('posts').insert({
  'content': content,
  'author_id': userId,
});

// Real-time subscription
_supabase
  .from('messages')
  .stream(primaryKey: ['id'])
  .eq('receiver_id', userId)
  .listen((data) { /* handle updates */ });
```

### Storage Architecture

```
Supabase Storage
├── profiles/                    (Public bucket)
│   ├── user1_avatar.jpg
│   ├── user2_banner.jpg
│   └── ...
└── posts/                       (Public bucket)
    ├── post1_image.jpg
    ├── post2_image.jpg
    └── ...
```

**Upload Process**:
1. Pick image locally
2. Generate unique filename (timestamp + random)
3. Upload to bucket
4. Get public URL
5. Store URL in database

---

## 🎯 State Management Architecture

### Provider Pattern

```dart
// Provider at top level
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: MaterialApp(...)
)

// Access in widget
final authProvider = context.watch<AuthProvider>();
final user = authProvider.currentUser;

// Trigger actions
context.read<AuthProvider>().signOut();
```

### State Lifecycle

```
App Startup
    ↓
AuthProvider initialized
    ↓
Check existing session
    ↓
If session exists → Load user profile
    ↓
notifyListeners()
    ↓
UI rebuilds with user data
```

---

## 🔄 Real-time Architecture

### Supabase Realtime

**How it works**:
1. Subscribe to table changes
2. Supabase broadcasts updates via WebSocket
3. Stream emits new data
4. Widget rebuilds automatically

**Example: Real-time Messages**

```dart
Stream<List<MessageModel>> streamMessages(userId, partnerId) {
  return _supabase
    .from('messages')
    .stream(primaryKey: ['id'])
    .or('and(sender_id.eq.$userId,receiver_id.eq.$partnerId),
         and(sender_id.eq.$partnerId,receiver_id.eq.$userId)')
    .order('created_at')
    .map((data) => data.map((json) => 
         MessageModel.fromJson(json)).toList());
}
```

---

## 🎨 UI Architecture

### Widget Hierarchy

```
MaterialApp
└── MultiProvider
    └── MainScreen (Bottom Navigation)
        ├── HomeScreen
        │   ├── ProfileCardWidget (left sidebar)
        │   ├── PostCreationCard
        │   ├── PostCardWidget (feed)
        │   └── SuggestionsWidget (right sidebar)
        ├── NetworkScreen
        ├── TeamsScreen
        ├── MessagesScreen
        └── AlertsScreen
```

### Responsive Design

```dart
// Screen width breakpoints
if (MediaQuery.of(context).size.width > 1200) {
  // Desktop: 3-column layout
} else if (MediaQuery.of(context).size.width > 900) {
  // Tablet: 2-column layout
} else {
  // Mobile: single column
}
```

---

## 🔌 Plugin Architecture

### Core Plugins

**Supabase Flutter** (`supabase_flutter: ^2.5.0`)
- Database operations
- Authentication
- Storage
- Real-time subscriptions

**Google Sign-In** (`google_sign_in: ^6.2.1`)
- OAuth authentication
- Profile data sync

**Provider** (`provider: ^6.1.1`)
- State management
- Dependency injection

**Cached Network Image** (`cached_network_image: ^3.3.1`)
- Image caching
- Memory optimization
- Placeholder support

**Image Picker** (`image_picker: ^1.0.7`)
- Camera access
- Gallery access
- Cross-platform

---

## 📊 Performance Architecture

### Optimization Strategies

**1. Image Caching**
```dart
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

**2. Pagination**
```dart
// Load 20 posts at a time
final posts = await _supabase
  .from('posts')
  .select()
  .range(offset, offset + 19);
```

**3. Lazy Loading**
- Images load as they appear in viewport
- Infinite scroll for feeds
- On-demand data fetching

**4. Database Indexes**
```sql
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_users_display_name_lower ON users(display_name_lower);
CREATE INDEX idx_messages_participants ON messages(sender_id, receiver_id);
```

---

## 🧪 Testing Architecture

### Testing Strategy (Future)

**Unit Tests**
- Model serialization/deserialization
- Utility functions
- Business logic

**Widget Tests**
- Individual widget rendering
- User interactions
- State changes

**Integration Tests**
- End-to-end flows
- API integration
- Database operations

---

## 🚀 Deployment Architecture

### Build Process

```
Source Code (lib/)
    ↓
Flutter Compiler
    ↓
Platform-specific builds
    ├── Android: APK/AAB
    ├── iOS: IPA
    └── Web: JS bundle
    ↓
Distribution
    ├── Google Play Store
    ├── Apple App Store
    └── Web hosting (Netlify/Vercel/Firebase)
```

### Environment Configuration

```dart
// Development
const bool isDevelopment = true;
const String apiUrl = 'https://dev.supabase.co';

// Production
const bool isDevelopment = false;
const String apiUrl = 'https://prod.supabase.co';
```

---

## 🔍 Monitoring Architecture (Planned)

### Error Tracking
- Firebase Crashlytics
- Error logging service
- User feedback system

### Analytics
- Firebase Analytics
- User behavior tracking
- Feature usage metrics

### Performance Monitoring
- App performance metrics
- API response times
- Database query performance

---

## 📈 Scalability Considerations

### Database Scaling
- Supabase handles auto-scaling
- Connection pooling
- Read replicas (if needed)

### Storage Scaling
- Supabase Storage auto-scales
- CDN for image delivery
- Image optimization

### Application Scaling
- Stateless design
- Horizontal scaling ready
- Load balancing (platform handles)

---

## 🔄 Future Architecture Enhancements

### Planned Improvements

1. **Microservices** (if needed)
   - Separate services for heavy operations
   - Edge functions for complex logic

2. **Caching Layer**
   - Redis for frequently accessed data
   - Local database (SQLite) for offline support

3. **Message Queue**
   - Background job processing
   - Scheduled tasks

4. **GraphQL** (alternative to REST)
   - More efficient data fetching
   - Reduced over-fetching

5. **Offline Support**
   - Local data persistence
   - Sync when online
   - Conflict resolution

---

## 📝 Architecture Decisions

### Why Supabase?
- ✅ Built-in authentication
- ✅ Real-time capabilities
- ✅ PostgreSQL (powerful & reliable)
- ✅ Row Level Security
- ✅ Storage included
- ✅ Auto-scaling

### Why Provider?
- ✅ Simple state management
- ✅ Built into Flutter
- ✅ Good for medium apps
- ✅ Easy to understand

### Why Clean Architecture?
- ✅ Separation of concerns
- ✅ Testable code
- ✅ Maintainable
- ✅ Scalable

### Why PostgreSQL (via Supabase)?
- ✅ Relational data model fits use case
- ✅ ACID compliance
- ✅ Complex queries support
- ✅ JSONB for flexible data

---

## 🎓 Best Practices Followed

1. **Single Responsibility** - Each class has one job
2. **DRY** - Don't Repeat Yourself
3. **Separation of Concerns** - Layers are independent
4. **Error Handling** - Try-catch blocks everywhere
5. **Null Safety** - Using Dart null safety
6. **Code Organization** - Clear folder structure
7. **Naming Conventions** - Consistent naming
8. **Documentation** - Inline comments where needed

---

**Last Updated**: October 2025
**Version**: 1.0.0
