import '../firestore_variables.dart';

class UtilityModel {
  final String userId;
  final int totalVideoCount;
  final bool isRecharged;
  final int videoCountToCheckSub;
  final bool isFreeTrialOpted;
  final bool isFreeTrialSubscription;

  // Grace period fields
  final bool isGracePeriodActive;
  final DateTime? gracePeriodStartDate;
  final DateTime? gracePeriodEndDate;
  final String? utilitySubscriptionId;

  UtilityModel({
    required this.userId,
    required this.totalVideoCount,
    required this.isRecharged,
    required this.videoCountToCheckSub,
    required this.isFreeTrialOpted,
    required this.isFreeTrialSubscription,
    this.isGracePeriodActive = false,
    this.gracePeriodStartDate,
    this.gracePeriodEndDate,
    this.utilitySubscriptionId,
  });

  factory UtilityModel.fromJson(Map<String, dynamic> json) {
    return UtilityModel(
      userId: json[FirestoreVariables.userIdField] as String,
      totalVideoCount: json[FirestoreVariables.totalVideoCount] as int,
      isRecharged: json[FirestoreVariables.isRecharged] as bool,
      isFreeTrialSubscription: json[FirestoreVariables.isFreeTrialSubscription] as bool,
      isFreeTrialOpted: json[FirestoreVariables.isFreeTrialOpted] as bool,
      videoCountToCheckSub:
          json[FirestoreVariables.videoCountToCheckSub] as int,
      isGracePeriodActive:
          json[FirestoreVariables.isGracePeriodActive] as bool? ?? false,
      gracePeriodStartDate: json[FirestoreVariables.gracePeriodStartDate]
          ?.toDate(),
      gracePeriodEndDate: json[FirestoreVariables.gracePeriodEndDate]?.toDate(),
      utilitySubscriptionId:
          json[FirestoreVariables.utilitySubscriptionId] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirestoreVariables.userIdField: userId,
      FirestoreVariables.totalVideoCount: totalVideoCount,
      FirestoreVariables.isRecharged: isRecharged,
      FirestoreVariables.videoCountToCheckSub: videoCountToCheckSub,
      FirestoreVariables.isFreeTrialSubscription: isFreeTrialSubscription,
      FirestoreVariables.isFreeTrialOpted: isFreeTrialOpted,
      FirestoreVariables.isGracePeriodActive: isGracePeriodActive,
      FirestoreVariables.gracePeriodStartDate: gracePeriodStartDate,
      FirestoreVariables.gracePeriodEndDate: gracePeriodEndDate,
      FirestoreVariables.utilitySubscriptionId: utilitySubscriptionId,
    };
  }

  // Convert to Map (for Hive)
  Map<String, dynamic> toMap() {
    return {
      FirestoreVariables.userIdField: userId,
      FirestoreVariables.totalVideoCount: totalVideoCount,
      FirestoreVariables.isRecharged: isRecharged,
      FirestoreVariables.videoCountToCheckSub: videoCountToCheckSub,
      FirestoreVariables.isFreeTrialSubscription: isFreeTrialSubscription,
      FirestoreVariables.isFreeTrialOpted: isFreeTrialOpted,
      FirestoreVariables.isGracePeriodActive: isGracePeriodActive,
      FirestoreVariables.gracePeriodStartDate: gracePeriodStartDate,
      FirestoreVariables.gracePeriodEndDate: gracePeriodEndDate,
      FirestoreVariables.utilitySubscriptionId: utilitySubscriptionId,
    };
  }

  // Create from Map
  factory UtilityModel.fromMap(Map<String, dynamic> map) {
    return UtilityModel(
      userId: map[FirestoreVariables.userIdField] as String,
      totalVideoCount: map[FirestoreVariables.totalVideoCount] as int,
      isRecharged: map[FirestoreVariables.isRecharged] as bool,
      isFreeTrialOpted: map[FirestoreVariables.isFreeTrialOpted] as bool,
      isFreeTrialSubscription: map[FirestoreVariables.isFreeTrialSubscription] as bool,
      videoCountToCheckSub: map[FirestoreVariables.videoCountToCheckSub] as int,
      isGracePeriodActive:
          map[FirestoreVariables.isGracePeriodActive] as bool? ?? false,
      gracePeriodStartDate: map[FirestoreVariables.gracePeriodStartDate]
          ?.toDate(),
      gracePeriodEndDate: map[FirestoreVariables.gracePeriodEndDate]?.toDate(),
      utilitySubscriptionId:
          map[FirestoreVariables.utilitySubscriptionId] as String?,
    );
  }
}
