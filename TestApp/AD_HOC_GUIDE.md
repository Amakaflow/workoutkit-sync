# Ad Hoc Distribution Guide (Free Alternative to TestFlight)

## Why Ad Hoc?

- ✅ **No paid Apple Developer Program needed** (free account works)
- ✅ Can install on up to 100 registered devices
- ✅ Works wirelessly after initial setup (if you use a service)
- ⚠️ Requires USB connection for initial setup
- ⚠️ App expires after 7 days (free account) or 1 year (paid account)
- ⚠️ Need to rebuild/re-sign when expired

## Prerequisites

1. **Free Apple Developer Account**
   - Sign in at: https://developer.apple.com
   - No payment required

2. **Register Device UDID**
   - You'll need your device's UDID
   - Register it in your developer account

## Step 1: Get Your Device UDID

### On iPhone:
1. Connect iPhone to Mac via USB
2. Open **Finder** (or iTunes on older macOS)
3. Click on your iPhone
4. Click on the device name/identifier
5. UDID will appear (long string of letters/numbers)
6. Copy it

### Or via Terminal:
```bash
# Connect iPhone and run:
system_profiler SPUSBDataType | grep -A 11 iPhone
```

### Or via Xcode:
1. Connect iPhone
2. Open Xcode → **Window** → **Devices and Simulators**
3. Select your iPhone
4. Copy the **Identifier** (this is your UDID)

## Step 2: Register Device in Apple Developer

1. Go to https://developer.apple.com/account/resources/devices/list
2. Sign in with your Apple ID
3. Click **+** to add device
4. Fill in:
   - **Name**: My iPhone (or any name)
   - **UDID**: Paste your UDID
   - **Platform**: iOS
5. Click **Continue** → **Register**

## Step 3: Build and Archive in Xcode

1. Open your Xcode project
2. Select your target
3. **Signing & Capabilities**:
   - Select your **Team** (free account works)
   - **Bundle Identifier**: Your unique ID (e.g., `com.yourname.workoutkitsync`)
4. **Product** → **Archive**
5. Wait for archive to complete

## Step 4: Export for Ad Hoc Distribution

1. **Window** → **Organizer** (or Shift+Cmd+O)
2. Select your archive
3. Click **Distribute App**
4. Choose **Ad Hoc**
5. Click **Next**
6. Select **Automatically manage signing** (or manually select)
7. Click **Next**
8. Review and click **Export**
9. Choose a location to save
10. Click **Export**

This creates an `.ipa` file.

## Step 5: Install on Your iPhone

### Option A: Via Finder (macOS Catalina+)

1. Connect iPhone via USB
2. Open **Finder**
3. Select your iPhone in sidebar
4. Drag the `.ipa` file to the Finder window
5. Wait for installation

### Option B: Via Xcode

1. Connect iPhone via USB
2. Open Xcode → **Window** → **Devices and Simulators**
3. Select your iPhone
4. Click **+** under **Installed Apps**
5. Select your `.ipa` file
6. Wait for installation

### Option C: Via Third-Party Tool

- **AltStore** (free, wireless installation)
- **3uTools** (free, requires USB)
- **Sideloadly** (free, requires USB)

## Step 6: Use Your App

1. Find the app on your iPhone home screen
2. Open it
3. Upload workouts as needed

## Updating the App

When the app expires (7 days for free account) or you make changes:

1. Make changes in Xcode
2. **Product** → **Archive**
3. **Distribute App** → **Ad Hoc** → **Export**
4. Install the new `.ipa` file

## Limitations

- ⚠️ **App expires after 7 days** (free account) or 1 year (paid account)
- ⚠️ **Need to rebuild** when expired
- ⚠️ **Maximum 100 devices** can be registered
- ⚠️ **USB connection** typically needed for installation (unless using AltStore)

## Alternative: AltStore (Wireless Installation)

AltStore allows wireless installation without a paid Developer account:

1. Install AltStore on your Mac: https://altstore.io
2. Install AltServer on your iPhone
3. Upload your `.ipa` to AltStore
4. Install wirelessly on your iPhone
5. Still expires after 7 days, but easier to reinstall

## Comparison: TestFlight vs Ad Hoc

| Feature | TestFlight | Ad Hoc |
|---------|------------|--------|
| Cost | $99/year | Free |
| App Expiration | No expiration | 7 days (free) or 1 year (paid) |
| Installation | Wireless via TestFlight app | USB or AltStore |
| Updates | Easy, automatic | Manual rebuild |
| Device Limit | Unlimited | 100 devices |
| Best For | Regular use, multiple devices | Personal use, occasional updates |

## Recommendation

- **For regular use**: Consider TestFlight (worth the $99/year)
- **For occasional use**: Ad Hoc distribution works fine
- **For personal use only**: Ad Hoc is perfect

Choose based on your needs! 🚀
