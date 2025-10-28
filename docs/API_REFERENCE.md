# Sermon AI - API Reference

## **Overview**

This document provides comprehensive API reference for the Sermon AI Flutter application, including Firebase services, Razorpay integration, and custom API endpoints.

## **Firebase Services**

### **Authentication API**

#### **OTP Service**

```dart
class OTPService {
  // Send OTP to phone number
  static Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  });
  
  // Verify OTP code
  static Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String otpCode,
  });
  
  // Sign out user
  static Future<void> signOut();
  
  // Get current user
  static User? getCurrentUser();
}
```

**Parameters:**
- `phoneNumber`: Phone number in international format (e.g., "+919876543210")
- `verificationId`: Verification ID returned from `sendOTP`
- `otpCode`: 6-digit OTP code received via SMS

**Returns:**
- `UserCredential`: Firebase user credential on successful verification
- `null`: On verification failure

### **Firestore API**

#### **User Data Management**

```dart
class UserDataService {
  // Create user in Firestore
  static Future<void> createUser(FirebaseUser user);
  
  // Get user data by UID
  static Future<FirebaseUser?> getUserData(String uid);
  
  // Update user data
  static Future<void> updateUserData(String uid, Map<String, dynamic> data);
  
  // Delete user data
  static Future<void> deleteUserData(String uid);
}
```

**User Model:**
```dart
class FirebaseUser {
  final String uid;                    // Firebase user ID
  final String email;                  // User email
  final String phoneNumber;            // User phone number
  final String name;                   // User display name
  final String? subscriptionId;        // Associated subscription ID
  final bool? isFreeTrialOpted;        // Trial opt-in status
  final bool? isFreeTrialCompleted;    // Trial completion status
  final DateTime? trialStartDate;      // Trial start date
  final DateTime? trialEndDate;        // Trial end date
}
```

#### **Subscription Management**

```dart
class SubscriptionFirestoreFunctions {
  // Get user subscription status
  Future<SubscriptionCollectionOfUser?> getSubscriptionStatus(String userId);
  
  // Update subscription status
  Future<void> updateSubscriptionStatus(
    String userId, 
    SubscriptionCollectionOfUser subscription
  );
  
  // Create new subscription
  Future<void> createSubscription(SubscriptionCollectionOfUser subscription);
  
  // Cancel subscription
  Future<void> cancelSubscription(String userId);
}
```

**Subscription Model:**
```dart
class SubscriptionCollectionOfUser {
  final String uid;                           // User ID
  final String? subscriptionId;               // Internal subscription ID
  final String? razorpaySubscriptionId;       // Razorpay subscription ID
  final String? planId;                       // Plan identifier
  final String? planType;                     // Plan type (monthly/yearly)
  final String? customerId;                   // Razorpay customer ID
  final SubscriptionStatus status;            // Current status
  final int? totalCount;                      // Total subscription count
  final DateTime? createdAt;                  // Creation timestamp
  final DateTime? updatedAt;                  // Last update timestamp
  final DateTime? cancelledAt;                // Cancellation timestamp
  final DateTime? currentStart;               // Current period start
  final DateTime? currentEnd;                 // Current period end
}

enum SubscriptionStatus {
  active,                    // Active subscription
  payment_captured,         // Payment successfully captured
  cancelled,                // Subscription cancelled
  nullStatus,               // No subscription
  created,                  // Subscription created but not active
  subscription_authenticated, // Subscription authenticated
}
```

#### **Content Management**

```dart
class ReelsFirestoreFunctions {
  // Get reels with pagination
  Future<List<ReelsModel>> getReels({
    int limit = 10,
    DocumentSnapshot? lastDocument,
  });
  
  // Get single reel by ID
  Future<ReelsModel?> getReelById(String id);
  
  // Get reels by category
  Future<List<ReelsModel>> getReelsByCategory(String category);
}

class VideoFirestoreFunctions {
  // Get videos with pagination
  Future<List<VideoDataModel>> getVideos({
    int limit = 10,
    DocumentSnapshot? lastDocument,
  });
  
  // Get single video by ID
  Future<VideoDataModel?> getVideoById(String id);
  
  // Get videos by category
  Future<List<VideoDataModel>> getVideosByCategory(String category);
}
```

**Content Models:**
```dart
class ReelsModel {
  final String id;                    // Unique reel identifier
  final String videoId;               // Associated full video ID
  final String fullVideoLink;         // URL to full video
  final String reelLink;              // URL to reel video
  final String category;              // Content category
}

class VideoDataModel {
  final String id;                    // Video identifier
  final String title;                 // Video title
  final String description;           // Video description
  final String videoUrl;              // Video URL
  final String thumbnailUrl;          // Thumbnail URL
  final String category;              // Content category
  final DateTime createdAt;           // Creation timestamp
  final int duration;                 // Video duration in seconds
  final List<String> tags;            // Content tags
}
```

