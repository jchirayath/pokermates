-- Migration: Create User Profiles System
-- Created: 2025-11-29 06:56:17
-- Description: Creates user profiles table with comprehensive member information

-- =====================================================
-- PART 1: EXTENSIONS
-- =====================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- PART 2: TABLES
-- =====================================================
CREATE TABLE user_profiles (
    -- Primary Key (links to auth.users)
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Basic Information
    full_name TEXT NOT NULL,
    username TEXT UNIQUE,
    bio TEXT,
    
    -- Profile Picture
    avatar_url TEXT,
    
    -- Contact Information
    phone_number TEXT,
    
    -- Address Information
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    
    -- Preferences
    preferred_game_type TEXT,
    skill_level TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- =====================================================
-- PART 3: INDEXES
-- =====================================================
CREATE INDEX idx_user_profiles_username ON user_profiles(username);
CREATE INDEX idx_user_profiles_created_at ON user_profiles(created_at);

-- =====================================================
-- PART 4: ROW LEVEL SECURITY (RLS)
-- =====================================================
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Users can view all profiles
CREATE POLICY "Users can view all profiles"
    ON user_profiles FOR SELECT
    TO authenticated
    USING (true);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile"
    ON user_profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON user_profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Users can delete their own profile
CREATE POLICY "Users can delete own profile"
    ON user_profiles FOR DELETE
    TO authenticated
    USING (auth.uid() = id);

-- =====================================================
-- PART 5: FUNCTIONS
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- PART 6: TRIGGERS
-- =====================================================
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- PART 7: MOCK DATA
-- =====================================================
-- Note: Mock data will be created when users sign up
-- The profile creation will happen automatically via the app