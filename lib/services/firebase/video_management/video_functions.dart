import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sermon/services/firebase/firestore_variables.dart';

import '../../../models/video_data_model.dart';

class VideoFunctions {
  //   Future<SectionDetail?> getSliderVideo() async {
  //   final videoCollection = FirebaseFirestore.instance.collection(
  //     'SermonVideosCollection', // new collection name
  //   );

  //   final snapshot = await videoCollection.get();
  //   if (snapshot.docs.isEmpty) return null;

  //   // Find the "Latest Sermons" document
  //   final videoDoc = snapshot.docs.firstWhere(
  //     (doc) => doc.id == 'Latest Sermons',
  //     orElse: () => throw Exception('No slider video found'),
  //   );

  //   final data = videoDoc.data();

  //   // Episodes is stored as List<List<dynamic>>
  //   final episodes = data['Episodes'] as List<dynamic>;

  //   final videos = episodes.map((episode) {
  //     final ep = episode as Map<String, dynamic>;
  //     return VideoDataModel(
  //       thumbnailUrl: ep['thumbnailUrl'] as String,
  //       video: ep['video'] as String,
  //       title: ep['title'] as String,
  //     );
  //   }).toList();

  //   return SectionDetail(
  //     nameOfSection: videoDoc.id,
  //     videos: videos,
  //   );
  // }
  //   Future<List<SectionDetail>> getAllSections() async {
  //   final videoCollection = FirebaseFirestore.instance.collection(
  //     'SermonVideosCollection',
  //   );

  //   final snapshot = await videoCollection.get();
  //   if (snapshot.docs.isEmpty) return [];

  //   return snapshot.docs.map((doc) {
  //     final data = doc.data();
  //     final episodesRaw = data['Episodes'] as List<dynamic>? ?? [];

  //     final videos = episodesRaw.map((episode) {
  //       if (episode is Map<String, dynamic>) {
  //         // Handle Map format
  //         return VideoDataModel(
  //           thumbnailUrl: episode['thumbnailUrl'] as String,
  //           video: episode['video'] as String,
  //           title: episode['title'] as String,
  //         );
  //       } else if (episode is List<dynamic>) {
  //         // Handle List format
  //         return VideoDataModel(
  //           thumbnailUrl: episode[0] as String,
  //           video: episode[1] as String,
  //           title: episode[2] as String,
  //         );
  //       } else {
  //         throw Exception("Invalid episode format in doc ${doc.id}");
  //       }
  //     }).toList();

  //     return SectionDetail(
  //       nameOfSection: doc.id,
  //       videos: videos,
  //     );
  //   }).toList();
  // }

  Stream<List<SectionDetail>> getSectionsStream() {
    final videoCollection = FirebaseFirestore.instance.collection(
      'SermonVideosCollection',
    );

    return videoCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final episodesRaw = data['Episodes'] as List<dynamic>? ?? [];

        final videos = episodesRaw.map((episode) {
          if (episode is Map<String, dynamic>) {
            return VideoDataModel(
              thumbnailUrl: episode['thumbnailUrl'] as String,
              video: episode['video'] as String,
              title: episode['title'] as String,
            );
          } else if (episode is List<dynamic>) {
            return VideoDataModel(
              thumbnailUrl: episode[0] as String,
              video: episode[1] as String,
              title: episode[2] as String,
            );
          } else {
            throw Exception("Invalid episode format in doc ${doc.id}");
          }
        }).toList();

        return SectionDetail(nameOfSection: doc.id, videos: videos);
      }).toList();
    });
  }
}
