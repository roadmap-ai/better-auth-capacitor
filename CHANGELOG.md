# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Changed

- **BREAKING:** Session cookie and cached session data are now stored with `@aparajita/capacitor-secure-storage` (Keychain / Keystore) instead of `@capacitor/preferences`. Existing sessions are not migrated; users must sign in again.
- **BREAKING:** Capacitor peer dependencies now require `>=8.0.0 <9`.
- `@aparajita/capacitor-secure-storage` is a new required peer dependency. `@capacitor/preferences` is still required for `lastLoginMethodClient`.

## [0.1.0] - 2025-01-29

### Added

- Initial release
- `capacitorClient` plugin for Better Auth with offline-first authentication
- OAuth flow support with system browser integration
- `setupCapacitorFocusManager` for app focus tracking (session refresh)
- `setupCapacitorOnlineManager` for network connectivity monitoring
- `getCapacitorAuthToken` utility for extracting bearer tokens
- `lastLoginMethodClient` plugin for tracking last used login method
- Cookie persistence with `@capacitor/preferences`
- Automatic Bearer token injection for API requests
- Session caching for offline use
