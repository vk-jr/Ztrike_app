# Database Credentials Information

## Current Setup

Your Supabase credentials are currently stored in:
**`lib/core/constants/supabase_constants.dart`**

```dart
class SupabaseConstants {
  static const String supabaseUrl = 'https://xpxvezrjqfgxqghehwnr.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
}
```

## Why No .env File?

Flutter **web** doesn't natively support `.env` files like Node.js does. The credentials need to be compiled into the app.

## Options for Managing Credentials

### Option 1: Current Approach (Hardcoded)
✅ **Pros:** Simple, works out of the box
❌ **Cons:** Credentials visible in source code

**Good for:** Development, demos, learning

### Option 2: Environment Variables (Build Time)
Use `--dart-define` flags:

```bash
flutter build web --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_KEY=...
```

Then access in code:
```dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
```

✅ **Pros:** Keeps secrets out of source code
❌ **Cons:** More complex build process

**Good for:** Production deployments

### Option 3: Config File + .gitignore
Create a separate config file and add it to `.gitignore`:

```dart
// lib/core/constants/supabase_config_secret.dart (add to .gitignore)
class SupabaseConfig {
  static const String url = 'https://...';
  static const String key = '...';
}
```

✅ **Pros:** Keeps secrets out of git
❌ **Cons:** Need to manage file separately

**Good for:** Team development

## Current Database Credentials

**Supabase Project URL:** `https://xpxvezrjqfgxqghehwnr.supabase.co`

**Anon Key:** 
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhweHZlenJqcWZneHFnaGVod25yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyOTkwNTQsImV4cCI6MjA3NDg3NTA1NH0.o1MOlFJojXtZx4VcZ9mv_RddmBqou3pj0c5JSpAwpsY
```

## Security Notes

⚠️ **The anon key is PUBLIC** - it's meant to be in client-side code
🔒 **Row Level Security (RLS)** protects your data, not the anon key
✅ **Service role key** (if you have one) should NEVER be in client code

## What Was Fixed

The signup error was **not** a credentials issue. It was a **Row Level Security (RLS) policy** issue.

**Fixed:** Updated RLS policies to allow users to insert their own profile during signup.

## Need to Change Credentials?

If you need different credentials:

1. **Get them from Supabase Dashboard:**
   - Go to https://supabase.com/dashboard
   - Select your project
   - Go to Settings > API
   - Copy URL and anon key

2. **Update the file:**
   - Edit `lib/core/constants/supabase_constants.dart`
   - Replace the URL and key
   - Run `flutter pub get`
   - Restart the app

## Summary

✅ Your credentials are already configured and working
✅ The signup error was fixed by updating RLS policies
✅ You can now sign up successfully
✅ No .env file is needed for Flutter web
