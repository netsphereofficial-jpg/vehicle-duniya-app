import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Local storage service using SharedPreferences
class StorageService {
  late final SharedPreferences _prefs;
  bool _initialized = false;

  /// Initialize the storage service
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    AppLogger.info('StorageService', 'Initialized');
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception('StorageService not initialized. Call initialize() first.');
    }
  }

  // Keys
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyUserId = 'user_id';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserName = 'user_name';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyLastSyncTime = 'last_sync_time';
  static const String _keyRecentSearches = 'recent_searches';

  // First Launch
  bool get isFirstLaunch {
    _ensureInitialized();
    return _prefs.getBool(_keyIsFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    _ensureInitialized();
    await _prefs.setBool(_keyIsFirstLaunch, false);
  }

  // User Info
  String? get userId {
    _ensureInitialized();
    return _prefs.getString(_keyUserId);
  }

  Future<void> setUserId(String? value) async {
    _ensureInitialized();
    if (value == null) {
      await _prefs.remove(_keyUserId);
    } else {
      await _prefs.setString(_keyUserId, value);
    }
  }

  String? get userPhone {
    _ensureInitialized();
    return _prefs.getString(_keyUserPhone);
  }

  Future<void> setUserPhone(String? value) async {
    _ensureInitialized();
    if (value == null) {
      await _prefs.remove(_keyUserPhone);
    } else {
      await _prefs.setString(_keyUserPhone, value);
    }
  }

  String? get userName {
    _ensureInitialized();
    return _prefs.getString(_keyUserName);
  }

  Future<void> setUserName(String? value) async {
    _ensureInitialized();
    if (value == null) {
      await _prefs.remove(_keyUserName);
    } else {
      await _prefs.setString(_keyUserName, value);
    }
  }

  // FCM Token
  String? get fcmToken {
    _ensureInitialized();
    return _prefs.getString(_keyFcmToken);
  }

  Future<void> setFcmToken(String? value) async {
    _ensureInitialized();
    if (value == null) {
      await _prefs.remove(_keyFcmToken);
    } else {
      await _prefs.setString(_keyFcmToken, value);
    }
  }

  // Theme Mode
  String get themeMode {
    _ensureInitialized();
    return _prefs.getString(_keyThemeMode) ?? 'light';
  }

  Future<void> setThemeMode(String value) async {
    _ensureInitialized();
    await _prefs.setString(_keyThemeMode, value);
  }

  // Notifications
  bool get notificationsEnabled {
    _ensureInitialized();
    return _prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _ensureInitialized();
    await _prefs.setBool(_keyNotificationsEnabled, value);
  }

  // Last Sync Time
  DateTime? get lastSyncTime {
    _ensureInitialized();
    final millis = _prefs.getInt(_keyLastSyncTime);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  Future<void> setLastSyncTime(DateTime value) async {
    _ensureInitialized();
    await _prefs.setInt(_keyLastSyncTime, value.millisecondsSinceEpoch);
  }

  // Recent Searches
  List<String> get recentSearches {
    _ensureInitialized();
    return _prefs.getStringList(_keyRecentSearches) ?? [];
  }

  Future<void> addRecentSearch(String search) async {
    _ensureInitialized();
    final searches = recentSearches;
    searches.remove(search); // Remove if exists
    searches.insert(0, search); // Add to beginning
    // Keep only last 10 searches
    final trimmed = searches.take(10).toList();
    await _prefs.setStringList(_keyRecentSearches, trimmed);
  }

  Future<void> clearRecentSearches() async {
    _ensureInitialized();
    await _prefs.remove(_keyRecentSearches);
  }

  // Generic methods
  Future<void> setString(String key, String value) async {
    _ensureInitialized();
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    _ensureInitialized();
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    _ensureInitialized();
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    _ensureInitialized();
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    _ensureInitialized();
    return _prefs.getInt(key);
  }

  Future<void> remove(String key) async {
    _ensureInitialized();
    await _prefs.remove(key);
  }

  /// Clear all user data on logout
  Future<void> clearUserData() async {
    _ensureInitialized();
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserPhone);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyFcmToken);
    await _prefs.remove(_keyRecentSearches);
    AppLogger.info('StorageService', 'User data cleared');
  }

  /// Clear all data
  Future<void> clearAll() async {
    _ensureInitialized();
    await _prefs.clear();
    AppLogger.info('StorageService', 'All data cleared');
  }
}
