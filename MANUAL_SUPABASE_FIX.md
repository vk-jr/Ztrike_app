# Manual Supabase Fix for Signup Issues

## Problem
Getting 401 Unauthorized error when signing up users.

## Solution
You need to **disable email confirmation** in Supabase Dashboard.

### Steps to Fix:

1. **Go to Supabase Dashboard**
   - Open: https://supabase.com/dashboard
   - Select your project: `xpxvezrjqfgxqghehwnr`

2. **Navigate to Authentication Settings**
   - Click **"Authentication"** in left sidebar
   - Click **"Providers"** tab
   - Scroll to **"Email"** section

3. **Disable Email Confirmation**
   - Find **"Enable email confirmations"** toggle
   - **Turn it OFF** (disable it)
   - Click **"Save"**

4. **Alternative: Configure Email Confirmation URL**
   If you want to keep email confirmation ON:
   - Set **"Site URL"** to: `http://localhost:8080`
   - Set **"Redirect URLs"** to include: `http://localhost:8080/**`

## Why This Fixes It

When email confirmation is enabled:
- Users are NOT authenticated immediately after signup
- They can't insert into the `users` table until email is confirmed
- This causes the 401 error

When email confirmation is disabled:
- Users are authenticated immediately
- They can insert their profile right away
- Signup works smoothly

## Already Applied Fixes

✅ RLS policies updated to allow profile creation
✅ Code updated to handle session delays
✅ Error handling added to auth service

## Test After Fix

1. Refresh your Flutter app
2. Try signing up with a new email
3. Should work without 401 error!

## If Still Not Working

Run this SQL in Supabase SQL Editor:

```sql
-- Completely open insert policy for testing
DROP POLICY IF EXISTS "Allow profile creation during signup" ON users;

CREATE POLICY "Allow profile creation during signup" ON users
  FOR INSERT
  WITH CHECK (true);
```

This will allow ANY authenticated user to insert profiles (for testing).

