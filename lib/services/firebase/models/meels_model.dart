class ReelsModel {
  final String id;
  final String videoId;
  final String fullVideoLink;
  final String reelLink;
  final String category;

  ReelsModel({
    required this.id,
    required this.videoId,
    required this.fullVideoLink,
    required this.reelLink,
    required this.category,
  });

  factory ReelsModel.fromMap(Map<String, dynamic> data) {
    return ReelsModel(
      id: data['id'] ?? '',
      videoId: data['videoId'] ?? '',
      fullVideoLink: data['fullVideoLink'] ?? '',
      reelLink: data['reelLink'] ?? '',
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'videoId': videoId,
      'fullVideoLink': fullVideoLink,
      'reelLink': reelLink,
      'category': category,
    };
  }
}
