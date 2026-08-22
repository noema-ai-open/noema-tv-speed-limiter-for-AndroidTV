# Privacy Policy — NOEMA TV Speed Limiter

Effective date: 22 August 2026

NOEMA TV Speed Limiter is designed to work locally on the Android TV / Google TV device.

## Data collection

NOEMA TV Speed Limiter does not require an account and does not include advertising, analytics, remote telemetry or a NOEMA-operated VPN server.

NOEMA AI does not collect, store, sell or share browsing history, website content, app traffic contents, device identifiers, location, contacts, messages, photos, health information, financial information or other personal data through the app.

## Why Android VpnService is used

The app uses Android's `VpnService` API only to create an on-device traffic path that allows the selected download bandwidth limit to be applied across apps on the TV.

Traffic path:

`App traffic -> Android VpnService TUN -> local HEV tun2socks -> local SOCKS5 relay -> device's physical network`

The TUN and SOCKS relay run locally on the device. Traffic is not sent through a remote NOEMA VPN endpoint. The app does not change the apparent country or public IP address for the purpose of advertising, tracking or monetization.

## DNS

The app normally uses DNS servers supplied by the active physical network. If the device does not expose a DNS server, the current implementation uses `1.1.1.1` as a fallback resolver. This fallback is not operated by NOEMA AI.

## Local diagnostics and settings

The app keeps the selected limiter state and the user's acceptance of the VPN disclosure in Android local preferences on the device.

Session traffic counters and the built-in diagnostics are generated locally for troubleshooting. NOEMA TV Speed Limiter does not upload those diagnostics to NOEMA AI.

## Third-party software

The app uses the HEV tun2socks / WG Tunnel HEV binding as an on-device networking component. Third-party components are governed by their own licenses. Their inclusion does not give NOEMA AI access to user traffic.

## Children

The app is a networking utility and is not directed specifically at children. It does not create accounts or intentionally collect personal information from children.

## Changes

If the app's data handling or use of `VpnService` changes, this privacy policy will be updated before the changed behavior is released.

## Contact

Project and support information:

https://noema-ai.de

https://github.com/noema-ai-open/noema-tv-speed-limiter-for-AndroidTV
