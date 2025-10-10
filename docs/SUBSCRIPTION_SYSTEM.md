# Sermon AI - Subscription System Documentation

## **Overview**

The Sermon AI subscription system implements a freemium model where users can watch 2 reels for free before being prompted to subscribe. The system integrates with Razorpay for payment processing and Firebase for subscription management.

## **Subscription Model**

### **Freemium Access**
- **Free Users**: Can watch 2 reels without subscription
- **Premium Users**: Unlimited access to all reels and full videos
- **Trial Period**: 7-day free trial available for new users
- **Paywall Trigger**: After 2 reels, users are redirected to subscription screen

### **Subscription Tiers**
- **Monthly Plan**: Recurring monthly subscription
- **Plan ID**: 
  - Test: `plan_Qwe6q0fZBLxs0L`
  - Production: `plan_RLVhblLvuxHbFc`
- **Total Count**: 12 months
- **Start Date**: 7 days (trial period)

## **Technical Implementation**

### **Subscription Status Enum**

```dart
enum SubscriptionStatus {
  active,                    // Active subscription
  payment_captured,         // Payment successfully captured
  cancelled,                // Subscription cancelled
  nullStatus,               // No subscription
  created,                  // Subscription created but not active
  subscription_authenticated, // Subscription authenticated
}
```

### **Subscription Data Model**

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
```

## **Subscription Validation Logic**

### **Access Control Implementation**

```dart
class UtilsFunctions {
  // Check if user can access a specific reel
  Future<bool> canUseReel({required int index}) async {
    // Get user subscription status
    final subscription = await getSubscriptionStatus();
    
    // Check if user has active subscription
    if (subscription?.status == SubscriptionStatus.active) {
      return true;
    }
    
    // Check if user is within free limit
    if (index <= FirestoreVariables.totalReelCountUserCanSee) {
      return true;
    }
    
    // Check trial period
    if (await isWithinTrialPeriod()) {
      return true;
    }
    
    return false;
  }
  
  // Check if user is within trial period
  Future<bool> isWithinTrialPeriod() async {
    final user = await getUserData();
    if (user?.isFreeTrialOpted == true && user?.isFreeTrialCompleted == false) {
      final trialStart = user?.trialStartDate;
      if (trialStart != null) {
        final now = await getNetworkTime() ?? DateTime.now();
        final trialEnd = trialStart.add(Duration(days: 7));
        return now.isBefore(trialEnd);
      }
    }
    return false;
  }
}
```

### **Paywall Trigger Logic**

```dart
// In BottomNavZeroScreen
onPageChanged: (index) async {
  // If scrolling beyond allowed free index
  if (index > _maxFreeIndex) {
    var canUseVideo = await UtilsFunctions().canUseReel(index: index);
    
    if (!canUseVideo) {
      // Log subscription attempt
      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().subscribePageByReels,
      );
      
      // Snap back to last free index
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _maxFreeIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
      
      // Navigate to subscription screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => PlanPurchaseCubit(),
            child: SubscriptionTrialScreen(
              controller: _controllers[_maxFreeIndex],
            ),
          ),
        ),
      );
    }
  }
}
```

## **Razorpay Integration**

### **Payment Service Implementation**

```dart
class RazorpayService {
  final Razorpay _razorpay = Razorpay();
  
  RazorpayService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  
  void openCheckout({
    required String apiKey,
    required String subscriptionId,
    required Future<void> Function() onSuccess,
  }) {
    var options = {
      "key": apiKey,
      "subscription_id": subscriptionId,
      "recurring": true,
      'method': 'wallet',
      "name": "SermonTV",
      "description": 'Recharge Plan Activation',
      'theme': {'color': '#1F20D6'},
    };
    
    try {
      _razorpay.open(options);
    } catch (e) {
      AppLogger.e('Razorpay error: $e');
    }
  }
}
```

### **Payment Flow**

1. **Customer Creation**
   ```dart
   Future<Response> createCustomer({required FirebaseUser firebaseUser}) async {
     var data = {
       'name': firebaseUser.name,
       'email': firebaseUser.email == '' 
           ? firebaseUser.uid.toGmail() 
           : firebaseUser.email,
       'contact': firebaseUser.phoneNumber,
       'userId': firebaseUser.uid,
     };
     
     return await MyAppDio.instance().post(
       '/$razorPayUrl/create-customer',
       data: data,
     );
   }
   ```

2. **Subscription Creation**
   ```dart
   Future<Response> createSubscription({
     required RazorpayCustomerResponse razorpayCustomerResponse,
   }) async {
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
     
     return await MyAppDio.instance().post(
       '/$razorPayUrl/create-subscription',
       data: data,
     );
   }
   ```

3. **Payment Success Handling**
   ```dart
   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
     final String transactionId = response.paymentId ?? const Uuid().v4();
     
     // Record transaction in Firestore
     TransistionFirestoreFunctions().newFirebaseTransitionData(
       firebaseTransition: TransactionModelFirebase(
         transactionId: transactionId,
         amount: money,
         createdAt: DateTime.now().toString(),
         updatedAt: DateTime.now().add(Duration(days: 30)).toString(),
         userId: FirebaseAuth.instance.currentUser?.uid ?? HiveBoxFunctions().getUuid(),
       ),
     );
     
     await _onSuccessCallback();
   }
   ```

## **Firestore Integration**

### **Subscription Collection Structure**

```dart
// Firestore collection: 'subscriptions' (production) or 'test-subscriptions' (test)
{
  "userId": "user_uid",
  "subscriptionId": "internal_subscription_id",
  "razorpaySubscriptionId": "razorpay_subscription_id",
  "planId": "plan_RLVhblLvuxHbFc",
  "planType": "monthly",
  "customerId": "razorpay_customer_id",
  "status": "active",
  "totalCount": 12,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "cancelledAt": null,
  "currentStart": "2024-01-01T00:00:00Z",
  "currentEnd": "2024-02-01T00:00:00Z"
}
```

### **Subscription Status Checking**

```dart
class SubscriptionFirestoreFunctions {
  // Get user subscription status
  Future<SubscriptionCollectionOfUser?> getSubscriptionStatus(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestoreVariables.subscriptionCollection)
          .where(FirestoreVariables.userIdForSubscription, isEqualTo: userId)
          .limit(1)
          .get();
      
