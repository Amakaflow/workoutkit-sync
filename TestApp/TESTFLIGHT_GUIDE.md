# TestFlight Deployment Guide

## Why TestFlight?

- ✅ Install on any device (iPhone, iPad, Watch) without USB
- ✅ Easy updates - just re-upload new version
- ✅ Works wirelessly after initial setup
- ✅ No need to open Xcode every time
- ✅ Can share with others if needed

## Prerequisites

### ⚠️ Important: Apple Developer Program Membership Required

**You need a paid Apple Developer Program membership ($99/year) for TestFlight.**

- **Free Apple Developer Account** (just signing in) is NOT enough
- **TestFlight requires Apple Developer Program membership** ($99/year)
- If you get redirected to `developer.apple.com/programs/` when trying to access App Store Connect, you need to enroll first

### Option 1: Enroll in Apple Developer Program

1. Go to https://developer.apple.com/programs/
2. Click **Enroll** (or **Start Your Enrollment**)
3. Complete the enrollment process ($99/year)
4. Wait for approval (usually 24-48 hours)
5. Once approved, you can access App Store Connect

### Option 2: Alternative - Ad Hoc Distribution (No Paid Membership)

If you don't want to pay $99/year, you can use **Ad Hoc Distribution** instead:

- ✅ Works with free Apple Developer account
- ✅ Can install on up to 100 devices (registered UDIDs)
- ⚠️ Requires USB connection for installation
- ⚠️ Need to re-sign app when it expires (7 days for free accounts, 1 year for paid)

See `AD_HOC_GUIDE.md` for instructions on this method.

### Option 3: Direct Installation (Development Build)

For personal use, you can build and install directly:

- ✅ No paid membership needed
- ✅ Works with free Apple Developer account
- ⚠️ App expires after 7 days (free account) or 1 year (paid account)
- ⚠️ Requires USB connection
- ⚠️ Need to rebuild/reinstall when expired

See `HOW_TO_TEST.md` for this method.

## Step 1: Verify Apple Developer Program Access

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Sign in with your Apple ID

**If you get redirected to `developer.apple.com/programs/`:**
- You need to enroll in the Apple Developer Program first
- Go to https://developer.apple.com/programs/enroll/
- Complete enrollment ($99/year)
- Wait for approval

**If you can access App Store Connect:**
- Continue to Step 2

## Step 2: Create App in App Store Connect

Before you can create the app record you need a **Bundle ID**. If you do not already have one:

1. Go to the [Identifiers](https://developer.apple.com/account/resources/identifiers/list) page in the Apple Developer portal.
2. Click the **+** button → choose **App IDs** → **App** → **Continue**.
3. Enter a **Description** (e.g. `WorkoutKitSync`).
4. Choose **Explicit** for Bundle ID and enter a reverse‑DNS string such as `com.yourname.workoutkitsync`.  
   Use something unique (usually your domain backwards plus the app name).
5. Leave capabilities at defaults (you can add more later).
6. Click **Continue** → **Register**.

Now the Bundle ID will appear in the dropdown inside App Store Connect.

1. In App Store Connect, click **My Apps** → **+** → **New App**
2. Fill in:
   - **Platform**: iOS
   - **Name**: WorkoutKitSync (or your name)
   - **Primary Language**: English
   - **Bundle ID**: Select the explicit ID you just registered (e.g., `com.yourname.workoutkitsync`)
   - **SKU**: Enter any unique string you will recognize (for example `WKSYNC001` or `2024-WorkoutKitSync`). This is internal only.
3. Click **Create**

## Step 3: Build Your App in Xcode

1. Open your Xcode project (from HOW_TO_TEST.md setup)
2. In Xcode, select your target
3. **Signing & Capabilities**:
   - Select your **Team** (your Apple ID)
   - **Bundle Identifier**: Must match App Store Connect (e.g., `com.yourname.workoutkitsync`)
4. **Product** → **Archive**
5. Wait for archive to complete

## Step 4: Upload to App Store Connect

1. **Window** → **Organizer** (or Shift+Cmd+O)
2. Select your archive
3. Click **Distribute App**
4. Choose **App Store Connect**
5. Click **Next**
6. Choose **Upload**
7. Click **Next**
8. Select your distribution options
9. Click **Upload**
10. Wait for upload to complete

## Step 5: Add to TestFlight

1. Go back to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Click **TestFlight** tab
4. Wait for processing (can take 10-30 minutes)
5. Once processed, your build will appear

## Step 6: Install TestFlight App

1. On your iPhone, open **App Store**
2. Search for **TestFlight**
3. Install the **TestFlight** app (free, by Apple)

## Step 7: Add Yourself as Tester

1. In App Store Connect, go to **TestFlight** tab
2. Click **Internal Testing** (or **External Testing**)
3. Click **+** to add testers
4. Add your email address
5. Click **Add**

## Step 8: Install Your App

1. On your iPhone, open **TestFlight** app
2. You should see an invitation email, or
3. Tap **Accept** on the invitation
4. Your app will appear in TestFlight
5. Tap **Install**

## Step 9: Use Your App

1. Find your app on your iPhone home screen
2. Open it
3. Upload workouts as needed
4. No Xcode needed! 🎉

## Updating Your App

When you want to update:

1. Make changes in Xcode
2. **Product** → **Archive**
3. **Distribute App** → **App Store Connect** → **Upload**
4. Wait for processing in App Store Connect
5. TestFlight will notify you of update
6. Tap **Update** in TestFlight app

That's it! No USB cable needed after initial setup.

## Troubleshooting

### "No builds available"
- Wait for processing (can take 30+ minutes)
- Check that upload completed successfully

### "Invitation not received"
- Check spam folder
- Add yourself manually in TestFlight section

### "App won't install"
- Make sure TestFlight app is installed
- Check that you accepted the invitation
- Try deleting and reinstalling from TestFlight

## Benefits Summary

✅ **No Xcode needed** after initial setup  
✅ **No USB cable** needed  
✅ **Works on any device** you add  
✅ **Easy updates** - just re-upload  
✅ **Wireless installation**  

Perfect for regular use! 🚀
