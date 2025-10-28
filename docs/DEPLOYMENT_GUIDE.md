# Sermon AI - Deployment Guide

## **Overview**

This guide covers the deployment process for the Sermon AI Flutter application, including build configuration, environment setup, and release management for both Android and iOS platforms.

## **Build Configuration**

### **Environment Setup**

1. **Debug Environment**
   ```dart
   bool isDebugMode() {
     if (kReleaseMode) {
       return false;
     }
     return false; // Set to true for debug features
   }
   ```

2. **API Configuration**
   ```dart
   String razorPayUrl = isDebugMode() ? 'test' : '';
   String baseUrl = isDebugMode() 
       ? 'https://api-test.sermonai.com' 
       : 'https://api.sermonai.com';
   ```

3. **Firebase Configuration**
   - Debug: Uses test Firebase project
   - Production: Uses production Firebase project

### **Build Variants**

#### **Android Build Configuration**

1. **Debug Build**
   ```bash
   flutter build apk --debug
   ```

2. **Release Build**
   ```bash
   flutter build apk --release
   ```

3. **App Bundle (Recommended for Play Store)**
   ```bash
   flutter build appbundle --release
   ```

4. **Specific Architecture**
   ```bash
   flutter build apk --target-platform android-arm64
   flutter build apk --target-platform android-arm,android-x64
   ```

#### **iOS Build Configuration**

1. **Debug Build**
   ```bash
   flutter build ios --debug
   ```

2. **Release Build**
   ```bash
   flutter build ios --release
   ```

3. **Archive for App Store**
   ```bash
   flutter build ipa --release
   ```

## **Android Deployment**

### **Play Store Configuration**

1. **App Signing**
   ```bash
   # Sign APK with keystore
   jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
     -keystore playstore_things/sermon_ai.jks \
     app-release-unsigned.apk sermon_ai
   
   # Align APK
   zipalign -v 4 app-release-unsigned.apk app-release-signed.apk
   ```

2. **Build Configuration (android/app/build.gradle.kts)**
   ```kotlin
   android {
       compileSdk 34
       
       defaultConfig {
           applicationId "com.sermonai.app"
           minSdk 21
           targetSdk 34
           versionCode 1
           versionName "1.0.0"
       }
       
       signingConfigs {
           create("release") {
               storeFile = file("../playstore_things/sermon_ai.jks")
               storePassword = "sermon_ai"
               keyAlias = "sermon_ai"
               keyPassword = "sermon_ai"
           }
       }
       
       buildTypes {
           getByName("release") {
               isMinifyEnabled = true
               proguardFiles(
                   getDefaultProguardFile("proguard-android-optimize.txt"),
                   "proguard-rules.pro"
               )
               signingConfig = signingConfigs.getByName("release")
           }
       }
   }
   ```

3. **ProGuard Configuration (android/app/proguard-rules.pro)**
   ```proguard
   # Flutter
   -keep class io.flutter.app.** { *; }
   -keep class io.flutter.plugin.** { *; }
   -keep class io.flutter.util.** { *; }
   -keep class io.flutter.view.** { *; }
   -keep class io.flutter.** { *; }
   -keep class io.flutter.plugins.** { *; }
   
   # Firebase
   -keep class com.google.firebase.** { *; }
   -keep class com.google.android.gms.** { *; }
   
   # Razorpay
   -keep class com.razorpay.** { *; }
   ```

### **Play Store Assets**

1. **App Icons**
   - `playstore_things/icon.png` - App icon
   - `playstore_things/feature_graphic.png` - Feature graphic

2. **Screenshots**
   - `playstore_things/1.png` - Screenshot 1
   - `playstore_things/2.png` - Screenshot 2
   - `playstore_things/3.png` - Screenshot 3
   - `playstore_things/4.png` - Screenshot 4

3. **Store Listing**
   - App title: "Sermon AI"
   - Short description: "Christian video streaming platform"
   - Full description: Detailed app description
   - Category: "Entertainment" or "Religion & Spirituality"

### **Release Process**

1. **Pre-release Checklist**
   ```bash
   # Clean build
   flutter clean
   flutter pub get
   
   # Run tests
   flutter test
   
   # Analyze code
   flutter analyze
   
   # Build release
   flutter build appbundle --release
   ```

