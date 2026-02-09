import 'package:apivideo_player/apivideo_player.dart';
import 'package:flutter/material.dart';

class HlcVideoPlayerUsingId extends StatelessWidget {
  String videoId;
  HlcVideoPlayerUsingId({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    print('video id is: ${videoId}');
    return SizedBox();
    // return PlayerWidget(controller: ApiVideoPlayerController(videoOptions: VideoOptions(videoId: videoId), autoplay: true),);
  }
}


// class PlayerWidget extends StatefulWidget {
//   const PlayerWidget({
//     super.key,
//     required this.controller,
//   });

//   final ApiVideoPlayerController controller;

//   @override
//   State<PlayerWidget> createState() => _PlayerWidgetState();
// }

// class _PlayerWidgetState extends State<PlayerWidget> {
//   String _currentTime = 'Get current time';
//   String _duration = 'Get duration';
//   bool _hideControls = false;

//   @override
//   void initState() {
//     super.initState();
//     widget.controller.initialize();
//     widget.controller.addListener(ApiVideoPlayerControllerEventsListener(
//       onReady: () {
//         setState(() {
//           _duration = 'Get duration';
//         });
//       },
//     ));
//   }

//   @override
//   void dispose() {
//     widget.controller.dispose();
//     super.dispose();
//   }

//   void _toggleLooping() {
//     widget.controller.isLooping.then(
//       (bool isLooping) {
//         widget.controller.setIsLooping(!isLooping);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Your video is ${isLooping ? 'not on loop anymore' : 'on loop'}.',
//             ),
//             backgroundColor: Colors.blueAccent,
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SizedBox(
//             width: double.infinity,
//             height: double.infinity,
//             child: ApiVideoPlayer(
//                     controller: widget.controller,
//                     style: PlayerStyle(controlsBarStyle: ControlsBarStyle())),
//           ),
//     );}
// }

class ReelVideoPlayer extends StatefulWidget {
  final ApiVideoPlayerController controller;

  const ReelVideoPlayer({
    super.key,
    required this.controller,
  });

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  bool _showIcon = false;
  bool _isPlaying = true;

  Future<void> _togglePlayPause() async {
    final playing = await widget.controller.isPlaying;

    if (playing) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }

    setState(() {
      _isPlaying = !playing;
      _showIcon = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showIcon = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _togglePlayPause,
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// 🎥 api.video player (NO CONTROLS)
            ApiVideoPlayer(
              controller: widget.controller,
              fit: BoxFit.cover,
              style: PlayerStyle(
    controlsBarStyle: null,
    settingsBarStyle: null,
    timeSliderStyle: null,
  ),
            ),

            /// ▶️ Center Play / Pause icon
            if (_showIcon)
              Center(
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 80,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