      if (doc.docs.isNotEmpty) {
        return SubscriptionCollectionOfUser.fromJson(doc.docs.first.data());
      }
      return null;
    } catch (e) {
      AppLogger.e('Error getting subscription status: $e');
      return null;
    }
  }
  
  // Update subscription status
  Future<void> updateSubscriptionStatus(
    String userId, 
    SubscriptionCollectionOfUser subscription
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirestoreVariables.subscriptionCollection)
          .doc(userId)
          .set(subscription.toJson());
    } catch (e) {
      AppLogger.e('Error updating subscription status: $e');
    }
  }
}
```

## **Trial Period Management**

### **Trial Period Logic**

```dart
class UserTrialManagement {
  // Check if user is eligible for trial
  Future<bool> isEligibleForTrial(String userId) async {
    final user = await getUserData(userId);
    return user?.isFreeTrialOpted != true;
  }
  
  // Start trial period
  Future<void> startTrialPeriod(String userId) async {
    final now = DateTime.now();
    await updateUserData(userId, {
      'isFreeTrialOpted': true,
      'isFreeTrialCompleted': false,
      'trialStartDate': now.toIso8601String(),
    });
  }
  
  // Complete trial period
  Future<void> completeTrialPeriod(String userId) async {
    await updateUserData(userId, {
      'isFreeTrialCompleted': true,
      'trialEndDate': DateTime.now().toIso8601String(),
    });
  }
}
```

## **Analytics Integration**

### **Subscription Events**

```dart
class SubscriptionAnalytics {
  // Track subscription attempt
  static void logSubscriptionAttempt() {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: LogEventsName.instance().subscribePageByReels,
    );
  }
  
  // Track subscription success
  static void logSubscriptionSuccess(String planType) {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: 'subscription_success',
      parameters: {'plan_type': planType},
    );
  }
  
  // Track subscription failure
  static void logSubscriptionFailure(String reason) {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: LogEventsName.instance().subscriptionFailEvent,
      parameters: {'failure_reason': reason},
    );
  }
  
  // Track trial start
  static void logTrialStart() {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: 'trial_started',
    );
  }
}
```

## **Error Handling**

### **Subscription Error Scenarios**

1. **Payment Failure**
   ```dart
   void _handlePaymentError(PaymentFailureResponse response) async {
     AppLogger.e("Payment Error: ${response.code} - ${response.message}");
     
     // Record failed transaction
     TransistionFirestoreFunctions().newFirebaseTransitionData(
       firebaseTransition: TransactionModelFirebase(
         transactionId: const Uuid().v4(),
         amount: -1, // Negative amount indicates failure
         createdAt: DateTime.now().toString(),
         updatedAt: DateTime.now().add(Duration(days: 30)).toString(),
         userId: FirebaseAuth.instance.currentUser?.uid ?? HiveBoxFunctions().getUuid(),
       ),
     );
     
     // Log analytics event
     MyAppAmplitudeAndFirebaseAnalitics().logEvent(
       event: LogEventsName.instance().subscriptionFailEvent,
     );
   }
   ```

2. **Network Time Sync**
   ```dart
   Future<DateTime?> getNetworkTime() async {
     try {
       final response = await Dio().get(
         'http://worldtimeapi.org/api/timezone/Etc/UTC',
       );
       
       if (response.statusCode == 200 && response.data != null) {
         final data = response.data;
         if (data['utc_datetime'] != null) {
           return DateTime.parse(data['utc_datetime']);
         }
       }
     } catch (e) {
       AppLogger.e('⚠️ Failed to fetch network time: $e');
     }
     
     return null; // fallback to local time
   }
   ```

## **Security Considerations**

### **Subscription Validation**

1. **Server-side Validation**: All subscription status checks should be validated server-side
2. **Time Synchronization**: Use network time to prevent local time manipulation
3. **Payment Verification**: Verify payment status with Razorpay webhooks
4. **Access Control**: Implement proper Firestore security rules

### **Firestore Security Rules**

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
    
    // Transaction data access control
    match /Transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

## **Testing Strategy**

### **Unit Tests**

```dart
group('Subscription System', () {
  test('should allow free users to watch 2 reels', () async {
    final utils = UtilsFunctions();
    expect(await utils.canUseReel(index: 0), true);
    expect(await utils.canUseReel(index: 1), true);
    expect(await utils.canUseReel(index: 2), false);
  });
  
  test('should allow subscribed users unlimited access', () async {
    final utils = UtilsFunctions();
    // Mock active subscription
    when(utils.getSubscriptionStatus()).thenReturn(
      SubscriptionCollectionOfUser(
        uid: 'test_user',
        status: SubscriptionStatus.active,
      ),
    );
    
    expect(await utils.canUseReel(index: 10), true);
  });
});
```

### **Integration Tests**

1. **Payment Flow Testing**: Test complete payment flow with Razorpay test mode
2. **Subscription Status Testing**: Verify subscription status updates in Firestore
3. **Trial Period Testing**: Test trial period logic and expiration
4. **Access Control Testing**: Verify paywall triggers correctly

---

*This subscription system documentation provides comprehensive details about the freemium model implementation, payment integration, and access control mechanisms in Sermon AI.*
