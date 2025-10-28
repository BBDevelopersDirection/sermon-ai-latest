# Sermon AI - Development Guide

## **Getting Started**

### **Prerequisites**

- **Flutter SDK**: Version 3.8.1 or higher
- **Dart SDK**: Version 3.8.1 or higher
- **Android Studio**: For Android development
- **Xcode**: For iOS development (macOS only)
- **Firebase CLI**: For Firebase configuration
- **Git**: For version control

### **Environment Setup**

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sermon
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Copy `google-services.json` to `android/app/`
   - Copy `GoogleService-Info.plist` to `ios/Runner/`
   - Update `firebase_options.dart` if needed

4. **Run the app**
   ```bash
   flutter run
   ```

## **Project Structure**

### **Directory Organization**

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase configuration
├── models/                           # Data models
├── network/                          # Network layer
├── reusable/                         # Shared components
├── screens/                          # UI screens
├── services/                         # Business logic
└── utils/                           # Utilities
```

### **Key Directories**

- **`models/`**: Data models for API responses and local storage
- **`network/`**: HTTP client configuration and API endpoints
- **`reusable/`**: Shared UI components and utilities
- **`screens/`**: Feature-specific screens organized by user flow
- **`services/`**: Business logic services organized by feature
- **`utils/`**: App-wide utilities and constants

## **Development Guidelines**

### **Code Style**

1. **Follow Dart/Flutter conventions**
   - Use `camelCase` for variables and functions
   - Use `PascalCase` for classes and enums
   - Use `snake_case` for file names

2. **File naming conventions**
   - Screens: `*_screen.dart`
   - Cubits: `*_cubit.dart`
   - States: `*_state.dart`
   - Models: `*_model.dart`
   - Services: `*_service.dart` or `*_functions.dart`

3. **Import organization**
   ```dart
   // External packages
   import 'package:flutter/material.dart';
   import 'package:firebase_auth/firebase_auth.dart';
   
   // Internal services
   import 'package:sermon/services/firebase/firestore_functions.dart';
   
   // Models and utilities
   import 'package:sermon/models/user_model.dart';
   import 'package:sermon/utils/app_color.dart';
   
   // Relative imports
   import 'widgets/custom_widget.dart';
   ```

### **State Management**

1. **Use BLoC pattern consistently**
   ```dart
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
   ```

2. **State classes with Equatable**
   ```dart
   abstract class ExampleState extends Equatable {
     @override
     List<Object?> get props => [];
   }
   ```

3. **Use BlocBuilder and BlocListener appropriately**
   ```dart
   BlocBuilder<ExampleCubit, ExampleState>(
     builder: (context, state) {
       if (state is ExampleLoading) {
         return CircularProgressIndicator();
       }
       return YourWidget();
     },
   )
   ```

### **Error Handling**

1. **Use try-catch blocks for async operations**
   ```dart
   Future<void> loadData() async {
     try {
       final data = await _service.getData();
       // Handle success
     } catch (e) {
       AppLogger.e('Error loading data: $e');
       // Handle error
     }
   }
   ```

2. **Log errors consistently**
   ```dart
   AppLogger.e('Error message: $e');
   AppLogger.d('Debug message');
   AppLogger.i('Info message');
   ```

3. **Handle network errors gracefully**
   ```dart
   try {
     final response = await dio.get('/api/data');
     return response.data;
   } on DioException catch (e) {
     if (e.type == DioExceptionType.connectionTimeout) {
       throw NetworkException('Connection timeout');
     }
     throw NetworkException('Network error: ${e.message}');
   }
   ```

### **Firebase Integration**

1. **Use Firestore collections consistently**
   ```dart
   // Use constants from FirestoreVariables
   await FirebaseFirestore.instance
       .collection(FirestoreVariables.usersCollection)
       .doc(userId)
       .set(userData);
   ```

2. **Handle Firestore errors**
   ```dart
   try {
     await FirebaseFirestore.instance
         .collection('collection')
         .doc('doc')
         .set(data);
   } catch (e) {
     AppLogger.e('Firestore error: $e');
     throw Exception('Failed to save data');
   }
   ```

3. **Use offline persistence**
   ```dart
   // Already configured in main.dart
   FirebaseFirestore.instance.settings = const Settings(
     persistenceEnabled: true,
     cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
   );
   ```

## **Testing Guidelines**

### **Unit Testing**

1. **Test business logic**
   ```dart
   group('UserCubit', () {
     late UserCubit userCubit;
     late MockUserRepository mockRepository;
     
     setUp(() {
       mockRepository = MockUserRepository();
       userCubit = UserCubit(mockRepository);
     });
     
     test('should emit loading then loaded state', () async {
       // Arrange
       when(mockRepository.getUser(any)).thenAnswer((_) async => mockUser);
       
       // Act
       userCubit.loadUser('123');
       
       // Assert
       expect(userCubit.state, isA<UserLoading>());
       await expectLater(userCubit.stream, emits(isA<UserLoaded>()));
     });
   });
   ```

2. **Test data models**
   ```dart
   test('should parse user model correctly', () {
     final json = {'id': '123', 'name': 'John'};
     final user = UserModel.fromJson(json);
     expect(user.id, '123');
     expect(user.name, 'John');
   });
   ```

### **Widget Testing**

1. **Test UI components**
   ```dart
   testWidgets('should display user name', (tester) async {
     await tester.pumpWidget(
       MaterialApp(
         home: UserWidget(user: mockUser),
       ),
     );
     
     expect(find.text('John'), findsOneWidget);
   });
   ```

2. **Test user interactions**
   ```dart
   testWidgets('should call onTap when button is pressed', (tester) async {
     bool tapped = false;
     
     await tester.pumpWidget(
       MaterialApp(
         home: ElevatedButton(
           onPressed: () => tapped = true,
           child: Text('Tap me'),
         ),
       ),
     );
     
     await tester.tap(find.text('Tap me'));
     expect(tapped, true);
   });
   ```

### **Integration Testing**

1. **Test complete user flows**
   ```dart
   testWidgets('should complete login flow', (tester) async {
     await tester.pumpWidget(MyApp());
     
     // Enter phone number
     await tester.enterText(find.byType(TextField), '9876543210');
     await tester.tap(find.text('Send OTP'));
     await tester.pumpAndSettle();
     
     // Enter OTP
     await tester.enterText(find.byType(TextField), '123456');
     await tester.tap(find.text('Verify'));
     await tester.pumpAndSettle();
     
     // Verify navigation
     expect(find.byType(HomeScreen), findsOneWidget);
   });
   ```

## **Performance Optimization**

### **Memory Management**

1. **Dispose controllers properly**
   ```dart
   @override
   void dispose() {
     _controller.dispose();
     _streamSubscription.cancel();
     super.dispose();
   }
   ```

2. **Use const constructors**
   ```dart
   const MyWidget({
     Key? key,
     required this.title,
   }) : super(key: key);
   ```

3. **Optimize list rendering**
   ```dart
   ListView.builder(
     itemCount: items.length,
     itemBuilder: (context, index) {
       return ListTile(
         key: ValueKey(items[index].id),
         title: Text(items[index].title),
       );
     },
   )
   ```

### **Network Optimization**

1. **Use connection pooling**
   ```dart
   final dio = Dio(BaseOptions(
     connectTimeout: Duration(seconds: 30),
     receiveTimeout: Duration(seconds: 30),
     sendTimeout: Duration(seconds: 30),
   ));
   ```

2. **Implement retry logic**
   ```dart
   Future<T> retryOperation<T>(Future<T> Function() operation) async {
     int retryCount = 0;
     while (retryCount < 3) {
       try {
         return await operation();
       } catch (e) {
         retryCount++;
         if (retryCount >= 3) throw e;
         await Future.delayed(Duration(seconds: retryCount));
       }
     }
     throw Exception('Max retries exceeded');
   }
   ```

### **Image Optimization**

1. **Use cached network images**
   ```dart
   CachedNetworkImage(
     imageUrl: imageUrl,
     placeholder: (context, url) => CircularProgressIndicator(),
     errorWidget: (context, url, error) => Icon(Icons.error),
   )
   ```

2. **Optimize image sizes**
   ```dart
   Image.network(
     imageUrl,
     width: 100,
     height: 100,
     fit: BoxFit.cover,
   )
   ```

## **Debugging**

### **Logging**

1. **Use structured logging**
   ```dart
   AppLogger.d('User login attempt: ${user.phoneNumber}');
   AppLogger.e('Payment failed: ${error.message}');
   AppLogger.i('Video loaded: ${video.id}');
   ```

2. **Log important events**
   ```dart
   // Log user actions
   MyAppAmplitudeAndFirebaseAnalitics().logEvent(
     event: 'user_action',
     parameters: {'action': 'button_click', 'screen': 'home'},
   );
   ```

### **Debug Tools**

1. **Use Flutter Inspector**
   - Widget tree inspection
   - Performance profiling
   - Memory usage analysis

2. **Use Firebase DebugView**
   - Real-time event monitoring
   - User journey tracking
   - Performance metrics

3. **Use Dart DevTools**
   - CPU profiling
   - Memory allocation tracking
   - Network monitoring

## **Code Review Guidelines**

### **Review Checklist**

1. **Code Quality**
   - [ ] Follows Dart/Flutter conventions
   - [ ] Proper error handling
   - [ ] Memory management
   - [ ] Performance considerations

2. **Architecture**
   - [ ] Follows BLoC pattern
   - [ ] Proper separation of concerns
   - [ ] Reusable components
   - [ ] Consistent naming

3. **Testing**
   - [ ] Unit tests for business logic
   - [ ] Widget tests for UI components
   - [ ] Integration tests for user flows
   - [ ] Error scenario testing

4. **Security**
   - [ ] Input validation
   - [ ] Secure data handling
   - [ ] Authentication checks
   - [ ] Error message sanitization

### **Common Issues to Avoid**

1. **Memory leaks**
   - Not disposing controllers
   - Not canceling streams
   - Holding references to disposed objects

2. **Performance issues**
   - Unnecessary rebuilds
   - Heavy operations in build methods
   - Large widget trees

3. **Security vulnerabilities**
   - Exposing sensitive data
   - Not validating inputs
   - Insecure data storage

## **Deployment**

### **Build Configuration**

1. **Debug build**
   ```bash
   flutter build apk --debug
   flutter build ios --debug
   ```

2. **Release build**
   ```bash
   flutter build apk --release
   flutter build ios --release
   ```

3. **App bundle (Android)**
   ```bash
   flutter build appbundle --release
   ```

### **Environment Configuration**

1. **Debug configuration**
   ```dart
   bool isDebugMode() {
     if (kReleaseMode) {
       return false;
     }
     return false; // Set to true for debug features
   }
   ```

2. **API endpoints**
   ```dart
   String razorPayUrl = isDebugMode() ? 'test' : '';
   ```

### **Release Checklist**

1. **Pre-release**
   - [ ] All tests passing
   - [ ] Code review completed
   - [ ] Performance testing done
   - [ ] Security review completed

2. **Build**
   - [ ] Version number updated
   - [ ] Release notes prepared
   - [ ] Build artifacts generated
   - [ ] Signing configuration verified

3. **Deployment**
   - [ ] Play Store/App Store upload
   - [ ] Release notes published
   - [ ] Monitoring enabled
   - [ ] Rollback plan prepared

## **Troubleshooting**

### **Common Issues**

1. **Build failures**
   - Check Flutter version compatibility
   - Verify dependency versions
   - Clean build cache: `flutter clean`

2. **Runtime errors**
   - Check Firebase configuration
   - Verify network connectivity
   - Review error logs

3. **Performance issues**
   - Profile with Flutter Inspector
   - Check memory usage
   - Optimize image loading

### **Debug Commands**

```bash
# Clean build
flutter clean
flutter pub get

# Check dependencies
flutter pub deps

# Analyze code
flutter analyze

# Run tests
flutter test

# Build for specific platform
flutter build apk --target-platform android-arm64
```

---

*This development guide provides comprehensive guidelines for developing, testing, and deploying the Sermon AI Flutter application.*
