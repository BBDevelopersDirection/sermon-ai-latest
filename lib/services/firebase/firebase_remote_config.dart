import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:sermon/reusable/logger_service.dart';

class FirebaseRemoteConfigService {
  static final FirebaseRemoteConfigService _instance =
      FirebaseRemoteConfigService._internal();

  factory FirebaseRemoteConfigService() => _instance;
  FirebaseRemoteConfigService._internal();

  late final FirebaseRemoteConfig _remoteConfig;
  bool _initialized = false;

  /// Initialize Remote Config — no hardcoded defaults!
  Future<void> initialize() async {
    if (_initialized) {
      AppLogger.d('📡 Remote Config already initialized');
      return;
    }

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      final bool activated = await _remoteConfig.fetchAndActivate();
      AppLogger.d(
        '📡 Remote Config initialized (${activated ? "fetched new" : "using cached"})',
      );

      _initialized = true;
    } catch (e) {
      AppLogger.e('❌ Failed to initialize Remote Config: $e');
      rethrow; // You may want to handle this at app startup
    }
  }

  /// Helper to safely get a string from Remote Config
  String getString(String key) {
    if (!_initialized) {
      AppLogger.w('⚠️ Remote Config not initialized; call initialize() first.');
      return '';
    }
    try {
      final value = _remoteConfig.getString(key).trim();
      if (value.isEmpty) {
        AppLogger.w('⚠️ Remote Config value for "$key" is empty.');
      }
      return value;
    } catch (e) {
      AppLogger.e('❌ Error getting Remote Config value for "$key": $e');
      return '';
    }
  }

  int getInt(String key) {
  if (!_initialized) {
    AppLogger.w('⚠️ Remote Config not initialized; call initialize() first.');
    return 0;
  }
  try {
    final value = _remoteConfig.getInt(key);
    return value;
  } catch (e) {
    AppLogger.e('❌ Error getting int Remote Config value for "$key": $e');
    return 0;
  }
}

bool? getBool(String key) {
  if (!_initialized) {
    AppLogger.w('⚠️ Remote Config not initialized; call initialize() first.');
    return null;
  }
  try {
    final value = _remoteConfig.getBool(key);
    return value;
  } catch (e) {
    AppLogger.e('❌ Error getting bool Remote Config value for "$key": $e');
    return null;
  }
}


  /// Example getters — all fetched remotely
  String get razorpayTestApiKey => getString('razorpay_test_api_key');
  String get razorpayLiveApiKey => getString('razorpay_live_api_key');
  String get apiBaseUrl => getString('api_base_url');
  String get razorpayTestPlanId => getString('razorpay_test_plan_id');
  String get razorpayLivePlanId => getString('razorpay_live_plan_id');
  String get truecallerClientId => getString('truecaller_client_id');
  String get truecallerTokenEndpoint => getString('truecaller_token_endpoint');
  String get truecallerUserinfoEndpoint =>
      getString('truecaller_userinfo_endpoint');
  String get whatsappSupportNumber => getString('whatsapp_support_number');
  String get privacyPolicyUrl => getString('privacy_policy_url');
  String get subscriptionCollectionTest =>
      getString('subscription_collection_test');
  String get subscriptionCollectionProd =>
      getString('subscription_collection_prod');
  String get homeGreetingText => getString('home_greeting_text');
  String get homeSubtitleText => getString('home_subtitle_text');
  String get whatsappErrorMessage => getString('whatsapp_error_message');
  int get totalVideoCountUserCanSee => getInt('total_video_count_user_can_see');
  int get totalReelCountUserCanSee => getInt('total_reel_count_user_can_see');
  int get rechargePageDelaySecondsAfterLogin => getInt('recharge_page_delay_seconds_after_login');
  bool get shouldShowRechargePage => getBool('shouldShowRechargePage') ?? true;

  /// Get Category Order as List<String>
  List<String> get categoryOrder {
    final raw = getString('category_order');
    if (raw.isEmpty) return [];
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Refresh values manually
  Future<void> refresh() async {
    if (!_initialized) await initialize();
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      AppLogger.d('📡 Remote Config ${activated ? "refreshed" : "cached"}');
    } catch (e) {
      AppLogger.e('❌ Error refreshing Remote Config: $e');
    }
  }
}
