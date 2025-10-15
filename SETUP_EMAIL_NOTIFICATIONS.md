# 🚀 Email Notification Setup - READY TO GO!

Your Resend API key has been configured! Follow these steps to activate email notifications.

## ✅ Step 1: Enable pg_net Extension in Supabase

1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Select your project
3. Navigate to: **Database** → **Extensions**
4. Search for **"pg_net"**
5. Click **Enable** on the pg_net extension
6. Wait for it to activate (takes ~10 seconds)

## ✅ Step 2: Run the Updated SQL Function

1. In Supabase Dashboard, go to: **SQL Editor**
2. Click **"New Query"**
3. Copy and paste the ENTIRE contents of `supabase_setup.sql`
4. Click **Run** (or press Cmd/Ctrl + Enter)
5. You should see: "Success. No rows returned"

**Note:** If you already ran the SQL before, you'll need to drop and recreate the trigger:

```sql
-- Drop existing trigger and function
DROP TRIGGER IF EXISTS signup_notification_trigger ON signups;
DROP FUNCTION IF EXISTS notify_new_signup();

-- Then run the full supabase_setup.sql contents
```

## ✅ Step 3: Test It!

1. Go to your website: https://garagevault.app
2. Enter a test email (use your own email)
3. Click "Get Notified"
4. Check **support@garagevault.app** for the notification email!

## 📧 What You'll Receive

When someone signs up, you'll get an email at **support@garagevault.app** with:
- **Subject:** 🚨 NEW SIGNUP - GarageVault Launch Notification
- **From:** GarageVault Signups <onboarding@resend.dev>
- **Content:**
  - User's email address
  - Form source (hero-form or bottom-form)
  - Timestamp of signup
  - Nice formatted HTML

## 🔧 Troubleshooting

### If emails aren't sending:

1. **Check pg_net is enabled:**
   - Supabase → Database → Extensions → pg_net should show "Enabled"

2. **Check Resend API key is valid:**
   - Go to https://resend.com/api-keys
   - Make sure `re_8MrgvSAw_JbhLX3CzjtP5ZZ63DnUSFjMH` is active

3. **Check trigger is active:**
   ```sql
   SELECT * FROM pg_trigger WHERE tgname = 'signup_notification_trigger';
   ```

4. **Test the function manually:**
   ```sql
   INSERT INTO signups (email, source) VALUES ('test@example.com', 'manual-test');
   ```

5. **Check Resend logs:**
   - Go to https://resend.com/emails
   - See if emails are being sent

### Common Issues:

- **pg_net not enabled:** Enable it in Database → Extensions
- **API key invalid:** Double-check your Resend API key
- **Email not verified:** Resend requires email verification (check your Resend dashboard)

## 🎯 Current Configuration

- **API Key:** `re_8MrgvSAw_JbhLX3CzjtP5ZZ63DnUSFjMH`
- **From Email:** `GarageVault Signups <onboarding@resend.dev>`
- **To Email:** `support@garagevault.app`
- **Trigger:** Automatically fires on every new signup

## 📊 Alternative: View Signups in Dashboard

You can always view signups manually:
1. Supabase Dashboard → **Table Editor**
2. Click **signups** table
3. See all submissions with timestamps

## ✨ You're All Set!

Once you complete Steps 1 & 2 above, you'll automatically receive email notifications for every signup! 🎉