#### **Transaction Management**

```dart
class TransistionFirestoreFunctions {
  // Create new transaction record
  Future<void> newFirebaseTransitionData(
    TransactionModelFirebase firebaseTransition
  );
  
  // Get user transactions
  Future<List<TransactionModelFirebase>> getUserTransactions(String userId);
  
  // Get transaction by ID
  Future<TransactionModelFirebase?> getTransactionById(String transactionId);
}
```

**Transaction Model:**
```dart
class TransactionModelFirebase {
  final String transactionId;         // Unique transaction ID
  final double amount;                // Transaction amount
  final String createdAt;             // Creation timestamp
  final String updatedAt;             // Last update timestamp
  final String userId;                // User ID
}
```

## **Razorpay Integration**

### **Payment Service**

```dart
class RazorpayService {
  // Open payment checkout
  void openCheckout({
    required String apiKey,
    required String subscriptionId,
    required Future<void> Function() onSuccess,
  });
  
  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response);
  
  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response);
  
  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response);
  
  // Dispose service
  void dispose();
}
```

**Payment Options:**
```dart
var options = {
  "key": apiKey,                      // Razorpay key ID
  "subscription_id": subscriptionId,  // Subscription ID
  "recurring": true,                  // Recurring payment
  'method': 'wallet',                 // Payment method
  "name": "SermonTV",                 // Merchant name
  "description": 'Recharge Plan Activation', // Description
  'theme': {'color': '#1F20D6'},      // Theme color
};
```

### **API Endpoints**

#### **Customer Management**

```dart
class MyAppEndpoints {
  // Create Razorpay customer
  Future<Response> createCustomer({
    required FirebaseUser firebaseUser
  });
  
  // Get customer details
  Future<Response> getCustomer(String customerId);
  
  // Update customer details
  Future<Response> updateCustomer(String customerId, Map<String, dynamic> data);
}
```

**Create Customer Request:**
```dart
var data = {
  'name': firebaseUser.name,
  'email': firebaseUser.email == '' 
      ? firebaseUser.uid.toGmail() 
      : firebaseUser.email,
  'contact': firebaseUser.phoneNumber,
  'userId': firebaseUser.uid,
};
```

**Create Customer Response:**
```dart
class RazorpayCustomerResponse {
  final Customer? customer;
  final String? error;
}

class Customer {
  final String? razorpayCustomerId;
  final String? userId;
  final String? name;
  final String? email;
  final String? contact;
}
```

#### **Subscription Management**

```dart
class MyAppEndpoints {
  // Create subscription
  Future<Response> createSubscription({
    required RazorpayCustomerResponse razorpayCustomerResponse,
  });
  
  // Get subscription status
  Future<Response> subscriptionStatus({required String userId});
  
  // Cancel subscription
  Future<Response> cancelSubscription(String subscriptionId);
}
```

**Create Subscription Request:**
```dart
Map<String, dynamic> data = {
  'planId': isDebugMode() 
      ? 'plan_Qwe6q0fZBLxs0L' 
      : 'plan_RLVhblLvuxHbFc',
  'customerId': razorpayCustomerResponse.customer?.razorpayCustomerId,
  'userId': razorpayCustomerResponse.customer?.userId,
  'planType': 'monthly',
  'totalCount': 12,
  'startDate': 7,
  'customerNotify': 1,
};
```

**Subscription Response:**
```dart
class SubscriptionResponse {
  final String? subscriptionId;
  final String? planId;
  final String? status;
  final DateTime? currentStart;
  final DateTime? currentEnd;
  final String? error;
}
```

## **Local Storage API**

### **Hive Database**

```dart
class HiveBoxFunctions {
  // User data management
  Future<void> saveUserData(FirebaseUser user);
  FirebaseUser? getUserData();
  Future<void> clearUserData();
  
  // Subscription data management
  Future<void> saveSubscriptionData(SubscriptionCollectionOfUser subscription);
  SubscriptionCollectionOfUser? getSubscriptionData();
  Future<void> clearSubscriptionData();
  
  // Utility functions
  String getUuid();
  Future<void> clearAllData();
  bool isUserLoggedIn();
}
```

### **SharedPreferences**

```dart
class SharedPreferenceLogic {
  // Authentication tokens
  static Future<void> saveAuthToken(String token);
  static Future<String?> getAuthToken();
  
  // User preferences
  static Future<void> saveUserPreference(String key, dynamic value);
  static Future<dynamic> getUserPreference(String key);
  
  // App settings
  static Future<void> saveAppSetting(String key, bool value);
  static Future<bool> getAppSetting(String key, {bool defaultValue = false});
  
  // First launch
  static Future<bool> isFirstLaunch();
  static Future<void> setFirstLaunchCompleted();
}
```

## **Analytics API**

### **Firebase Analytics**

