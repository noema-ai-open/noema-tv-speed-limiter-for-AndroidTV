# Google Play / Android TV Release Guide

This file contains the submission data and technical checklist for NOEMA TV Speed Limiter.

## Release identity

- App name: `NOEMA TV Speed Limiter`
- Package: `ai.noema.tvspeed`
- Version name: `1.1.0`
- Version code: `9`
- Minimum SDK: `26`
- Target SDK: `35`
- Compile SDK: `37`
- Form factor: Android TV / Google TV only
- Primary category: Tools

## Distribution decision before first public release

Decide whether the app will be a paid download before the first production rollout.

Google Play allows a paid app to become free, but an app that has already been offered free cannot later be changed to a paid download under the same package name. A free app can still add Play Billing products later.

For the simplest direct monetization without adding billing code, set the app as **Paid** in Play Console before the first production release and configure the desired price there.

## Store listing

### Short description

Limit Android TV download speed to save data on mobile and metered networks.

### Full description

NOEMA TV Speed Limiter is a lightweight bandwidth-control utility built for Android TV and Google TV.

It is designed for mobile hotspots, LTE/5G routers, travel, hotels, camper connections, holiday apartments and other networks where data volume matters.

Choose a simple download profile:

- 2 Mbit/s — Saver
- 4 Mbit/s — Balanced
- 6 Mbit/s — Comfort
- Full Speed — unrestricted

The selected limit applies to aggregate download traffic on the TV. Upload remains unrestricted.

NOEMA uses Android's VpnService only as a local on-device traffic path so it can apply the selected bandwidth limit. It does not connect your traffic to a NOEMA VPN server, does not change your country, does not contain advertising or analytics, and does not sell or monetize browsing traffic.

The app is designed for TV remotes and D-pad navigation and includes local diagnostics for troubleshooting.

Privacy policy:
https://github.com/noema-ai-open/noema-tv-speed-limiter-for-AndroidTV/blob/main/PRIVACY.md

## Android TV assets required in Play Console

Before submitting for TV review:

1. Upload the Android App Bundle (`.aab`).
2. Add at least one real Android TV screenshot.
3. Add the required Android TV store banner / graphic in Play Console.
4. Mention `Android TV` in the store description.
5. Opt in to Android TV under the Play Console form-factor settings.

The app manifest already declares the Leanback launcher, TV-only distribution, landscape orientation and no touchscreen requirement.

## VpnService declaration

Play Console requires a VpnService declaration for every app containing `VpnService`.

Recommended answers for the current implementation:

### 1. Is providing a VPN the primary functionality of the app?

**No.**

### 2. Which permitted functionality applies?

**Network-related tools.**

Suggested explanation:

> NOEMA TV Speed Limiter is a network utility whose primary purpose is to apply a user-selected download bandwidth limit across apps on an Android TV device. Android VpnService is required to create a local TUN interface. Traffic is then passed locally to an on-device HEV tun2socks component and local SOCKS5 relay, where the rate limit is enforced before sockets use the device's normal physical network. There is no remote NOEMA VPN endpoint and the app does not change the user's public location.

### 3. VPN usage demonstration video

Provide a public or reviewer-accessible video, maximum 90 seconds, showing:

1. Opening NOEMA TV Speed Limiter on the TV.
2. Selecting a 2, 4 or 6 Mbit/s profile.
3. The in-app `VPN disclosure` dialog.
4. Choosing `Continue`.
5. Android's system VPN permission dialog.
6. Granting the VPN permission.
7. The app showing the limiter as active.
8. Selecting `Full Speed Home` to stop it.

### 4. Does the VPN service collect or share user data?

**No**, for the current implementation.

The app processes traffic locally to enforce the rate limit and does not transmit browsing content, diagnostics or traffic metadata to NOEMA AI.

### 5. Prominent disclosure video

The same short video can show the complete in-app disclosure if the full text is readable. It must also demonstrate both paths:

- user accepts and reaches Android's VPN permission screen;
- user cancels, then can trigger the disclosure again by selecting a limited profile.

### 5(a). Is traffic from other apps routed or manipulated for monetization purposes?

**No.**

The traffic is rate-limited to provide the utility selected by the user. It is not redirected, altered or inspected for advertising or monetization.

## Foreground Service declaration

The VPN runs as a user-visible foreground service while bandwidth limiting is active. The manifest uses `specialUse` because there is no dedicated foreground-service type for this local bandwidth-limiter use case.

