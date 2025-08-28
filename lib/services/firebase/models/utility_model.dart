import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_variables.dart';

class UtilityModel {
  final String userId;
  final int totalVideoCount;
  final bool isRecharged;
  final int videoCountToCheckSub;
  final DateTime? rechargeStartDate; // new
  final DateTime? rechargeEndDate;   // new

  UtilityModel({
    required this.userId,
    required this.totalVideoCount,
    required this.isRecharged,
    required this.videoCountToCheckSub,
    this.rechargeStartDate,
    this.rechargeEndDate,
  });

  factory UtilityModel.fromJson(Map<String, dynamic> json) {
    return UtilityModel(
      userId: json[FirestoreVariables.userIdField] as String,
      totalVideoCount: json[FirestoreVariables.totalVideoCount] as int,
      isRecharged: json[FirestoreVariables.isRecharged] as bool,
      videoCountToCheckSub: json[FirestoreVariables.videoCountToCheckSub] as int,
      rechargeStartDate: json[FirestoreVariables.rechargeStartDate]?.toDate(),
      rechargeEndDate: json[FirestoreVariables.rechargeEndDate]?.toDate(),
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
    );
  }
}
