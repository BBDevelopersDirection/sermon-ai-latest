class FirestoreVariables {
  static const String usersCollection = 'Users';
  static const String userIdField = 'USER_ID';
  static const String emailField = 'EMAIL';
  static const String phoneField = 'PHONE_NUMBER';
  static const String nameField = 'NAME';

  static const String transactionsCollection = 'Transactions';
  static const String transactionIdField = 'TRANSACTION_ID';
  static const String amountField = 'AMOUNT';
  static const String createdAtField = 'CREATED_AT';
  static const String updatedAtField = 'UPDATED_AT';

  static const String utilitiesCollection = 'Utilities';
  static const String totalVideoCount = 'TOTAL_VIDEO_COUNT';
  static const String isRecharged = 'IS_RECHARGED';
  static const String videoCountToCheckSub = 'VIDEO_COUNT_TO_CHECK_SUB';

  static const String videosCollection = 'Videos';

  static const String reelsCollection = 'reels';

  static const String rechargeEndDate = 'RECHARGE_END_DATE';
  static const String rechargeStartDate = 'RECHARGE_START_DATE';

  static const int totalVideoCountUserCanSee = 1;
  static const int totalReelCountUserCanSee = 2;
}