# Sermon AI - Technical Architecture

## **Architecture Overview**

Sermon AI follows a clean architecture pattern with clear separation of concerns, using Flutter's BLoC pattern for state management and Firebase as the backend service.

## **Project Structure**

```
lib/
├── main.dart                          # Application entry point
├── firebase_options.dart              # Firebase configuration
├── models/                           # Data models
│   ├── login_model.dart
│   ├── sign_up_model.dart
│   ├── video_data_model.dart
│   └── playlist_and_episode_model_old.dart
├── network/                          # Network layer
│   ├── dio_client.dart               # HTTP client configuration
│   ├── endpoints.dart                # API endpoint definitions
│   └── form_data.dart                # Form data handling
├── reusable/                         # Shared UI components
│   ├── my_scaffold_widget.dart
│   ├── MyAppElevatedButton.dart
│   ├── video_player_using_id.dart
│   ├── app_dialogs.dart
│   └── my_app_firebase_analytics/    # Analytics components
├── screens/                          # UI screens
│   ├── splash_screen.dart
│   ├── before_login/                 # Authentication screens
│   └── after_login/                  # Main app screens
│       └── bottom_nav/               # Bottom navigation structure
├── services/                         # Business logic services
│   ├── firebase/                     # Firebase services
│   ├── hive_box/                     # Local storage
│   ├── shared_pref/                  # Shared preferences
│   ├── plan_service/                 # Subscription management
│   └── token_check_service/          # Authentication validation
└── utils/                           # Utility functions
    ├── app_assets.dart
    ├── app_color.dart
    └── string_extensions.dart
```

## **State Management Architecture**

### **BLoC Pattern Implementation**

The app uses Flutter BLoC pattern for state management with the following structure:

```dart
// Cubit - Business Logic
class ExampleCubit extends Cubit<ExampleState> {
  ExampleCubit() : super(ExampleInitial());
  
  Future<void> loadData() async {
    emit(ExampleLoading());
    try {
      final data = await _repository.getData();
      emit(ExampleLoaded(data));
    } catch (e) {
      emit(ExampleError(e.toString()));
    }
  }
}

// State - State Definition
abstract class ExampleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExampleInitial extends ExampleState {}
class ExampleLoading extends ExampleState {}
class ExampleLoaded extends ExampleState {
  final List<Data> data;
  ExampleLoaded(this.data);
  
  @override
  List<Object?> get props => [data];
}
class ExampleError extends ExampleState {
  final String message;
  ExampleError(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

### **Key BLoC Components**

1. **Authentication Flow**
   - `LoginCheckCubit`: Token validation and authentication state
   - `LoginForgotSignupCubit`: Login/signup form management

2. **Navigation Management**
   - `BottomNavCubit`: Main navigation state management
   - `BottomNavZeroCubit`: Reels tab state management
   - `BottomNavFirstCubit`: Videos tab state management

3. **Subscription Management**
   - `PlanPurchaseCubit`: Subscription purchase flow
   - Subscription validation and status management

## **Firebase Integration**

### **Firestore Collections**

```dart
class FirestoreVariables {
  // User Management
  static const String usersCollection = 'Users';
  static const String userIdField = 'USER_ID';
  static const String emailField = 'EMAIL';
  static const String phoneField = 'PHONE_NUMBER';
  static const String nameField = 'NAME';
  
  // Subscription Management
  static const String subscriptionCollection = 'subscriptions';
  static const String subscriptionCollectionTest = 'test-subscriptions';
  static const String razorpaySubscriptionIdField = 'razorpaySubscriptionId';
  static const String planIdField = 'planId';
  static const String statusField = 'status';
  
  // Content Management
  static const String videosCollection = 'Videos';
  static const String reelsCollection = 'reels';
  
  // Transaction Management
  static const String transactionsCollection = 'Transactions';
  static const String transactionIdField = 'TRANSACTION_ID';
  static const String amountField = 'AMOUNT';
  
  // Utility Management
  static const String utilitiesCollection = 'Utilities';
  static const String totalVideoCount = 'TOTAL_VIDEO_COUNT';
  static const String videoCountToCheckSub = 'VIDEO_COUNT_TO_CHECK_SUB';
}
```

### **Data Models**

#### **User Model**
```dart
class FirebaseUser {
  final String uid;
  final String email;
  final String phoneNumber;
  final String name;
  final String? subscriptionId;
  
  // Serialization methods
  factory FirebaseUser.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  Map<String, dynamic> toMap();
  factory FirebaseUser.fromMap(Map<String, dynamic> map);
}
```

#### **Subscription Model**
```dart
class SubscriptionCollectionOfUser {
  final String uid;
  final String? subscriptionId;
  final String? razorpaySubscriptionId;
  final String? planId;
  final String? planType;
  final String? customerId;
  final SubscriptionStatus status;
  final DateTime? currentStart;
  final DateTime? currentEnd;
  
