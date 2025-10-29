class FirestoreVariables {
  static const String usersCollection = 'Users';
  static const String userIdField = 'USER_ID';
  static const String emailField = 'EMAIL';
  static const String phoneField = 'PHONE_NUMBER';
  static const String nameField = 'NAME';
  static const String subscriptionIdField = 'subscriptionId';
  static const String createdDateField = 'createdDate';

  static const String transactionsCollection = 'Transactions';
  static const String transactionIdField = 'TRANSACTION_ID';
  static const String amountField = 'AMOUNT';
  static const String createdAtField = 'CREATED_AT';
  static const String updatedAtField = 'UPDATED_AT';

  static const String utilitiesCollection = 'Utilities';
  static const String totalVideoCount = 'TOTAL_VIDEO_COUNT';
  static const String isRecharged = 'IS_RECHARGED';
  static const String videoCountToCheckSub = 'VIDEO_COUNT_TO_CHECK_SUB';

  static const String subscriptionCollection = 'subscriptions';
  static const String subscriptionCollectionTest = 'test-subscriptions';
  static const String razorpaySubscriptionIdField = 'razorpaySubscriptionId';
  static const String planIdField = 'planId';
  static const String planTypeField = 'planType';
  static const String customerIdField = 'customerId';
  static const String userIdForSubscription = 'userId';
  static const String statusField = 'status';
  static const String totalCountField = 'totalCount';
  static const String cancelledAtField = 'cancelledAt';
  static const String currentStartField = 'currentStart';
  static const String currentEndField = 'currentEnd';

  static const String videosCollection = 'videos';

  static const String reelsCollection = 'reels';

  static const String rechargeEndDate = 'RECHARGE_END_DATE';
  static const String rechargeStartDate = 'RECHARGE_START_DATE';

  static const int totalVideoCountUserCanSee = 1;
  static const int totalReelCountUserCanSee = 2;
}


enum SubscriptionStatus {
  active,
  payment_captured,
  cancelled,
  nullStatus,
  created
}