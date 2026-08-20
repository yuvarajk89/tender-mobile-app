# Feature · Auth

**Login and session.** In mock mode any non-empty credentials sign in.

## Screen
- **Login** — branded full-bleed screen; email + password; "Sign in".

## Files
- `features/auth/presentation/login_page.dart`
- `features/auth/presentation/auth_providers.dart` — `AuthController` (StateNotifier) +
  `AuthState { isAuthenticated, userName }`.

## Behaviour
- `login()` sets `isAuthenticated = true`; the router redirect then allows `/home`.
- Logout clears the state (wire a button when needed).

## Going live
Replace `AuthController.login` with a call to the MeghaOS JWT login endpoint; store the
token; expose it to the HTTP client. State shape stays the same. See
[../05-DATA-LAYER.md](../05-DATA-LAYER.md).