```dart
class MyAppAmplitudeAndFirebaseAnalitics {
  // Log custom event
  Future<void> logEvent({
    required String event,
    Map<String, dynamic>? parameters,
  });
  
  // Set user properties
  Future<void> setUserProperties(Map<String, dynamic> properties);
  
  // Set user ID
  Future<void> setUserId(String userId);
  
  // Initialize analytics
  Future<void> init();
}
```

### **Event Tracking**

```dart
class LogEventsName {
  // Content engagement
  static String reel_watched = 'reel_watched';
  static String watch_full_video_reel = 'watch_full_video_reel';
  static String video_completion = 'video_completion';
  
  // User actions
  static String userLogin = 'user_login';
  static String userSignup = 'user_signup';
  static String userLogout = 'user_logout';
  
  // Subscription events
  static String subscribePageByReels = 'subscribe_page_by_reels';
  static String subscriptionSuccess = 'subscription_success';
  static String subscriptionFailEvent = 'subscription_fail_event';
  
  // App events
  static String appLaunch = 'app_launch';
  static String appBackground = 'app_background';
  static String appForeground = 'app_foreground';
}
```

## **Utility APIs**

### **Network Time**

```dart
class MyAppEndpoints {
  // Get network time for accurate time synchronization
  Future<DateTime?> getNetworkTime();
}
```

**Usage:**
```dart
final networkTime = await MyAppEndpoints.instance().getNetworkTime();
if (networkTime != null) {
  // Use network time for accurate calculations
  final now = networkTime;
} else {
  // Fallback to local time
  final now = DateTime.now();
}
```

### **String Extensions**

```dart
extension StringExtensions on String {
  // Convert to Gmail format
  String toGmail();
  
  // Validate email
  bool isValidEmail();
  
  // Validate phone number
  bool isValidPhoneNumber();
  
  // Format phone number
  String formatPhoneNumber();
}
```

### **App Logger**

```dart
class AppLogger {
  // Debug logging
  static void d(String message);
  
  // Error logging
  static void e(String message);
  
  // Info logging
  static void i(String message);
  
  // Warning logging
  static void w(String message);
}
```

## **Error Handling**

### **Custom Exceptions**

```dart
class AppError {
  final String message;
  final int? code;
  
  AppError(this.message, [this.code]);
}

class NetworkException extends AppError {
  NetworkException(String message) : super(message);
}

class AuthenticationException extends AppError {
  AuthenticationException(String message) : super(message);
}

class SubscriptionException extends AppError {
  SubscriptionException(String message) : super(message);
}
```

### **Error Response Format**

```dart
class ErrorResponse {
  final String message;
  final int code;
  final String? details;
  
  ErrorResponse({
    required this.message,
    required this.code,
    this.details,
  });
  
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] ?? 'Unknown error',
      code: json['code'] ?? 500,
      details: json['details'],
    );
  }
}
```

## **Rate Limiting**

### **API Rate Limits**

- **Firebase Auth**: 10 requests per minute per phone number
- **Firestore**: 1 million reads per day (free tier)
- **Razorpay**: 1000 requests per minute
- **Custom API**: 100 requests per minute per user

### **Retry Logic**

```dart
Future<T> retryOperation<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  int retryCount = 0;
  
  while (retryCount < maxRetries) {
    try {
      return await operation();
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        throw e;
      }
      await Future.delayed(delay * retryCount);
    }
  }
  
  throw Exception('Max retries exceeded');
}
```

## **Testing APIs**

### **Mock Services**

```dart
class MockUserDataService {
  static final Map<String, FirebaseUser> _users = {};
  
  static Future<void> createUser(FirebaseUser user) async {
    _users[user.uid] = user;
  }
  
  static Future<FirebaseUser?> getUserData(String uid) async {
    return _users[uid];
  }
  
  static Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    if (_users.containsKey(uid)) {
      // Update user data
    }
  }
  
  static Future<void> deleteUserData(String uid) async {
    _users.remove(uid);
  }
}
```

### **Test Utilities**

```dart
class TestUtils {
  // Create test user
  static FirebaseUser createTestUser({
    String uid = 'test_uid',
    String email = 'test@example.com',
    String phoneNumber = '+919876543210',
    String name = 'Test User',
  }) {
    return FirebaseUser(
      uid: uid,
      email: email,
      phoneNumber: phoneNumber,
      name: name,
    );
  }
  
  // Create test subscription
  static SubscriptionCollectionOfUser createTestSubscription({
    String uid = 'test_uid',
    SubscriptionStatus status = SubscriptionStatus.active,
  }) {
    return SubscriptionCollectionOfUser(
      uid: uid,
      status: status,
      currentStart: DateTime.now(),
      currentEnd: DateTime.now().add(Duration(days: 30)),
    );
  }
}
```

---

*This API reference provides comprehensive documentation for all services, models, and endpoints used in the Sermon AI Flutter application.*
