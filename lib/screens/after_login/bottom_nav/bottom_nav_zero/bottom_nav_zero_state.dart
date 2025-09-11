import 'package:equatable/equatable.dart';
import 'package:sermon/services/firebase/models/meels_model.dart';

class BottomNavZeroState extends Equatable {
  final List<ReelsModel> reels;
  final bool isLoading;
  final bool hasMore;
  final String? lastDocId;
  final int? totalDocs; // ✅

  const BottomNavZeroState({
    this.reels = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.lastDocId,
    this.totalDocs,
  });

  BottomNavZeroState copyWith({
    List<ReelsModel>? reels,
    bool? isLoading,
    bool? hasMore,
    String? lastDocId,
    int? totalDocs,
  }) {
    return BottomNavZeroState(
      reels: reels ?? this.reels,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      lastDocId: lastDocId ?? this.lastDocId,
      totalDocs: totalDocs ?? this.totalDocs,
    );
  }

  @override
  List<Object?> get props => [reels, isLoading, hasMore, lastDocId, totalDocs];
}
