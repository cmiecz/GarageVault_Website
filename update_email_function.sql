-- UPDATE ONLY THE EMAIL NOTIFICATION FUNCTION
-- Run this if you already have the signups table set up

-- Drop existing trigger and function (if they exist)
DROP TRIGGER IF EXISTS signup_notification_trigger ON signups;
DROP FUNCTION IF EXISTS notify_new_signup();

-- Create updated function with Resend API integration
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
    
    -- Use pg_net extension to send HTTP POST request
    -- Make sure pg_net extension is enabled in Database > Extensions
    PERFORM net.http_post(
        url := 'https://api.resend.com/emails',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer re_8MrgvSAw_JbhLX3CzjtP5ZZ63DnUSFjMH'
        ),
        body := jsonb_build_object(
            'from', 'GarageVault Signups <onboarding@resend.dev>',
            'to', ARRAY['support@garagevault.app'],
            'subject', '🚨 NEW SIGNUP - GarageVault Launch Notification',
            'html', '<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                <h2 style="color: #4a7c9e;">🎉 NEW SIGNUP RECEIVED!</h2>
                <div style="background: #f5f5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
                    <p style="margin: 10px 0;"><strong>Email:</strong> ' || NEW.email || '</p>
                    <p style="margin: 10px 0;"><strong>Source:</strong> ' || NEW.source || '</p>
                    <p style="margin: 10px 0;"><strong>Timestamp:</strong> ' || NEW.created_at || '</p>
                    <p style="margin: 10px 0;"><strong>User Agent:</strong> ' || COALESCE(NEW.user_agent, 'N/A') || '</p>
                </div>
                <p style="color: #666;">This person wants to be notified when GarageVault launches!</p>
                <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
                <p style="color: #999; font-size: 12px;">Sent automatically from GarageVault website</p>
            </div>'
        )
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate trigger to call the notification function
CREATE TRIGGER signup_notification_trigger
    AFTER INSERT ON signups
    FOR EACH ROW
    EXECUTE FUNCTION notify_new_signup();

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Email notification function updated successfully! Test by inserting a signup.';
END $$;