2. **Upload to Play Console**
   - Go to Google Play Console
   - Navigate to "Release" → "Production"
   - Upload the generated `.aab` file
   - Fill in release notes
   - Submit for review

## **iOS Deployment**

### **App Store Configuration**

1. **Xcode Project Setup**
   ```bash
   # Open iOS project
   open ios/Runner.xcworkspace
   ```

2. **Bundle Identifier**
   - Set in Xcode: `com.sermonai.app`
   - Must match Apple Developer account

3. **Signing Configuration**
   - Development Team: Your Apple Developer Team ID
   - Provisioning Profile: App Store distribution profile
   - Code Signing Identity: iOS Distribution

### **App Store Assets**

1. **App Icons**
   - 1024x1024px for App Store
   - Multiple sizes for app bundle

2. **Screenshots**
   - iPhone 6.7" (iPhone 14 Pro Max)
   - iPhone 6.5" (iPhone 11 Pro Max)
   - iPhone 5.5" (iPhone 8 Plus)

3. **App Store Metadata**
   - App name: "Sermon AI"
   - Subtitle: "Christian Video Streaming"
   - Keywords: "sermon, christian, video, streaming"
   - Category: "Entertainment"

### **Release Process**

1. **Build and Archive**
   ```bash
   # Build iOS app
   flutter build ios --release
   
   # Archive in Xcode
   # Product → Archive
   ```

2. **Upload to App Store Connect**
   - Use Xcode Organizer
   - Upload to App Store Connect
   - Fill in app information
   - Submit for review

## **Firebase Configuration**

### **Production Setup**

1. **Firebase Project Configuration**
   ```dart
   // firebase_options.dart
   class DefaultFirebaseOptions {
     static FirebaseOptions get currentPlatform {
       if (kIsWeb) {
         return web;
       }
       switch (defaultTargetPlatform) {
         case TargetPlatform.android:
           return android;
         case TargetPlatform.iOS:
           return ios;
         default:
           throw UnsupportedError(
             'DefaultFirebaseOptions have not been configured for this platform.',
           );
       }
     }
   }
   ```

