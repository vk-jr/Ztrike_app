-- Fix Row Level Security policies for users table
-- This allows users to create their own profile during signup

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
DROP POLICY IF EXISTS "Users can view all profiles" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Allow anyone to insert their own user profile (needed during signup)
CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT
  WITH CHECK (auth_id = auth.uid());

-- Allow all authenticated users to view all profiles (for social features)
CREATE POLICY "Users can view all profiles" ON users
  FOR SELECT
  USING (true);

-- Allow users to update only their own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE
  USING (auth_id = auth.uid())
  WITH CHECK (auth_id = auth.uid());

-- Allow users to delete own profile (optional)
CREATE POLICY "Users can delete own profile" ON users
  FOR DELETE
  USING (auth_id = auth.uid());