Suggested function description:

> The foreground service keeps the user-selected device-wide bandwidth limiter active after the user leaves the NOEMA screen and opens a streaming app. The service maintains Android VpnService, the local TUN/tun2socks path and the local rate limiter. A persistent notification tells the user that limiting is active.

Suggested user impact if deferred:

> The selected bandwidth limit would not begin when the user requests it, so the streaming app opened immediately afterward could consume mobile data at unrestricted speed.

Suggested user impact if interrupted:

> The bandwidth limit would stop unexpectedly and traffic would return to unrestricted speed, which could consume a metered data allowance faster than the user intended.

Suggested use-case text:

> User-initiated, user-visible local network bandwidth control using Android VpnService. The user starts it by choosing a speed profile and can stop it at any time by selecting Full Speed Home. A persistent notification is shown while active.

Use the same TV demonstration video, ensuring it shows the user action that starts and stops the foreground service.

## Data Safety form

For the current codebase:

- Account required: No
- Ads: No
- Analytics: No
- Developer-operated telemetry: No
- Personal data collected by NOEMA AI: No
- Personal data shared by NOEMA AI: No
- Browsing history collected by NOEMA AI: No
- Diagnostics uploaded to NOEMA AI: No

The app normally uses DNS supplied by the active network. If none is available, the current code falls back to `1.1.1.1`; this is documented in `PRIVACY.md`.

Re-check these answers before every release if analytics, crash reporting, billing, remote services or telemetry are added.

## Privacy policy URL

Use the public policy page:

https://github.com/noema-ai-open/noema-tv-speed-limiter-for-AndroidTV/blob/main/PRIVACY.md

A dedicated privacy page on `noema-ai.de` can replace this URL later.

## Production signing

Never commit the upload keystore or passwords to GitHub.

The Gradle release build reads these environment variables when available:

- `NOEMA_KEYSTORE_FILE`
- `NOEMA_KEYSTORE_PASSWORD`
- `NOEMA_KEY_ALIAS`
- `NOEMA_KEY_PASSWORD`

If they are not present, `bundleRelease` builds an unsigned AAB for CI validation only.

Generate an upload keystore with `tools/create-upload-keystore.sh`, keep the resulting `.jks` file private, and back it up securely.

For GitHub Actions production signing, add the keystore as a base64-encoded repository secret named `NOEMA_UPLOAD_KEYSTORE_B64` and add these repository secrets:

- `NOEMA_KEYSTORE_PASSWORD`
- `NOEMA_KEY_ALIAS`
- `NOEMA_KEY_PASSWORD`

Do not store those values in repository files.

## 32-bit, 64-bit and 16 KB page-size compliance

Google TV requires TV apps submitted from 1 August 2026 to support both 32-bit and 64-bit architectures and 16 KB page sizes.

The project explicitly packages:

- `armeabi-v7a`
- `arm64-v8a`
- `x86`
- `x86_64`

The current `com.wgtunnel:hevtunnel:1.0.4` upstream build uses Android NDK r28 and declares all four ABIs. The CI workflow additionally extracts the AAB and verifies the ABI set and 16 KB ELF load alignment for 64-bit native libraries.

The Play Console remains the final authoritative compatibility check after upload.

## Submission checklist

- [ ] Google Play developer account active
- [ ] Payments profile configured if app will be paid
- [ ] App created with package `ai.noema.tvspeed`
- [ ] Decide Paid vs Free before first production release
- [ ] Play App Signing accepted
- [ ] Private upload key created and backed up
- [ ] Signed `app-release.aab` built
- [ ] AAB uploaded successfully
- [ ] Android TV screenshot uploaded
- [ ] Android TV banner / store graphic uploaded
- [ ] Android TV form factor enabled
- [ ] Store listing completed
- [ ] Privacy policy URL entered
- [ ] Data Safety form completed
- [ ] VpnService declaration completed
- [ ] VpnService disclosure / usage video uploaded
- [ ] Foreground Service `specialUse` declaration completed
- [ ] Foreground Service demo video uploaded
- [ ] Content rating questionnaire completed
- [ ] App access declaration completed (no login required)
- [ ] Countries / regions selected
- [ ] Pricing configured
- [ ] Internal test release passes
- [ ] Closed/open testing requirements completed if Play Console requires them for the developer account
- [ ] Production rollout submitted for review
