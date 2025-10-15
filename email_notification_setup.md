# Email Notification Setup for GarageVault Signups

## 🎯 Goal
Get email notifications at support@garagevault.app when someone signs up for launch notifications.

## ✅ Easiest Solution: Use Make.com (Formerly Integromat)

### Step 1: Create Make.com Account
1. Go to https://www.make.com
2. Sign up for free account
3. Create a new scenario

### Step 2: Set up Supabase Webhook
1. In Make.com, add a "Webhooks" module (trigger)
2. Choose "Custom webhook"
3. Copy the webhook URL

### Step 3: Add Supabase Webhook
In your Supabase dashboard:
```sql
-- Create webhook function
CREATE OR REPLACE FUNCTION notify_new_signup()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM net.http_post(
        url := 'YOUR_MAKE_WEBHOOK_URL_HERE',
        headers := '{"Content-Type": "application/json"}'::jsonb,
        body := jsonb_build_object(
            'email', NEW.email,
            'source', NEW.source,
            'created_at', NEW.created_at,
            'user_agent', NEW.user_agent
        )
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Step 4: In Make.com
1. Add "Email" module after webhook
2. Configure:
   - To: support@garagevault.app
   - Subject: 🚨 NEW SIGNUP - GarageVault
   - Body: Use webhook data

## 🚀 Alternative: Use Resend API

### Step 1: Get Resend API Key
1. Go to https://resend.com
2. Sign up (Free tier: 100 emails/day)
3. Get API key from dashboard
4. Verify your domain (garagevault.app) or use their test domain

### Step 2: Enable pg_net in Supabase
1. Supabase Dashboard → Database → Extensions
2. Enable "pg_net"

### Step 3: Run Updated SQL
Use the `supabase_setup.sql` file and replace:
- `YOUR_RESEND_API_KEY_HERE` with your actual key

### Step 4: Test
1. Submit a test email on your website
2. Check support@garagevault.app for notification

## 📊 Viewing Signups Manually

You can always view signups in Supabase:
1. Go to Table Editor
2. Click "signups" table
3. See all email submissions with timestamps

## 🔔 Simplest Method: Supabase Dashboard Notifications

Alternative: Just check your Supabase dashboard regularly:
- Table Editor → signups
- You'll see all new signups with timestamps
- Export to CSV if needed
