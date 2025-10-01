# ZTRIKE - API Documentation

## 🔌 Supabase API Reference

This document outlines all database operations and API calls used in the ZTRIKE application.

---

## 🔐 Authentication API

### Sign Up with Email

```dart
final response = await supabase.auth.signUp(
  email: 'user@example.com',
  password: 'password123',
);

// Access user
final user = response.user;
final session = response.session;
```

**Response:**
- `user`: User object with id, email, etc.
- `session`: Session object with access token

**Errors:**
- `Email already registered`
- `Password too weak`
- `Invalid email format`

---

### Sign In with Email

```dart
final response = await supabase.auth.signInWithPassword(
  email: 'user@example.com',
  password: 'password123',
);
```

**Response:**
- `user`: Authenticated user
- `session`: Active session with JWT token

**Errors:**
- `Invalid login credentials`
- `Email not confirmed`

---

### Sign In with Google OAuth

```dart
final response = await supabase.auth.signInWithOAuth(
  Provider.google,
);
```

**Response:**
- Redirects to Google OAuth
- Returns user and session on success

---

### Sign Out

```dart
await supabase.auth.signOut();
```

---

### Get Current User

```dart
final user = supabase.auth.currentUser;
```

**Returns:**
- User object if authenticated
- null if not authenticated

---

### Auth State Stream

```dart
supabase.auth.onAuthStateChange.listen((data) {
  final event = data.event; // SIGNED_IN, SIGNED_OUT, etc.
  final session = data.session;
});
```

---

## 👤 Users API

### Get User by ID

```dart
final data = await supabase
  .from('users')
  .select()
  .eq('id', userId)
  .single();

final user = UserModel.fromJson(data);
```

**Response:** User object

**Fields:**
- id, email, display_name
- photo_url, banner_url, bio
- connections[], teams[], leagues[]
- performance stats
- team_info (JSONB)

---

### Get User by Auth ID

```dart
final data = await supabase
  .from('users')
  .select()
  .eq('auth_id', authId)
  .maybeSingle();
```

**Returns:** User object or null

---

### Update User Profile

```dart
await supabase
  .from('users')
  .update({
    'display_name': 'New Name',
    'bio': 'New bio',
    'updated_at': DateTime.now().toIso8601String(),
  })
  .eq('id', userId);
```

**RLS Policy:** Can only update own profile

---

### Search Users

```dart
final data = await supabase
  .from('users')
  .select()
  .ilike('display_name_lower', '%search%')
  .limit(10);

final users = (data as List)
  .map((json) => UserModel.fromJson(json))
  .toList();
```

**Query Parameters:**
- Search term (case-insensitive)
- Limit (default: 10)

---

### Get Users by Account Type

```dart
final data = await supabase
  .from('users')
  .select()
  .eq('account_type', 'athlete')
  .limit(20);
```

**Account Types:**
- `athlete`
- `team`
- `league`

---

### Get Multiple Users by IDs

```dart
final data = await supabase
  .from('users')
  .select()
  .in_('id', ['id1', 'id2', 'id3']);
```

**Use Case:** Get connections list

---

### Send Connection Request

```dart
// Manual array update (since RPC may not exist)
final userData = await supabase
  .from('users')
  .select('sent_requests')
  .eq('id', fromUserId)
  .single();

List<String> sentRequests = List<String>.from(userData['sent_requests'] ?? []);
sentRequests.add(toUserId);

await supabase
  .from('users')
  .update({'sent_requests': sentRequests})
  .eq('id', fromUserId);

// Similar for receiver's pending_requests
```

**Creates Notification:** Connection request notification

---

### Accept Connection Request

```dart
// Update both users' arrays
// Add to connections[], remove from pending_requests/sent_requests
await supabase.from('users').update({
  'connections': updatedConnections,
  'pending_requests': updatedPending,
}).eq('id', userId);
```

**Creates Notification:** Connection accepted notification

---

## 📝 Posts API

### Get All Posts (Paginated)

```dart
final data = await supabase
  .from('posts')
  .select()
  .order('created_at', ascending: false)
  .range(0, 19); // First 20 posts

final posts = (data as List)
  .map((json) => PostModel.fromJson(json))
  .toList();
```

**Pagination:**
- Page 1: range(0, 19)
- Page 2: range(20, 39)
- etc.

---

### Get Posts by Author

```dart
final data = await supabase
  .from('posts')
  .select()
  .eq('author_id', authorId)
  .order('created_at', ascending: false);
```

---

### Create Post

```dart
final data = await supabase.from('posts').insert({
  'author_id': userId,
  'content': 'Post content',
  'author_name': 'User Name',
  'author_photo_url': 'https://...',
  'image_url': 'https://...', // Optional
  'created_at': DateTime.now().toIso8601String(),
}).select().single();

final post = PostModel.fromJson(data);
```

