import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sermon_tv/services/firebase/firestore_variables.dart';
import 'package:sermon_tv/services/firebase/firebase_remote_config.dart';

import '../../../models/video_data_model.dart';

const defaultVideoCategories = <String>[
  'Latest Sermons',
  'Popular sermons',
  'Sermons on Faith',
  'Sermons on Healing',
  'Sermons on Miracles',
  'Sermons on holyspirit',
  'Sermons on prayer',
];

class VideoFunctions {
  // Old way by SermonVideosCollection
  // This is the old way of getting the sections by the sermon videos collection
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

  // New way by videos collection
  Stream<List<SectionDetail>> cvwgetSectionsByCategoriesStream() {
    // Get category order from Remote Config
    final categories = FirebaseRemoteConfigService().categoryOrder;

    final videosRef = FirebaseFirestore.instance.collection(
      FirestoreVariables.videosCollection,
    );

    final query = videosRef
        .where('category', whereIn: categories)
        .orderBy('createdDate', descending: true);

    return query.snapshots().map((snapshot) {
      // Group docs by category
      final Map<String, List<VideoDataModel>> categoryToVideos = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String?;
        if (category == null) continue;

        final video = VideoDataModel(
          title: (data['title'] ?? '').toString(),
          thumbnailUrl: (data['thumbnail'] ?? '').toString(),
          video: (data['fullVideoLink'] ?? '').toString(),
        );

        (categoryToVideos[category] ??= <VideoDataModel>[]).add(video);
      }

      // Build sections in the Remote Config category order
      final List<SectionDetail> sections = [];
      for (final category in categories) {
        final videos = categoryToVideos[category];
        if (videos == null || videos.isEmpty) continue;
        sections.add(SectionDetail(nameOfSection: category, videos: videos));
      }

      return sections;
    });
  }
}
