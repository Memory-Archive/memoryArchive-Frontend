import 'package:flutter/foundation.dart';
import 'package:smart_memories/core/storage/token_storage.dart';

enum SessionStatus {
  /// App just started; the splash screen is still checking.
  unknown,
  authenticated,
  unauthenticated,
}

/// The single source of truth for "is someone logged in?".
///
/// The router listens to it (refreshListenable), so changing the status is
/// all it takes to move the user between the auth screens and the app.
class SessionHelper extends ChangeNotifier {
  SessionHelper(this._tokens);

  final TokenStorage _tokens;

  SessionStatus _status = SessionStatus.unknown;
  SessionStatus get status => _status;

  Future<bool> hasStoredSession() => _tokens.hasSession();

  void markAuthenticated() => _set(SessionStatus.authenticated);

  /// Clears the tokens and sends the user to the login screen. Called on
  /// logout and by the auth interceptor when a token refresh fails.
  Future<void> end() async {
    await _tokens.clear();
    _set(SessionStatus.unauthenticated);
  }

  void _set(SessionStatus value) {
    if (_status == value) return;
    _status = value;
    notifyListeners();
  }
}