**RLS Policy:** Authenticated users can create

---

### Like/Unlike Post

```dart
final post = await supabase
  .from('posts')
  .select()
  .eq('id', postId)
  .single();

List<String> likedBy = List<String>.from(post['liked_by'] ?? []);
int likes = post['likes'] ?? 0;

if (likedBy.contains(userId)) {
  // Unlike
  likedBy.remove(userId);
  likes--;
} else {
  // Like
  likedBy.add(userId);
  likes++;
}

await supabase.from('posts').update({
  'liked_by': likedBy,
  'likes': likes,
}).eq('id', postId);
```

---

### Delete Post

```dart
await supabase
  .from('posts')
  .delete()
  .eq('id', postId);
```

**RLS Policy:** Author only

**Cascading:** Comments are deleted automatically

---

### Get Comments for Post

```dart
final data = await supabase
  .from('comments')
  .select()
  .eq('post_id', postId)
  .order('created_at', ascending: false);

final comments = (data as List)
  .map((json) => CommentModel.fromJson(json))
  .toList();
```

---

### Add Comment

```dart
final data = await supabase.from('comments').insert({
  'post_id': postId,
  'author_id': userId,
  'content': 'Comment text',
  'author_name': 'User Name',
  'author_photo_url': 'https://...',
  'created_at': DateTime.now().toIso8601String(),
}).select().single();
```

---

## 💬 Messages API

### Get Conversations

```dart
final data = await supabase
  .from('messages')
  .select()
  .or('sender_id.eq.$userId,receiver_id.eq.$userId')
  .order('created_at', ascending: false);
```

**Returns:** All messages involving user

**Processing:** Group by conversation partner

---

### Get Messages Between Users

```dart
final data = await supabase
  .from('messages')
  .select()
  .or('and(sender_id.eq.$userId,receiver_id.eq.$partnerId),and(sender_id.eq.$partnerId,receiver_id.eq.$userId)')
  .order('created_at', ascending: true);
```

**Returns:** Messages sorted chronologically

---

### Send Message

```dart
final data = await supabase.from('messages').insert({
  'sender_id': senderId,
  'receiver_id': receiverId,
  'content': 'Message text',
  'sender_name': 'Sender Name',
  'sender_photo_url': 'https://...',
  'read': false,
  'created_at': DateTime.now().toIso8601String(),
}).select().single();
```

**Creates Notification:** New message notification

---

### Mark Messages as Read

```dart
await supabase
  .from('messages')
  .update({'read': true})
  .eq('sender_id', partnerId)
  .eq('receiver_id', userId);
```

**RLS Policy:** Receiver can update

---

### Get Unread Count

```dart
final data = await supabase
  .from('messages')
  .select('id', const FetchOptions(count: CountOption.exact))
  .eq('receiver_id', userId)
  .eq('read', false);

final count = data.count ?? 0;
```

---

### Stream Messages (Real-time)

```dart
final stream = supabase
  .from('messages')
  .stream(primaryKey: ['id'])
  .or('and(sender_id.eq.$userId,receiver_id.eq.$partnerId),and(sender_id.eq.$partnerId,receiver_id.eq.$userId)')
  .order('created_at', ascending: true);

stream.listen((data) {
  final messages = data.map((json) => MessageModel.fromJson(json)).toList();
  // Update UI
});
```

---

## 🔔 Notifications API

### Get Notifications

```dart
final data = await supabase
  .from('notifications')
  .select()
  .eq('user_id', userId)
  .order('created_at', ascending: false);

final notifications = (data as List)
  .map((json) => NotificationModel.fromJson(json))
  .toList();
```

---

### Get Unread Count

```dart
final data = await supabase
  .from('notifications')
  .select('id', const FetchOptions(count: CountOption.exact))
  .eq('user_id', userId)
  .eq('read', false);

final count = data.count ?? 0;
```

---

### Mark as Read

```dart
await supabase
  .from('notifications')
  .update({'read': true})
  .eq('id', notificationId);
```

---

### Mark All as Read

```dart
await supabase
  .from('notifications')
  .update({'read': true})
  .eq('user_id', userId);
```

---

### Create Notification

```dart
await supabase.from('notifications').insert({
  'user_id': recipientId,
  'from_id': senderId,
  'type': 'connection_request',
  'title': 'New Connection Request',
  'description': 'User wants to connect',
  'created_at': DateTime.now().toIso8601String(),
});
```

**Notification Types:**
- `message`
- `connection_request`
- `connection_accepted`

---

### Stream Notifications (Real-time)