  // Serialization and status management
  factory SubscriptionCollectionOfUser.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

enum SubscriptionStatus {
  active,
  payment_captured,
  cancelled,
  nullStatus,
  created,
  subscription_authenticated,
}
```

#### **Reels Model**
```dart
class ReelsModel {
  final String id;
  final String videoId;
  final String fullVideoLink;
  final String reelLink;
  final String category;
  
  // Serialization methods
  factory ReelsModel.fromMap(Map<String, dynamic> data);
  Map<String, dynamic> toMap();
}
```

## **Network Layer**

### **Dio Client Configuration**

```dart
class MyAppDio {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ));
  
  static Dio instance() => _dio;
}
```

### **API Endpoints**

```dart
class MyAppEndpoints {
  // Subscription Management
  Future<Response> subscriptionStatus({required String userId});
  Future<Response> createCustomer({required FirebaseUser firebaseUser});
  Future<Response> createSubscription({
    required RazorpayCustomerResponse razorpayCustomerResponse,
  });
  
  // Utility Functions
  Future<DateTime?> getNetworkTime();
}
```

## **Local Storage Architecture**

### **Hive Database**

```dart
class HiveBoxFunctions {
  // User data storage
  Future<void> saveUserData(FirebaseUser user);
  FirebaseUser? getUserData();
  
  // Subscription data storage
  Future<void> saveSubscriptionData(SubscriptionCollectionOfUser subscription);
  SubscriptionCollectionOfUser? getSubscriptionData();
  
  // Utility functions
  String getUuid();
  Future<void> clearAllData();
}
```

### **SharedPreferences**

```dart
class SharedPreferenceLogic {
  // Authentication tokens
  static Future<void> saveAuthToken(String token);
  static String? getAuthToken();
  
  // User preferences
  static Future<void> saveUserPreference(String key, dynamic value);
  static dynamic getUserPreference(String key);
  
  // App settings
  static Future<void> saveAppSetting(String key, bool value);
  static bool getAppSetting(String key, {bool defaultValue = false});
}
```

## **Video Player Architecture**

### **Custom Video Player Implementation**

```dart
class ReelVideoPlayer extends StatefulWidget {
  final ReelsModel reelsModel;
  final int index;
  final Function(int, VideoPlayerController) onControllerReady;
  
  // Video player with gesture controls
  // Automatic play/pause management
  // Full video navigation
}
```

### **Video Management Features**

1. **Automatic Playback Control**
   - Only current video plays
   - Pause previous videos on scroll
   - Memory-efficient controller management

2. **Gesture Controls**
   - Tap to play/pause
   - Visual feedback for controls
   - Seamless user experience

3. **Full Video Integration**
   - Direct navigation to full video
   - Pause current reel before navigation
   - Analytics tracking for engagement

## **Analytics Integration**

### **Firebase Analytics**

```dart
class MyAppAmplitudeAndFirebaseAnalitics {
  // Event tracking
  Future<void> logEvent({
    required String event,
    Map<String, dynamic>? parameters,
  });
  
  // User properties
  Future<void> setUserProperties(Map<String, dynamic> properties);
  
  // Custom events
  Future<void> logReelWatched();
  Future<void> logFullVideoWatched();
  Future<void> logSubscriptionAttempt();
}
```

### **Event Tracking**

```dart
class LogEventsName {
  // Content engagement
  static String reel_watched = 'reel_watched';
  static String watch_full_video_reel = 'watch_full_video_reel';
  
  // Subscription events
  static String subscribePageByReels = 'subscribe_page_by_reels';
  static String subscriptionFailEvent = 'subscription_fail_event';
  
  // User journey
  static String userLogin = 'user_login';
  static String userSignup = 'user_signup';
}
```

## **Security Architecture**

### **Authentication Flow**

1. **OTP-based Authentication**
   - Phone number verification
   - Firebase Auth integration
   - Secure token management

2. **Subscription Validation**
   - Real-time status checking
   - Network time synchronization
   - Secure payment processing

### **Data Security**

1. **Firebase Security Rules**
   - User-based access control
   - Subscription status validation
   - Content access restrictions

2. **Payment Security**
   - Razorpay secure integration
   - Transaction validation
   - Secure customer data handling

## **Performance Optimization**

### **Memory Management**

```dart
class _BottomNavZeroScreenState extends State<BottomNavZeroScreen> {
  final Map<int, VideoPlayerController> _controllers = {};
  
  @override
  void dispose() {
    // Proper disposal of controllers
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
```

### **Offline Support**

```dart
// Firebase Firestore offline persistence
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### **Video Optimization**

1. **Lazy Loading**: Videos load only when needed
2. **Controller Management**: Efficient memory usage
3. **Caching**: Network image and video caching
4. **Background Handling**: Proper pause/resume on app state changes

## **Error Handling**

### **Global Error Handling**

```dart
void main() async {
  // Flutter error handling
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  // Platform error handling
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
```

### **Service Layer Error Handling**

```dart
class ExampleService {
  Future<Result<T, AppError>> safeCall<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Result.success(result);
    } catch (e) {
      return Result.failure(AppError(e.toString()));
    }
  }
}
```

---

*This technical architecture documentation provides a comprehensive overview of the Sermon AI app's technical implementation, patterns, and best practices.*
