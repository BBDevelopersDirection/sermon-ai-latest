import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sermon/services/firebase/models/meels_model.dart';

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

// class ReelsFirestoreFunctions {
//   final _firestore = FirebaseFirestore.instance;

//   Future<ReelsResult> fetchReels({
//     required int limit,
//     String? startAfterDocId,
//   }) async {
//     Query query = _firestore.collection('reels').limit(limit);

//     if (startAfterDocId != null) {
//       final startDoc =
//           await _firestore.collection('reels').doc(startAfterDocId).get();
//       if (startDoc.exists) {
//         query = query.startAfterDocument(startDoc);
//       }
//     }

//     final snapshot = await query.get();

//     final reels = snapshot.docs.map((doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       return ReelsModel.fromMap({
//         'id': doc.id,
//         ...data,
//       });
//     }).toList();

//     final lastDocId =
//         snapshot.docs.isNotEmpty ? snapshot.docs.last.id : startAfterDocId;

//     return ReelsResult(
//       reels: reels,
//       hasMore: snapshot.docs.length == limit,
//       lastDocId: lastDocId,
//     );
//   }
// }



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
    print("🔥 Fetching reels | limit: $limit | startAfterDocId: $startAfterDocId");

    Query query = _firestore.collection('reels').limit(limit);

    if (startAfterDocId != null) {
      print("👉 Getting startAfterDoc: $startAfterDocId");
      final startDoc =
          await _firestore.collection('reels').doc(startAfterDocId).get();
      if (startDoc.exists) {
        query = query.startAfterDocument(startDoc);
        print("✅ startAfterDoc found, continuing query");
      } else {
        print("⚠️ startAfterDoc NOT found in Firestore");
      }
    }

    final snapshot = await query.get();
    print("📦 Query returned ${snapshot.docs.length} docs");

    final reels = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      print("🎬 Reel fetched: ${doc.id} | data: $data");
      return ReelsModel.fromMap({
        'id': doc.id,
        ...data,
      });
    }).toList();

    final lastDocId =
        snapshot.docs.isNotEmpty ? snapshot.docs.last.id : startAfterDocId;

    print("🔚 Last doc id: $lastDocId | hasMore: ${snapshot.docs.length == limit}");

    return ReelsResult(
      reels: reels,
      hasMore: snapshot.docs.length == limit,
      lastDocId: lastDocId,
    );
  }
}

