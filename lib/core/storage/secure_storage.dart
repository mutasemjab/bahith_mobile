import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Thin wrapper around [FlutterSecureStorage] holding auth + locale state.
class SecureStorage {
  static const _tokenKey = 'token';
  static const _studentKey = 'student';
  static const _localeKey = 'locale';
  static const _deviceIdKey = 'device_id';
  static const _conductSignedKey = 'conduct_signed';
  static const _conductSignedStudentKey = 'conduct_signed_student_id';

  final FlutterSecureStorage _storage;
  final SharedPreferences _prefs;

  const SecureStorage(this._storage, this._prefs);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _safeRead(_tokenKey);

  Future<void> saveStudent(Map<String, dynamic> json) =>
      _storage.write(key: _studentKey, value: jsonEncode(json));

  Future<Map<String, dynamic>?> readStudent() async {
    final raw = await _safeRead(_studentKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLocale(String locale) =>
      _storage.write(key: _localeKey, value: locale);

  Future<String> readLocale() async => await _safeRead(_localeKey) ?? 'ar';

  Future<bool> hasToken() async => (await readToken()) != null;

  /// Caches the conduct gate for the currently signed student. Storing the
  /// student id beside the requested `conduct_signed` flag prevents a signed
  /// account from accidentally bypassing the gate for another account on the
  /// same device.
  bool isConductSignedFor(int studentId) =>
      _prefs.getBool(_conductSignedKey) == true &&
      _prefs.getInt(_conductSignedStudentKey) == studentId;

  Future<void> markConductSignedFor(int studentId) async {
    await _prefs.setInt(_conductSignedStudentKey, studentId);
    await _prefs.setBool(_conductSignedKey, true);
  }

  /// A random UUID generated once per install and kept forever after.
  ///
  /// Deliberately stored in plain [SharedPreferences] rather than
  /// [FlutterSecureStorage]: this value isn't a credential, and unlike the
  /// encrypted store it isn't tied to the Android Keystore entry for the
  /// app's current signing key — so it survives a debug/release signing
  /// change or an OS keystore reset instead of silently regenerating (which
  /// would desync it from what the backend has on file and lock the
  /// student out with a "different device" error). It's untouched by
  /// [clear] for the same reason logout must not reset it — only an actual
  /// uninstall should.
  Future<String> getOrCreateDeviceId() async {
    final existing = _prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = const Uuid().v4();
    await _prefs.setString(_deviceIdKey, generated);
    return generated;
  }

  /// Android ties `flutter_secure_storage`'s encryption key to the app's
  /// Keystore entry. If the app's signing identity changes across an
  /// install (a new debug/release key, a device restore, or the OS
  /// resetting its keystore) previously-written values become
  /// undecryptable and a plain `read` throws instead of returning null —
  /// which otherwise crashes the app before it can even reach the login
  /// screen. Treat that as "nothing stored" and wipe the now-orphaned data
  /// (every key shares the same cipher, so if one is unreadable the rest
  /// almost certainly are too) instead of surfacing the exception.
  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      await _storage.deleteAll();
      return null;
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _studentKey);
  }
}
