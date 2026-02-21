import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'shared_pref_variable.dart';

class SharedPreferenceLogic {
  static SharedPreferences? _preferences;

  /// Initialize SharedPreferences instance
  static Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> _ensurePrefs() async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  static String getAppDirectoryPath() {
    // returns the path to the app directory
    return getAppDirectoryPath();
  }

  /// Check login status
  static bool isLogIn() {
    bool? isLogIn = _preferences?.getBool(AppSharedPreference.isLogin);
    if (isLogIn == null) {
      _preferences?.setBool(AppSharedPreference.isLogin, false);
      return false;
    } else {
      return isLogIn;
    }
  }

  /// Set login status to false
  static void setLoginFalse() {
    _preferences?.setBool(AppSharedPreference.isLogin, false);
  }

  /// Set login status to true
  static void setLoginTrue() {
    _preferences?.setBool(AppSharedPreference.isLogin, true);
  }

  /// Check if it's a fresh install
  static bool isFreshInstall() {
    bool? isFreshInstall = _preferences?.getBool(
      AppSharedPreference.firstInstall,
    );

    if (isFreshInstall == null || isFreshInstall) {
      _preferences?.setBool(AppSharedPreference.firstInstall, false);
      return true;
    } else {
      return false;
    }
  }

  /// Check if the user can watch a video
  static bool canWatchVideo() {
    int? counter = _preferences?.getInt(AppSharedPreference.checkCounter);
    return counter == null || counter <= 3;
  }

  /// Increase the video watch counter
  static void increaseWatchVideoCounter() {
    int? counter = _preferences?.getInt(AppSharedPreference.checkCounter);
    _preferences?.setInt(AppSharedPreference.checkCounter, (counter ?? 0) + 1);
  }

  static void resetWatchVideoCounter() {
    int? counter = _preferences?.getInt(AppSharedPreference.checkCounter);
    _preferences?.setInt(AppSharedPreference.checkCounter, 0);
  }

  Future<String> getAmplititudeUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? isLogIn = pref.getString(AppSharedPreference.AmplititudeUserId);
    if (isLogIn == null) {
      String randomUserId = generateRandomString(len: 12);
      await saveAmplititudeUserId(UserId: randomUserId);
      return randomUserId;
    } else {
      return isLogIn;
    }
  }

  Future<String> getUserId() async {
    return getAmplititudeUserId();
  }

  static String generateRandomString({required int len}) {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(
      len,
      (index) => chars[r.nextInt(chars.length)],
    ).join();
  }

  static Future<void> saveAmplititudeUserId({required String UserId}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(AppSharedPreference.AmplititudeUserId, UserId);
  }

  static String _seenReelsKey(String userId) {
    return '${AppSharedPreference.seenReelsPrefix}$userId';
  }

  static Future<Set<String>> getSeenReelIds({required String userId}) async {
    final prefs = await _ensurePrefs();
    final ids = prefs.getStringList(_seenReelsKey(userId)) ?? [];
    return ids.toSet();
  }

  static Future<void> setSeenReelIds({
    required String userId,
    required Set<String> ids,
  }) async {
    final prefs = await _ensurePrefs();
    await prefs.setStringList(_seenReelsKey(userId), ids.toList());
  }

  static Future<void> addSeenReelIds({
    required String userId,
    required Iterable<String> ids,
  }) async {
    final current = await getSeenReelIds(userId: userId);
    current.addAll(ids);
    await setSeenReelIds(userId: userId, ids: current);
  }

  static Future<void> resetSeenReelIds({required String userId}) async {
    final prefs = await _ensurePrefs();
    await prefs.remove(_seenReelsKey(userId));
  }
}