```dart
final stream = supabase
  .from('notifications')
  .stream(primaryKey: ['id'])
  .eq('user_id', userId)
  .order('created_at', ascending: false);

stream.listen((data) {
  final notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
  // Update UI
});
```

---

## 🏆 Teams & Leagues API

### Get All Teams

```dart
final data = await supabase
  .from('teams')
  .select()
  .order('created_at', ascending: false);
```

**Optional Filter:**
```dart
.eq('sport', 'Soccer')
```

---

### Get Team by ID

```dart
final data = await supabase
  .from('teams')
  .select()
  .eq('id', teamId)
  .single();

final team = TeamModel.fromJson(data);
```

---

### Get All Leagues

```dart
final data = await supabase
  .from('leagues')
  .select()
  .order('created_at', ascending: false);
```

**Optional Filter:**
```dart
.eq('sport', 'Basketball')
```

---

### Get Matches

```dart
final data = await supabase
  .from('matches')
  .select()
  .order('start_time', ascending: false);
```

**Filter by Status:**
```dart
.eq('status', 'live')  // 'live', 'scheduled', 'completed'
```

---

### Get Achievements

```dart
final data = await supabase
  .from('achievements')
  .select()
  .eq('user_id', userId)
  .order('created_at', ascending: false);

final achievements = (data as List)
  .map((json) => AchievementModel.fromJson(json))
  .toList();
```

---

### Add Achievement

```dart
final data = await supabase.from('achievements').insert({
  'user_id': userId,
  'title': 'MVP Award',
  'description': 'League MVP 2024',
  'year': '2024',
  'created_at': DateTime.now().toIso8601String(),
}).select().single();
```

---

## 📦 Storage API

### Upload Image

```dart
final file = File(imagePath);
final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

await supabase.storage
  .from('profiles')  // or 'posts'
  .upload(fileName, file);

// Get public URL
final imageUrl = supabase.storage
  .from('profiles')
  .getPublicUrl(fileName);
```

**Buckets:**
- `profiles` - User photos and banners
- `posts` - Post images and videos

---

### Delete Image

```dart
await supabase.storage
  .from('profiles')
  .remove(['fileName.jpg']);
```

---

## 🔍 Advanced Queries

### Full-Text Search

```dart
final data = await supabase
  .from('users')
  .select()
  .textSearch('display_name', 'search term');
```

---

### Complex Filters

```dart
final data = await supabase
  .from('users')
  .select()
  .eq('account_type', 'athlete')
  .contains('sports', ['Soccer'])
  .gte('rank_score', 1000)
  .limit(10);
```

---

### Joins (Future)

```dart
final data = await supabase
  .from('posts')
  .select('*, author:users(display_name, photo_url)')
  .limit(20);
```

---

## ⚠️ Error Handling

### Common Errors

**Authentication Errors:**
```dart
try {
  await supabase.auth.signIn(...);
} catch (e) {
  if (e.toString().contains('Invalid login credentials')) {
    // Show error to user
  }
}
```

**Database Errors:**
```dart
try {
  await supabase.from('posts').insert(...);
} catch (e) {
  if (e.toString().contains('violates row-level security')) {
    // User not authorized
  }
}
```

**Network Errors:**
```dart
try {
  await supabase.from('users').select();
} on SocketException {
  // No internet connection
}
```

---

## 🔒 Security Best Practices

### 1. Never Expose Sensitive Data
```dart
// ❌ Bad
const apiKey = 'secret-key';

// ✅ Good
const apiKey = String.fromEnvironment('API_KEY');
```

### 2. Validate All Inputs
```dart
if (email.isEmpty || !isValidEmail(email)) {
  throw Exception('Invalid email');
}
```

### 3. Use RLS Policies
All tables have RLS enabled - users can only access authorized data.

### 4. Sanitize User Input
```dart
final sanitized = input.trim().replaceAll(RegExp(r'[<>]'), '');
```

---

## 📊 Rate Limits

Supabase Free Tier:
- **Database**: 500 MB
- **Storage**: 1 GB
- **Bandwidth**: 2 GB
- **API Requests**: Unlimited (with fair use)

Pro Tier (if needed):
- Higher limits
- Better performance
- Support included

---

## 🎯 Best Practices

1. **Use Pagination** - Don't fetch all data at once
2. **Cache Images** - Use CachedNetworkImage
3. **Handle Errors** - Try-catch all API calls
4. **Loading States** - Show loading indicators
5. **Debounce Search** - Wait 300ms before searching
6. **Use Streams** - For real-time data
7. **Optimize Queries** - Only select needed fields
8. **Index Properly** - Already done in schema

---

**API Version**: Supabase v2
**Last Updated**: October 2025
