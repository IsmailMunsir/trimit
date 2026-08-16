import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../db/database_helper.dart';
import '../utils/password_utils.dart';

enum AuthStatus { unknown, loggedOut, loggedIn }

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  AuthStatus _status = AuthStatus.unknown;
  String? _lastError;

  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get lastError => _lastError;
  bool get isLoggedIn => _status == AuthStatus.loggedIn;

  /// Creates a new account. Returns true on success, false if the
  /// email is already registered (stores a message in lastError either way).
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final existing = await DatabaseHelper.instance.getUserByEmail(normalizedEmail);
    if (existing != null) {
      _lastError = 'An account with this email already exists.';
      notifyListeners();
      return false;
    }

    final newUser = User(
      id: const Uuid().v4(),
      name: name.trim(),
      email: normalizedEmail,
      passwordHash: PasswordUtils.hash(password),
      emailVerified: false,
    );

    await DatabaseHelper.instance.insertUser(newUser);

    _currentUser = newUser;
    _status = AuthStatus.loggedIn;
    _lastError = null;
    notifyListeners();
    return true;
  }

  /// Attempts login. Returns true on success, false on wrong email/password.
  Future<bool> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = await DatabaseHelper.instance.getUserByEmail(normalizedEmail);

    if (user == null || !PasswordUtils.verify(password, user.passwordHash)) {
      _lastError = 'Incorrect email or password.';
      notifyListeners();
      return false;
    }

    _currentUser = user;
    _status = AuthStatus.loggedIn;
    _lastError = null;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _status = AuthStatus.loggedOut;
    notifyListeners();
  }

  /// Resets a password directly, given a known email — used by the
  /// Reset Password screen after a (locally simulated) Forgot Password step.
  Future<bool> resetPassword({required String email, required String newPassword}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = await DatabaseHelper.instance.getUserByEmail(normalizedEmail);

    if (user == null) {
      _lastError = 'No account found with that email.';
      notifyListeners();
      return false;
    }

    final updated = user.copyWith(passwordHash: PasswordUtils.hash(newPassword));
    await DatabaseHelper.instance.updateUser(updated);

    if (_currentUser?.id == updated.id) {
      _currentUser = updated;
    }
    _lastError = null;
    notifyListeners();
    return true;
  }

  Future<void> updateProfile({required String name, required String email}) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(name: name.trim(), email: email.trim().toLowerCase());
    await DatabaseHelper.instance.updateUser(updated);
    _currentUser = updated;
    notifyListeners();
  }

  void markEmailVerified() {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(emailVerified: true);
    notifyListeners();
    // Note: in this local-only phase we don't persist emailVerified to the
    // database on every change to keep this step simple; Part C below wires
    // the verification screen, and we will persist it there.
  }
}