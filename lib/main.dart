// import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sermon/screens/before_login/login_forgot_signup_cubit.dart';
import 'package:sermon/services/log_service/log_service.dart';
import 'package:sermon/services/plan_service/plan_purchase_cubit.dart';
import 'package:sermon/services/plan_service/plan_purchase_screen.dart';
import 'package:sermon/services/reel_video_download.dart';
import 'package:sermon/services/shared_pref/shared_preference.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import 'package:sermon/reusable/logger_service.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/deep_link_content_screen.dart';
import 'services/firebase_notification_mine.dart';
import 'services/token_check_service/login_check_cubit.dart';
import 'utils/app_color.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sermon/services/firebase/firebase_remote_config.dart';
import 'package:sermon/services/deep_link_service.dart';

// Global navigator key for navigation from outside of build context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure proper initialization
  await SharedPreferenceLogic.initialize();

  // Initialize deep link service
  await DeepLinkService().initialize();

  // To clear cache
  await ReelVideoDownloader().clearAllCachedReels();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.instance.initialize();
    AppLogger.d('🔥 Firebase Core initialized successfully');

    // Initialize Firebase Analytics
    final analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(true);
    AppLogger.d('📊 Firebase Analytics initialized and enabled');

    await MyAppAmplitudeAndFirebaseAnalitics().init();
    AppLogger.d('📱 App analytics services initialized');

    // Initialize Firebase Remote Config
    await FirebaseRemoteConfigService().initialize();
    AppLogger.d('📡 Firebase Remote Config initialized');

    try {
      await FirebaseRemoteConfigService().refresh();
    } catch (e) {
      AppLogger.e('❌ Error refreshing Firebase Remote Config: $e');
    }
  } catch (e) {
    AppLogger.e('❌ Error initializing Firebase: $e');
  }

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // ✅ Enable offline mode
    cacheSizeBytes:
        Settings.CACHE_SIZE_UNLIMITED, // Optional: keep unlimited cache
  );

  // final config = ClarityConfig(
  //     projectId: "s3uew6gddm",
  //     logLevel: LogLevel.None // Note: Use "LogLevel.Verbose" value while testing to debug initialization issues.
  // );

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  final hiveBoxService = HiveBoxFunctions();
  await hiveBoxService.init();

  runApp(MyApp());

  // await configureSDK();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _setupDeepLinkListener();

    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCheckCubit>(
          create: (context) => LoginCheckCubit()..freshInstallEventLog(),
        ),
        BlocProvider<LoginForgotSignupCubit>(
          create: (context) => LoginForgotSignupCubit(),
        ),
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        navigatorKey: navigatorKey, // Add navigator key here
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: MyAppColor.background,
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: Colors.white),
            displayMedium: TextStyle(color: Colors.white),
            displaySmall: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Colors.white),
            labelLarge: TextStyle(color: Colors.white),
            labelMedium: TextStyle(color: Colors.white),
            labelSmall: TextStyle(color: Colors.white),
            headlineLarge: TextStyle(color: Colors.white),
            headlineMedium: TextStyle(color: Colors.white),
            headlineSmall: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
            titleSmall: TextStyle(color: Colors.white),
          ),
        ),
        home: SplashScreen(),
        // home: const SignUpThirdScreen(),
      ),
    );
  }

  void _setupDeepLinkListener() {
    DeepLinkService().deepLinkStream.listen((String link) {
      AppLogger.d('🔗 Deep link received in MyApp: $link');
      final deepLinkContent = DeepLinkService().extractPathFromLink(link);
      if (deepLinkContent != null) {
        AppLogger.d('📱 Navigating to deep link content: $deepLinkContent');
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => DeepLinkContentScreen(
              deepLinkContent: deepLinkContent,
              isFromSplash: false,
            ),
          ),
        );
      }
    });
  }
}

bool isDebugMode() {
  if (kReleaseMode) {
    return false;
  }
  return false;
}
