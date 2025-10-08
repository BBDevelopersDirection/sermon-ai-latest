import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sermon/services/firebase/models/meels_model.dart';
import 'package:sermon/reusable/logger_service.dart';

class ReelsResult {
  final List<ReelsModel> reels;
  final bool hasMore;
  final String? lastDocId;

  ReelsResult({
    required this.reels,
    required this.hasMore,
    required this.lastDocId,
  });
}

// for fetching some at a tym

class ReelsFirestoreFunctions {
  final _firestore = FirebaseFirestore.instance;

  /// Get total count of reels (so UI can fetch clean multiples)
  Future<int?> getTotalCount() async {
    final snapshot = await _firestore.collection('reels').count().get();
    return snapshot.count;
  }

  Future<ReelsResult> fetchReels({
    required int limit,
    String? startAfterDocId,
  }) async {
  AppLogger.d("🔥 Fetching reels | limit: $limit | startAfterDocId: $startAfterDocId");

    Query query = _firestore.collection('reels').orderBy('createdDate', descending: true).limit(limit);

    if (startAfterDocId != null) {
  AppLogger.d("👉 Getting startAfterDoc: $startAfterDocId");
      final startDoc =
          await _firestore.collection('reels').doc(startAfterDocId).get();
      if (startDoc.exists) {
        query = query.startAfterDocument(startDoc);
  AppLogger.d("✅ startAfterDoc found, continuing query");
      } else {
  AppLogger.w("⚠️ startAfterDoc NOT found in Firestore");
      }
    }

    final snapshot = await query.get();
  AppLogger.d("📦 Query returned ${snapshot.docs.length} docs");

    final reels = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
  AppLogger.d("🎬 Reel fetched: ${doc.id} | data: $data");
      return ReelsModel.fromMap({
        'id': doc.id,
        ...data,
      });
    }).toList();

    final lastDocId =
        snapshot.docs.isNotEmpty ? snapshot.docs.last.id : startAfterDocId;

  AppLogger.d("🔚 Last doc id: $lastDocId | hasMore: ${snapshot.docs.length == limit}");

    return ReelsResult(
      reels: reels,
      hasMore: snapshot.docs.length == limit,
      lastDocId: lastDocId,
    );
  }
}




// class ReelsFirestoreFunctions {
//   final _firestore = FirebaseFirestore.instance;

//   /// Get total count of reels
//   Future<int?> getTotalCount() async {
//     final snapshot = await _firestore.collection('reels').count().get();
//     return snapshot.count;
//   }

//   /// Fetch all reels at once (no pagination)
//   Future<ReelsResult> fetchReels() async {
//     AppLogger.d("🔥 Fetching ALL reels from Firestore");

//     try {
//       final snapshot = await _firestore
//           .collection('reels')
//           .orderBy('createdDate', descending: true)
//           .get();

//       AppLogger.d("📦 Query returned ${snapshot.docs.length} reels");

//       final reels = snapshot.docs.map((doc) {
//         final data = doc.data();
//         AppLogger.d("🎬 Reel fetched: ${doc.id}");
//         return ReelsModel.fromMap({
//           'id': doc.id,
//           ...data,
//         });
//       }).toList();

//       return ReelsResult(
//         reels: reels,
//         hasMore: false, // No pagination
//         lastDocId: snapshot.docs.isNotEmpty ? snapshot.docs.last.id : null,
//       );
//     } catch (e, st) {
//       AppLogger.e("❌ Error fetching reels: $e", st);
//       return ReelsResult(
//         reels: [],
//         hasMore: false,
//         lastDocId: null,
//       );
//     }
//   }
// }
