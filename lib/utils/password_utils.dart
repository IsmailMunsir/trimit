import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Turns a plain-text password into a one-way hash for storage.
/// The real password is never saved anywhere — only this hash.
/// To check a login attempt, we hash the entered password the same way
/// and compare the two hashes.
class PasswordUtils {
  static String hash(String plainPassword) {
    final bytes = utf8.encode(plainPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verify(String plainPassword, String storedHash) {
    return hash(plainPassword) == storedHash;
  }

  /// Simple strength check used to power the password-strength indicator
  /// on the Create Account screen. Returns a score from 0 (weak) to 4 (strong).
  static int strengthScore(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score;
  }
}