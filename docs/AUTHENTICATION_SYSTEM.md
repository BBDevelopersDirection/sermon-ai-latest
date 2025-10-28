# Sermon AI - Authentication System Documentation

## **Overview**

The Sermon AI authentication system implements OTP-based phone number verification using Firebase Authentication. The system provides secure user registration, login, and session management with comprehensive error handling and analytics tracking.

## **Authentication Flow**

### **User Registration Process**

1. **Phone Number Input**: User enters phone number
2. **OTP Verification**: Firebase sends OTP to phone number
3. **OTP Validation**: User enters received OTP
4. **Account Creation**: Firebase creates user account
5. **Profile Setup**: User completes profile information
6. **Local Storage**: User data stored locally for offline access

### **User Login Process**

1. **Phone Number Input**: User enters registered phone number
2. **OTP Verification**: Firebase sends OTP to phone number
3. **OTP Validation**: User enters received OTP
4. **Session Creation**: Firebase creates authenticated session
5. **Data Sync**: User data synchronized from Firestore
6. **Navigation**: User redirected to main app

## **Technical Implementation**

### **Firebase Authentication Service**

```dart
class OTPService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Send OTP to phone number
  static Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      onError(e.toString());
    }
  }
  
  // Verify OTP code
  static Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String otpCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      
      return await _signInWithCredential(credential);
    } catch (e) {
      AppLogger.e('OTP verification error: $e');
      return null;
    }
  }
  
  // Sign in with credential
  static Future<UserCredential> _signInWithCredential(
    PhoneAuthCredential credential
  ) async {
    return await _auth.signInWithCredential(credential);
  }
}
```

### **Authentication State Management**

```dart
class LoginCheckCubit extends Cubit<LoginCheckState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  LoginCheckCubit() : super(LoginCheckInitial()) {
    _initializeAuth();
  }
  
  void _initializeAuth() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _handleUserSignedIn(user);
      } else {
        _handleUserSignedOut();
      }
    });
  }
  
  Future<void> _handleUserSignedIn(User user) async {
    try {
      // Get user data from Firestore
      final userData = await UserDataService.getUserData(user.uid);
      
      if (userData != null) {
        // Save user data locally
        await HiveBoxFunctions().saveUserData(userData);
        
        emit(LoginCheckAuthenticated(userData));
      } else {
        // User data not found, need to complete profile
        emit(LoginCheckProfileIncomplete(user));
      }
    } catch (e) {
      emit(LoginCheckError(e.toString()));
    }
  }
  
  void _handleUserSignedOut() {
    emit(LoginCheckUnauthenticated());
  }
  
  // Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await HiveBoxFunctions().clearUserData();
      emit(LoginCheckUnauthenticated());
    } catch (e) {
      emit(LoginCheckError(e.toString()));
    }
  }
}
```

### **Authentication States**

```dart
abstract class LoginCheckState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginCheckInitial extends LoginCheckState {}

class LoginCheckLoading extends LoginCheckState {}

class LoginCheckAuthenticated extends LoginCheckState {
  final FirebaseUser user;
  
  LoginCheckAuthenticated(this.user);
  
  @override
  List<Object?> get props => [user];
}

class LoginCheckUnauthenticated extends LoginCheckState {}

class LoginCheckProfileIncomplete extends LoginCheckState {
  final User firebaseUser;
  
  LoginCheckProfileIncomplete(this.firebaseUser);
  
  @override
  List<Object?> get props => [firebaseUser];
}

class LoginCheckError extends LoginCheckState {
  final String message;
  
  LoginCheckError(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

## **User Data Management**

### **User Model**

```dart
class FirebaseUser {
  final String uid;                    // Firebase user ID
  final String email;                  // User email
  final String phoneNumber;            // User phone number
  final String name;                   // User display name
  final String? subscriptionId;        // Associated subscription ID
  
  // Trial period fields
  final bool? isFreeTrialOpted;        // Whether user opted for trial
  final bool? isFreeTrialCompleted;    // Whether trial is completed
  final DateTime? trialStartDate;      // Trial start date
  final DateTime? trialEndDate;        // Trial end date
  
  FirebaseUser({
    required this.uid,
    required this.email,
    required this.phoneNumber,
    required this.name,
    this.subscriptionId,
    this.isFreeTrialOpted,
    this.isFreeTrialCompleted,
    this.trialStartDate,
    this.trialEndDate,
  });
  
