import '../firestore_variables.dart';

class SubscriptionCollectionOfUser {
  final String uid;

  // Subscription-related fields
  final String? subscriptionId;
  final String? razorpaySubscriptionId;
  final String? planId;
  final String? planType;
  final String? customerId;
  final SubscriptionStatus status;

  final int? totalCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;
  final DateTime? currentStart;
  final DateTime? currentEnd;

  SubscriptionCollectionOfUser({
    required this.uid,
    this.subscriptionId,
    this.razorpaySubscriptionId,
    this.planId,
    this.planType,
    this.customerId,
    required this.status,
    this.totalCount,
    this.createdAt,
    this.updatedAt,
    this.cancelledAt,
    this.currentStart,
    this.currentEnd,
  });

  factory SubscriptionCollectionOfUser.fromJson(Map<String, dynamic> json) {
    var status = json[FirestoreVariables.statusField] as String?;
    SubscriptionStatus statusEnum = SubscriptionStatus.nullStatus;
    if (status == null) {
      statusEnum = SubscriptionStatus.nullStatus;
    } else if (status == 'active') {
      statusEnum = SubscriptionStatus.active;
    } else if (status == 'payment_captured') {
      statusEnum = SubscriptionStatus.payment_captured;
    } else if (status == 'cancelled') {
      statusEnum = SubscriptionStatus.cancelled;
    } else if (status == 'created'){
      statusEnum = SubscriptionStatus.created;
    }

    return SubscriptionCollectionOfUser(
      uid: json[FirestoreVariables.userIdForSubscription] as String,
      razorpaySubscriptionId:
          json[FirestoreVariables.razorpaySubscriptionIdField] as String?,
      planId: json[FirestoreVariables.planIdField] as String?,
      planType: json[FirestoreVariables.planTypeField] as String?,
      customerId: json[FirestoreVariables.customerIdField] as String?,
      status: statusEnum,
      totalCount: json[FirestoreVariables.totalCountField] as int?,
      createdAt: json[FirestoreVariables.createdAtField] != null
          ? DateTime.tryParse(
              json[FirestoreVariables.createdAtField].toString(),
            )
          : null,
      updatedAt: json[FirestoreVariables.updatedAtField] != null
          ? DateTime.tryParse(
              json[FirestoreVariables.updatedAtField].toString(),
            )
          : null,
      cancelledAt: json[FirestoreVariables.cancelledAtField] != null
          ? DateTime.tryParse(
              json[FirestoreVariables.cancelledAtField].toString(),
            )
          : null,
      currentStart: json[FirestoreVariables.currentStartField] != null
          ? DateTime.tryParse(
              json[FirestoreVariables.currentStartField].toString(),
            )
          : null,
      currentEnd: json[FirestoreVariables.currentEndField] != null
          ? DateTime.tryParse(
              json[FirestoreVariables.currentEndField].toString(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirestoreVariables.userIdField: uid,
      FirestoreVariables.subscriptionIdField: subscriptionId,
      FirestoreVariables.razorpaySubscriptionIdField: razorpaySubscriptionId,
      FirestoreVariables.planIdField: planId,
      FirestoreVariables.planTypeField: planType,
      FirestoreVariables.customerIdField: customerId,
      FirestoreVariables.statusField: status,
      FirestoreVariables.totalCountField: totalCount,
      FirestoreVariables.createdAtField: createdAt?.toIso8601String(),
      FirestoreVariables.updatedAtField: updatedAt?.toIso8601String(),
      FirestoreVariables.cancelledAtField: cancelledAt?.toIso8601String(),
      FirestoreVariables.currentStartField: currentStart?.toIso8601String(),
      FirestoreVariables.currentEndField: currentEnd?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory SubscriptionCollectionOfUser.fromMap(Map<String, dynamic> map) =>
      SubscriptionCollectionOfUser.fromJson(map);
}