2. **Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users can only access their own data
       match /Users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Subscription data access control
       match /subscriptions/{subscriptionId} {
         allow read, write: if request.auth != null && 
           request.auth.uid == resource.data.userId;
       }
       
       // Public content (videos, reels)
       match /Videos/{videoId} {
         allow read: if true;
         allow write: if request.auth != null;
       }
       
       match /reels/{reelId} {
         allow read: if true;
         allow write: if request.auth != null;
       }
     }
   }
   ```

3. **Firebase Analytics**
   ```dart
   // Enable analytics in production
   await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
   ```

### **Environment Variables**

1. **Debug Environment**
   ```dart
   class Environment {
     static const String firebaseProjectId = 'sermon-ai-test';
     static const String razorpayKeyId = 'rzp_test_...';
     static const String apiBaseUrl = 'https://api-test.sermonai.com';
   }
   ```

2. **Production Environment**
   ```dart
   class Environment {
     static const String firebaseProjectId = 'sermon-ai-prod';
     static const String razorpayKeyId = 'rzp_live_...';
     static const String apiBaseUrl = 'https://api.sermonai.com';
   }
   ```

## **CI/CD Pipeline**

### **GitHub Actions Workflow**

1. **Build and Test**
   ```yaml
   name: Build and Test
   
   on:
     push:
       branches: [ main, develop ]
     pull_request:
       branches: [ main ]
   
   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - uses: subosito/flutter-action@v2
           with:
             flutter-version: '3.8.1'
         - run: flutter pub get
         - run: flutter test
         - run: flutter analyze
   
     build-android:
       needs: test
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - uses: subosito/flutter-action@v2
         - run: flutter pub get
         - run: flutter build appbundle --release
         - uses: actions/upload-artifact@v3
           with:
             name: app-release
             path: build/app/outputs/bundle/release/app-release.aab
   ```

2. **Deploy to Play Store**
   ```yaml
   name: Deploy to Play Store
   
   on:
     push:
       tags:
         - 'v*'
   
   jobs:
     deploy:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - uses: subosito/flutter-action@v2
         - run: flutter pub get
         - run: flutter build appbundle --release
         - uses: r0adkll/upload-google-play@v1
           with:
             serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
             packageName: com.sermonai.app
             releaseFiles: build/app/outputs/bundle/release/app-release.aab
             track: production
   ```

### **Automated Testing**

1. **Unit Tests**
   ```bash
   flutter test
   ```

2. **Integration Tests**
   ```bash
   flutter drive --target=test_driver/app.dart
   ```

3. **Widget Tests**
   ```bash
   flutter test test/widget_test.dart
   ```

## **Monitoring and Analytics**

### **Firebase Analytics**

1. **Event Tracking**
   ```dart
   // Track important events
   await FirebaseAnalytics.instance.logEvent(
     name: 'user_subscription',
     parameters: {
       'plan_type': 'monthly',
       'amount': 99,
     },
   );
   ```

2. **User Properties**
   ```dart
   await FirebaseAnalytics.instance.setUserProperty(
     name: 'subscription_status',
     value: 'active',
   );
   ```

### **Crashlytics**

1. **Error Reporting**
   ```dart
   // Already configured in main.dart
   FlutterError.onError = (errorDetails) {
     FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
   };
   ```

2. **Custom Logging**
   ```dart
   FirebaseCrashlytics.instance.log('User performed action: $action');
   ```

### **Performance Monitoring**

1. **Custom Traces**
   ```dart
   final trace = FirebasePerformance.instance.newTrace('video_loading');
   await trace.start();
   
   // Perform operation
   await loadVideo();
   
   await trace.stop();
   ```

## **Release Management**

### **Version Control**

1. **Semantic Versioning**
   - Format: `MAJOR.MINOR.PATCH`
   - Example: `1.0.0`, `1.1.0`, `1.1.1`

2. **Version Updates**
   ```yaml
   # pubspec.yaml
   version: 1.0.0+1
   #           ^  ^
   #           |  +-- Build number
   #           +----- Version name
   ```

3. **Git Tags**
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

### **Release Notes**

1. **Template**
   ```markdown
   ## Version 1.0.0
   
   ### New Features
   - Initial release
   - Sermon reels and full videos
   - Subscription system
   - OTP authentication
   
   ### Bug Fixes
   - Fixed video loading issues
   - Improved error handling
   
   ### Improvements
   - Enhanced user experience
   - Performance optimizations
   ```

2. **Changelog**
   - Keep `CHANGELOG.md` updated
   - Document all changes
   - Include breaking changes

### **Rollback Strategy**

1. **Play Store Rollback**
   - Use Play Console to rollback
   - Deactivate current release
   - Activate previous version

2. **App Store Rollback**
   - Use App Store Connect
   - Remove current version
   - Submit previous version

3. **Firebase Rollback**
   - Revert Firestore rules
   - Update Firebase configuration
   - Monitor for issues

## **Security Considerations**

### **App Signing**

1. **Android Signing**
   - Use secure keystore
   - Backup keystore securely
   - Use different keys for debug/release

2. **iOS Signing**
   - Use Apple Developer certificates
   - Keep certificates secure
   - Renew before expiration

### **API Security**

1. **API Keys**
   - Use environment variables
   - Don't commit keys to repository
   - Rotate keys regularly

2. **Firebase Security**
   - Implement proper Firestore rules
   - Use Firebase App Check
   - Monitor for abuse

### **Data Protection**

1. **User Data**
   - Encrypt sensitive data
   - Follow GDPR/CCPA guidelines
   - Implement data retention policies

2. **Payment Data**
   - Use Razorpay secure integration
   - Don't store payment details
   - Follow PCI compliance

## **Troubleshooting**

### **Common Issues**

1. **Build Failures**
   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

2. **Signing Issues**
   ```bash
   # Check keystore
   keytool -list -v -keystore playstore_things/sermon_ai.jks
   ```

3. **Firebase Issues**
   - Check `google-services.json`
   - Verify Firebase project configuration
   - Check network connectivity

### **Debug Commands**

```bash
# Check Flutter version
flutter --version

# Check dependencies
flutter pub deps

# Analyze code
flutter analyze

# Check device connectivity
flutter devices

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

---

*This deployment guide provides comprehensive instructions for building, configuring, and deploying the Sermon AI Flutter application to production environments.*