  // Serialization methods
  factory FirebaseUser.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  Map<String, dynamic> toMap();
  factory FirebaseUser.fromMap(Map<String, dynamic> map);
}
```

### **User Data Service**

```dart
class UserDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Create user data in Firestore
  static Future<void> createUser(FirebaseUser user) async {
    try {
      await _firestore
          .collection(FirestoreVariables.usersCollection)
          .doc(user.uid)
          .set(user.toJson());
      
      AppLogger.d('User created successfully: ${user.uid}');
    } catch (e) {
      AppLogger.e('Error creating user: $e');
      throw Exception('Failed to create user: $e');
    }
  }
  
  // Get user data from Firestore
  static Future<FirebaseUser?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestoreVariables.usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return FirebaseUser.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      AppLogger.e('Error getting user data: $e');
      return null;
    }
  }
  
  // Update user data
  static Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(FirestoreVariables.usersCollection)
          .doc(uid)
          .update(data);
      
      AppLogger.d('User data updated successfully: $uid');
    } catch (e) {
      AppLogger.e('Error updating user data: $e');
      throw Exception('Failed to update user data: $e');
    }
  }
  
  // Delete user data
  static Future<void> deleteUserData(String uid) async {
    try {
      await _firestore
          .collection(FirestoreVariables.usersCollection)
          .doc(uid)
          .delete();
      
      AppLogger.d('User data deleted successfully: $uid');
    } catch (e) {
      AppLogger.e('Error deleting user data: $e');
      throw Exception('Failed to delete user data: $e');
    }
  }
}
```

## **Local Storage Integration**

### **Hive Database**

```dart
class HiveBoxFunctions {
  static const String userBoxName = 'userBox';
  static const String userDataKey = 'userData';
  
  // Save user data locally
  Future<void> saveUserData(FirebaseUser user) async {
    try {
      final box = await Hive.openBox(userBoxName);
      await box.put(userDataKey, user.toMap());
      AppLogger.d('User data saved locally');
    } catch (e) {
      AppLogger.e('Error saving user data locally: $e');
    }
  }
  
  // Get user data from local storage
  FirebaseUser? getUserData() {
    try {
      final box = Hive.box(userBoxName);
      final userData = box.get(userDataKey);
      
      if (userData != null) {
        return FirebaseUser.fromMap(Map<String, dynamic>.from(userData));
      }
      return null;
    } catch (e) {
      AppLogger.e('Error getting user data from local storage: $e');
      return null;
    }
  }
  
  // Clear user data
  Future<void> clearUserData() async {
    try {
      final box = await Hive.openBox(userBoxName);
      await box.clear();
      AppLogger.d('User data cleared locally');
    } catch (e) {
      AppLogger.e('Error clearing user data: $e');
    }
  }
  
  // Check if user is logged in locally
  bool isUserLoggedIn() {
    return getUserData() != null;
  }
}
```

### **SharedPreferences**

```dart
class SharedPreferenceLogic {
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String isFirstLaunchKey = 'is_first_launch';
  
