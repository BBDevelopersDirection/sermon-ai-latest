// import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sermon/services/log_service/log_service.dart';
import 'package:sermon/services/shared_pref/shared_preference.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_notification_mine.dart';
import 'services/token_check_service/login_check_cubit.dart';
import 'utils/app_color.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// Global navigator key for navigation from outside of build context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure proper initialization
  await SharedPreferenceLogic.initialize();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.instance.initialize();
    debugPrint('🔥 Firebase Core initialized successfully');

    // Initialize Firebase Analytics
    final analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(true);
    debugPrint('📊 Firebase Analytics initialized and enabled');

    await MyAppAmplitudeAndFirebaseAnalitics().init();
    debugPrint('📱 App analytics services initialized');
  } catch (e) {
    debugPrint('❌ Error initializing Firebase: $e');
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
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Optional: keep unlimited cache
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
    return BlocProvider(
      create: (context) => LoginCheckCubit(),
      child: MaterialApp(
        navigatorKey: navigatorKey, // Add navigator key here
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: MyAppColor.background,
          // progressIndicatorTheme: const ProgressIndicatorThemeData(
          //   color: Colors.white,
          // ),
        ),
        home: const SplashScreen(),
        // home: const SignUpThirdScreen(),
      ),
    );
  }
}
