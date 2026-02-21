
import '../firestore_variables.dart';

class UtilityModel {
  final String userId;
  final int totalVideoCount;
  final bool isRecharged;
  final int videoCountToCheckSub;
  final DateTime? rechargeStartDate; // new
  final DateTime? rechargeEndDate; // new
  final bool is30DaysSubscriptionID;

  UtilityModel({
    required this.userId,
    required this.totalVideoCount,
    required this.isRecharged,
    required this.videoCountToCheckSub,
    required this.is30DaysSubscriptionID,
    this.rechargeStartDate,
    this.rechargeEndDate,
  });

  factory UtilityModel.fromJson(Map<String, dynamic> json) {
    return UtilityModel(
      userId: json[FirestoreVariables.userIdField] as String,
      totalVideoCount: json[FirestoreVariables.totalVideoCount] as int,
      isRecharged: json[FirestoreVariables.isRecharged] as bool,
      videoCountToCheckSub:
          json[FirestoreVariables.videoCountToCheckSub] as int,
      rechargeStartDate: json[FirestoreVariables.rechargeStartDate]?.toDate(),
      rechargeEndDate: json[FirestoreVariables.rechargeEndDate]?.toDate(),
      is30DaysSubscriptionID: json[FirestoreVariables.is30DaysSubscriptionID] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirestoreVariables.userIdField: userId,
      FirestoreVariables.totalVideoCount: totalVideoCount,
      FirestoreVariables.isRecharged: isRecharged,
      FirestoreVariables.videoCountToCheckSub: videoCountToCheckSub,
      FirestoreVariables.rechargeStartDate: rechargeStartDate,
      FirestoreVariables.rechargeEndDate: rechargeEndDate,
      FirestoreVariables.is30DaysSubscriptionID: is30DaysSubscriptionID,
    };
  }

  // Convert to Map (for Hive)
  Map<String, dynamic> toMap() {
    return {
      FirestoreVariables.userIdField: userId,
      FirestoreVariables.totalVideoCount: totalVideoCount,
      FirestoreVariables.isRecharged: isRecharged,
      FirestoreVariables.videoCountToCheckSub: videoCountToCheckSub,
      FirestoreVariables.rechargeStartDate: rechargeStartDate,
      FirestoreVariables.rechargeEndDate: rechargeEndDate,
      FirestoreVariables.is30DaysSubscriptionID: is30DaysSubscriptionID,
    };
  }

  // Create from Map
  factory UtilityModel.fromMap(Map<String, dynamic> map) {
    return UtilityModel(
      userId: map[FirestoreVariables.userIdField] as String,
      totalVideoCount: map[FirestoreVariables.totalVideoCount] as int,
      isRecharged: map[FirestoreVariables.isRecharged] as bool,
      videoCountToCheckSub: map[FirestoreVariables.videoCountToCheckSub] as int,
      rechargeStartDate: map[FirestoreVariables.rechargeStartDate]?.toDate(),
      rechargeEndDate: map[FirestoreVariables.rechargeEndDate]?.toDate(),
      is30DaysSubscriptionID: map[FirestoreVariables.is30DaysSubscriptionID] as bool,
    );
  }
}
