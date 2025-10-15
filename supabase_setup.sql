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

-- Create a function to notify you of new signups via HTTP webhook
CREATE OR REPLACE FUNCTION notify_new_signup()
RETURNS TRIGGER AS $$
DECLARE
    payload json;
BEGIN
    -- Create JSON payload with signup details
    payload := json_build_object(
        'email', NEW.email,
        'source', NEW.source,
        'created_at', NEW.created_at,
        'user_agent', NEW.user_agent,
        'notification_email', 'support@garagevault.app'
    );
    
    -- Use pg_net extension to send HTTP POST request (if available)
    -- This requires the pg_net extension to be enabled in Supabase
    -- Go to Database > Extensions and enable "pg_net"
    PERFORM net.http_post(
        url := 'https://api.resend.com/emails',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer YOUR_RESEND_API_KEY_HERE'
        ),
        body := jsonb_build_object(
            'from', 'GarageVault <onboarding@resend.dev>',
            'to', ARRAY['support@garagevault.app'],
            'subject', '🚨 NEW SIGNUP - GarageVault Launch Notification',
            'html', '<h2>🎉 NEW SIGNUP RECEIVED!</h2><p><strong>Email:</strong> ' || NEW.email || '</p><p><strong>Source:</strong> ' || NEW.source || '</p><p><strong>Timestamp:</strong> ' || NEW.created_at || '</p><p>This person wants to be notified when GarageVault launches!</p>'
        )
    );
    
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
