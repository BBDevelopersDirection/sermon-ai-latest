import 'package:apivideo_player/apivideo_player.dart';
import 'package:flutter/material.dart';

class HlcPlayer extends StatelessWidget {
  String videoId;
  HlcPlayer({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    return ApiVideoPlayer(
      controller: ApiVideoPlayerController(
        videoOptions: VideoOptions(videoId: videoId),
      ),
    );
  }
}
