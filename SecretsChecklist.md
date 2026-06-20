# Unio Secrets Checklist

Production secrets are never committed to this repository.

Before a release build, provide these files or environment values through CI secrets or local developer configuration:

- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_STORAGE_BUCKET`.
- Supabase Auth provider setup for Apple, Google, and GitHub if social sign-in is enabled.
- Supabase RLS policies and database tables for `profiles`, `posts`, `chats`, `messages`, and media metadata.
- For GitHub Actions IPA export: `IOS_CERT_P12_BASE64`, `IOS_CERT_PASSWORD`, `IOS_KEYCHAIN_PASSWORD`, `IOS_PROVISION_PROFILE_BASE64`, `IOS_PROVISION_PROFILE_NAME`, and `APPLE_TEAM_ID`.
- APNs Auth Key (`.p8`), Key ID, Team ID, and bundle ID for push notifications.
- `UNIO_API_BASE_URL`, `UNIO_WEBSOCKET_URL`, and `UNIO_AI_BASE_URL` for any external AI or service endpoints.
- App Group identifier used by App Intents handoff, if different from `group.app.unio`.
- WebRTC signaling endpoint and TURN/STUN credentials, supplied by the external backend.
- AI backend service token, stored only server-side.

Local setup:

1. Copy `.env.example` to `.env` and fill the local Supabase and endpoint values.
2. Keep real service keys, APNs keys, and signing assets out of git.
3. If you later re-enable the legacy Firebase adapters, supply `Config/GoogleService-Info.plist` separately; it is not required for the Supabase path.