  // Save authentication token
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(authTokenKey, token);
  }
  
  // Get authentication token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(authTokenKey);
  }
  
  // Save user ID
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userIdKey, userId);
  }
  
  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }
  
  // Check if first launch
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isFirstLaunchKey) ?? true;
  }
  
  // Set first launch completed
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isFirstLaunchKey, false);
  }
}
```

## **UI Components**

### **Login Screen**

```dart
class LoginScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginForgotSignupCubit(),
      child: Scaffold(
        body: BlocBuilder<LoginForgotSignupCubit, LoginForgotSignupState>(
          builder: (context, state) {
            if (state is LoginForgotSignupLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return Column(
              children: [
                // Phone number input
                TextFieldWithHead(
                  title: 'Phone Number',
                  hintText: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    context.read<LoginForgotSignupCubit>().updatePhoneNumber(value);
                  },
                ),
                
                // Send OTP button
                MyAppElevatedButton(
                  title: 'Send OTP',
                  onPressed: () {
                    context.read<LoginForgotSignupCubit>().sendOTP();
                  },
                ),
                
                // Error message
                if (state is LoginForgotSignupError)
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

### **OTP Verification Screen**

```dart
class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginForgotSignupCubit(),
      child: Scaffold(
        body: BlocBuilder<LoginForgotSignupCubit, LoginForgotSignupState>(
          builder: (context, state) {
            return Column(
              children: [
                // OTP input
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  onChanged: (value) {
                    context.read<LoginForgotSignupCubit>().updateOTPCode(value);
                  },
                  onCompleted: (value) {
                    context.read<LoginForgotSignupCubit>().verifyOTP(
                      verificationId: widget.verificationId,
                      otpCode: value,
                    );
                  },
                ),
                
                // Verify button
                MyAppElevatedButton(
                  title: 'Verify OTP',
                  onPressed: () {
                    context.read<LoginForgotSignupCubit>().verifyOTP(
                      verificationId: widget.verificationId,
                      otpCode: state.otpCode,
                    );
                  },
                ),
                
                // Resend OTP
                TextButton(
                  onPressed: () {
                    context.read<LoginForgotSignupCubit>().resendOTP();
                  },
                  child: Text('Resend OTP'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

## **Analytics Integration**

### **Authentication Events**

```dart
class AuthAnalytics {
  // Track login attempt
  static void logLoginAttempt(String phoneNumber) {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: 'login_attempt',
      parameters: {
        'phone_number': phoneNumber,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Track successful login
  static void logLoginSuccess(String userId) {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: LogEventsName.instance().userLogin,
      parameters: {
        'user_id': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Track signup attempt
  static void logSignupAttempt(String phoneNumber) {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: 'signup_attempt',
      parameters: {
        'phone_number': phoneNumber,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Track successful signup
  static void logSignupSuccess(String userId) {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: LogEventsName.instance().userSignup,
      parameters: {
        'user_id': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Track OTP verification
  static void logOTPVerification(String phoneNumber, bool success) {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: 'otp_verification',
      parameters: {
        'phone_number': phoneNumber,
        'success': success,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Track logout
  static void logLogout(String userId) {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: 'user_logout',
      parameters: {
        'user_id': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}
```

## **Error Handling**

### **Authentication Errors**

```dart
class AuthErrorHandler {
  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      case 'session-expired':
        return 'Session expired. Please try again';
      default:
        return 'Authentication failed. Please try again';
    }
  }
  
  static void handleAuthError(FirebaseAuthException e) {
    AppLogger.e('Authentication error: ${e.code} - ${e.message}');
    
    // Log error to analytics
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: 'auth_error',
      parameters: {
        'error_code': e.code,
        'error_message': e.message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}
```

## **Security Considerations**

### **Phone Number Validation**

```dart
class PhoneNumberValidator {
  static bool isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if phone number is valid (10-15 digits)
    if (cleaned.length < 10 || cleaned.length > 15) {
      return false;
    }
    
    // Additional validation logic
    return true;
  }
  
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Add country code if not present
    if (cleaned.length == 10) {
      return '+91$cleaned'; // Default to India
    }
    
    return '+$cleaned';
  }
}
```

### **Session Management**

```dart
class SessionManager {
  static const Duration sessionTimeout = Duration(hours: 24);
  
  // Check if session is valid
  static bool isSessionValid(DateTime lastActivity) {
    final now = DateTime.now();
    return now.difference(lastActivity) < sessionTimeout;
  }
  
  // Refresh session
  static Future<void> refreshSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.getIdToken(true); // Force refresh
        AppLogger.d('Session refreshed successfully');
      }
    } catch (e) {
      AppLogger.e('Error refreshing session: $e');
    }
  }
  
  // Auto-refresh session
  static void startAutoRefresh() {
    Timer.periodic(Duration(minutes: 30), (timer) {
      refreshSession();
    });
  }
}
```

## **Testing Strategy**

### **Unit Tests**

```dart
group('Authentication System', () {
  test('should validate phone number correctly', () {
    expect(PhoneNumberValidator.isValidPhoneNumber('+919876543210'), true);
    expect(PhoneNumberValidator.isValidPhoneNumber('9876543210'), true);
    expect(PhoneNumberValidator.isValidPhoneNumber('123'), false);
  });
  
  test('should format phone number correctly', () {
    expect(PhoneNumberValidator.formatPhoneNumber('9876543210'), '+919876543210');
    expect(PhoneNumberValidator.formatPhoneNumber('+919876543210'), '+919876543210');
  });
  
  test('should handle authentication errors correctly', () {
    final error = FirebaseAuthException(code: 'invalid-phone-number');
    expect(AuthErrorHandler.getErrorMessage(error), 'Invalid phone number format');
  });
});
```

### **Integration Tests**

1. **OTP Flow**: Test complete OTP verification flow
2. **User Creation**: Test user data creation in Firestore
3. **Session Management**: Test session creation and validation
4. **Error Handling**: Test various error scenarios
5. **Local Storage**: Test data persistence and retrieval

---

*This authentication system documentation provides comprehensive details about the OTP-based authentication flow, user management, and security considerations in Sermon AI.*
