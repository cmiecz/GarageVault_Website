-- GarageVault Signups Table Setup
-- Run this SQL in your Supabase SQL Editor

-- Create signups table for launch notification emails
CREATE TABLE IF NOT EXISTS signups (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    source TEXT DEFAULT 'website',
    user_agent TEXT,
    ip_address INET
);

-- Create index for faster email lookups
CREATE INDEX IF NOT EXISTS idx_signups_email ON signups(email);
CREATE INDEX IF NOT EXISTS idx_signups_created_at ON signups(created_at);

-- Enable Row Level Security
ALTER TABLE signups ENABLE ROW LEVEL SECURITY;

-- Create policy to allow inserts (for public signups)
CREATE POLICY "Allow public signup inserts" ON signups
    FOR INSERT WITH CHECK (true);

-- Create policy to allow reads for authenticated users (you can view signups)
CREATE POLICY "Allow authenticated reads" ON signups
    FOR SELECT USING (auth.role() = 'authenticated');

-- Create a function to notify you of new signups (optional)
CREATE OR REPLACE FUNCTION notify_new_signup()
RETURNS TRIGGER AS $$
BEGIN
    -- You can add email notification logic here later
    -- For now, we'll just log it
    RAISE NOTICE 'New signup: % at %', NEW.email, NEW.created_at;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the notification function
CREATE TRIGGER signup_notification_trigger
    AFTER INSERT ON signups
    FOR EACH ROW
    EXECUTE FUNCTION notify_new_signup();

-- Grant necessary permissions
GRANT INSERT ON signups TO anon;
GRANT SELECT ON signups TO authenticated;
