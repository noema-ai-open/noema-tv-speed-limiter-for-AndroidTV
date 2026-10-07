# Privacy Policy — Data Saver Android TV / NOEMA TV Data Limiter

Effective date: 7 October 2026

NOEMA TV Data Limiter is designed to work locally on the Android TV / Google TV device.

## Data collection during normal use

NOEMA TV Data Limiter does not require an account and does not include advertising, analytics, automatic remote telemetry or a NOEMA-operated VPN server.

During normal use, NOEMA AI does not receive browsing history, website content, app traffic contents, location, contacts, messages, photos, health information, financial information or other traffic content through the app.

## Why Android VpnService is used

The app uses Android's `VpnService` API only to create an on-device traffic path that allows the selected download bandwidth limit to be applied across apps on the TV.

Traffic path:

`App traffic -> Android VpnService TUN -> local HEV tun2socks -> local SOCKS5 relay -> device's physical network`

The TUN and SOCKS relay run locally on the device. Traffic is not sent through a remote NOEMA VPN endpoint. The app does not change the apparent country or public IP address for advertising, tracking or monetization.

The Google Play package is `ai.noema.tvspeed`, published by NOEMA AI. Earlier versions and the TV interface use the names NOEMA TV Speed Limiter or NOEMA TV Data Limiter.

The app does not require root access, Device Owner privileges, privileged system permissions, a modified operating system, a custom ROM, or an unlocked bootloader. It uses the standard Android VpnService API with Android's user permission dialog. It does not modify Android system files.

## Network data processed on the device

The VPN path handles packets from other apps. IP addresses, transport ports, TCP/UDP connection state and hostnames supplied in SOCKS requests are processed to connect to the original destinations. Payload bytes are temporarily buffered in memory for forwarding and download rate limiting. The app does not decrypt TLS connections, inspect content for advertising or profiling, or create packet-capture files or a browsing-history database.

This local processing can handle personal or sensitive content carried by other apps' traffic, including encrypted bytes. NOEMA AI does not receive that content. Original connections still leave the device for the internet services selected by those apps; local VPN processing is not an offline mode. There is no additional remote VPN tunnel, remote private network service or geographic VPN endpoint. The app does not add a separate layer of encryption to the original connections; encryption remains that of the originating app/protocol, such as HTTPS/TLS.

## DNS

The app normally uses DNS servers supplied by the active physical network. If the device does not expose a DNS server, the current implementation uses Cloudflare's `1.1.1.1` resolver as a fallback. In that fallback case, DNS queries are sent to Cloudflare rather than to a NOEMA AI server.

## Local settings, statistics and diagnostics

The app stores the selected limiter state and the user's acceptance of the VPN disclosure in Android local preferences on the device.

Usage statistics, recent-session history and built-in diagnostics are generated and stored locally for the app's own display and troubleshooting. They are not automatically transmitted to NOEMA AI.

Persistent statistics contain aggregate downloaded/uploaded byte counts, session count, time spent limiting, profile and session timestamps. The app retains at most twelve completed sessions. Active counters are periodically saved to recover interrupted statistics. Totals persist until **Reset statistics**, clearing Android app data or uninstalling. Older entries are replaced when the twelve-session history fills. There is no fixed time-based deletion of totals or settings. Android backup is disabled in the app manifest.

Diagnostics include DNS resolver addresses, the physical network's Android handle/status, local TUN/SOCKS status, device/build information, connection/packet counters and the latest error. Errors can contain destination IP addresses, ports or hostnames. The latest diagnostic error is kept in process memory, replaced by a new error and reset when a new limiter session begins or the process terminates. Some errors/status messages also go to Android's local system log; log retention is controlled by Android and is not a developer-defined fixed period. There is no app-managed destination/domain history or packet-content log.

The HEV configuration file in the app's private cache stores local interface addresses, MTU and loopback relay configuration, not forwarded packet contents. Android may clear cache files; the configuration is overwritten when the tunnel starts again.

## Support reports

The **Report problem** function prepares a troubleshooting report locally. Depending on the device and current session, it can contain information such as:

- app version and report time
- device manufacturer/model and Android/API version
- network state, DNS/TUN/HEV/SOCKS status
- TCP/UDP diagnostic counters and the latest detected networking error
- local usage totals/session summary relevant to troubleshooting

A latest networking error can include a destination address or hostname. Review the displayed report before sharing it. Clipboard copies are subject to Android's clipboard behavior and can be cleared by the user or operating system.

The report stays on the TV until the user explicitly chooses an action. NOEMA does not automatically upload support reports to NOEMA AI or to a support server.

If the user chooses **Send report**, Android opens a compatible email or sharing application and prepares the report for `support@noema-ai.de`. The selected external application then controls any actual transmission and may apply its own privacy policy. The user remains in control and can cancel before sending.

If the user chooses **Copy report**, Android copies the displayed report to the local clipboard. The user can then decide whether to provide it manually. A user may also send a photo or screenshot of the problem to the support address.

If no compatible email or sharing application is available, NOEMA falls back to copying the report locally rather than transmitting it automatically.

If a user voluntarily sends diagnostic information to NOEMA Support, NOEMA AI receives only the information the user chose to provide. Support correspondence may be retained as reasonably necessary to answer the request, maintain support history and diagnose recurring compatibility issues, subject to applicable law.

## Third-party software

The app uses the HEV tun2socks / WG Tunnel HEV binding as an on-device networking component. Third-party components are governed by their own licenses. Their inclusion does not give NOEMA AI access to user traffic.

## Children

The app is a networking utility and is not directed specifically at children. It does not create accounts or intentionally collect personal information from children.

## Changes

If the app's data handling or use of `VpnService` changes, this privacy policy will be updated before the changed behavior is released.

## Contact

Support: `support@noema-ai.de`

Website: https://noema-ai.de

Project: https://github.com/noema-ai-open/noema-tv-speed-limiter-for-AndroidTV
