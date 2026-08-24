import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal auth state for the mock. In the live app this is backed by the
/// MeghaOS JWT login (see docs/05-DATA-LAYER.md); here any non-empty
/// credentials sign in, so the client can walk the flow without a backend.
class AuthState {
  const AuthState({this.isAuthenticated = false, this.userName = ''});
  final bool isAuthenticated;
  final String userName;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  /// Hardcoded internal-preview credentials (test build only): admin / 1234.
  /// Replace with the real MeghaOS JWT login when going live (see
  /// docs/05-DATA-LAYER.md).
  static const String testUser = 'admin';
  static const String testPassword = '1234';

  /// Returns true on success, false on bad credentials.
  Future<bool> login(String user, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final ok = user.trim() == testUser && password == testPassword;
    if (ok) {
      state = const AuthState(isAuthenticated: true, userName: 'Admin');
    }
    return ok;
  }

  /// Demo Google sign-in (UI only for now). In the live app this runs the real
  /// Google OAuth → MeghaOS session. Here it just signs in so the flow works.
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 600));
    state = const AuthState(isAuthenticated: true, userName: 'Buyer');
  }

  void logout() => state = const AuthState();
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});
