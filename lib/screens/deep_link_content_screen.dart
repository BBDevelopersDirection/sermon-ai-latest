import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sermon/reusable/logger_service.dart';
import 'package:sermon/reusable/video_player_using_id.dart';
import 'package:sermon/services/firebase/models/meels_model.dart';
import 'package:sermon/services/firebase/reels_management/reels_functions.dart';
import 'package:sermon/services/log_service/log_service.dart';
import 'package:sermon/services/log_service/log_variables.dart';
import 'package:sermon/services/reel_video_download.dart';
import 'package:sermon/services/token_check_service/login_check_cubit.dart';
import 'package:sermon/services/token_check_service/login_check_screen.dart';
import 'package:sermon/utils/app_assets.dart';
import 'package:sermon/utils/app_color.dart';
import 'package:video_player/video_player.dart';

class DeepLinkContentScreen extends StatefulWidget {
  final String deepLinkContent;
  final bool isFromSplash;

  const DeepLinkContentScreen({
    required this.deepLinkContent,
    required this.isFromSplash,
    super.key,
  });

  @override
  State<DeepLinkContentScreen> createState() => _DeepLinkContentScreenState();
}

class _DeepLinkContentScreenState extends State<DeepLinkContentScreen> {
  bool _isLoading = true;
  late ReelsModel _reelsModel;
  @override
  initState() {
    super.initState();
    _fetchReel();
    _eventTracking();
  }

  Future<void> _fetchReel() async {
    setState(() {
      _isLoading = true;
    });
    final reel = await ReelsFirestoreFunctions().getReelById(
      reelId: widget.deepLinkContent,
    );
    if (reel != null) {
      // Handle the fetched reel data as needed
      _reelsModel = reel;
    } else {
      _navigateBack();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _eventTracking() async {
    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: LogEventsName.instance().shared_reel_watched,
    );
  }

  void _navigateBack() {
    if (widget.isFromSplash) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginCheckScreen(isLoginOrRegesterFlow: false),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevent default pop
      onPopInvoked: (didPop) {
        if (didPop) return;
        _navigateBack();
      },
      child: Scaffold(
        backgroundColor: MyAppColor.background,
        body: Stack(
          children: [
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ReelVideoPlayer(reelsModel: _reelsModel),
            ),

            /// 🔙 Back button inside body
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: _navigateBack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReelVideoPlayer extends StatefulWidget {
  final ReelsModel reelsModel;

  const ReelVideoPlayer({super.key, required this.reelsModel});

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showPlayPause = false;
  late Future<File> _reelFileFuture;

  @override
  void initState() {
    super.initState();

    AppLogger.d("video reel: ${widget.reelsModel.reelLink}");

    _initializePlayer();

    /// Start background download for share
    _reelFileFuture = ReelVideoDownloader().getCachedOrDownload(
      videoUrl: widget.reelsModel.reelLink,
      reelId: widget.reelsModel.id,
    );
  }

  Future<void> _initializePlayer() async {
    final File? cachedFile = await ReelVideoDownloader().getCachedFile(
      widget.reelsModel.id,
    );

    if (cachedFile != null && cachedFile.existsSync()) {
      /// ✅ Play from local file
      _controller = VideoPlayerController.file(cachedFile);
      AppLogger.d("Playing reel from cache");
    } else {
      /// 🌐 Play from network
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.reelsModel.reelLink),
      );
      AppLogger.d("Playing reel from network");
    }

    await _controller.initialize();

    _controller
      ..setLooping(true)
      ..setVolume(1.0)
      ..play();

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }

    setState(() => _showPlayPause = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showPlayPause = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// Video
          FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),

          /// Play / Pause overlay
          if (_showPlayPause)
            Center(
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 70,
              ),
            ),

          /// Bottom actions
          // Positioned(
          //   bottom: 40,
          //   left: 16,
          //   right: 16,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.end,
          //     children: [
          //       /// Share
          //       GestureDetector(
          //         onTap: () {
          //           context.read<LoginCheckCubit>().shareReel(
          //             reelId: widget.reelsModel.id,
          //             videoFuture: _reelFileFuture,
          //           );
          //         },
          //         child: Column(
          //           children: [
          //             SizedBox(
          //               height: 30,
          //               width: 30,
          //               child: SvgPicture.asset(MyAppAssets.svg_whatsapp),
          //             ),
          //             const SizedBox(height: 4),
          //             const Text(
          //               'Share',
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 12,
          //                 fontFamily: 'Gilroy',
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),

          //       const SizedBox(height: 52),

          //       /// Watch full video
          //       GestureDetector(
          //         onTap: () async {
          //           await MyAppAmplitudeAndFirebaseAnalitics().logEvent(
          //             event:
          //                 LogEventsName.instance().watch_full_video_reel,
          //           );

          //           _controller.pause();

          //           Navigator.of(context).push(
          //             MaterialPageRoute(
          //               builder: (_) => VideoPlayerUsingId(
          //                 url: widget.reelsModel.fullVideoLink,
          //               ),
          //             ),
          //           );
          //         },
          //         child: Container(
          //           height: 48,
          //           decoration: BoxDecoration(
          //             color: Colors.black.withOpacity(0.8),
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //           child: const Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               Text(
          //                 'Watch Full Video',
          //                 style: TextStyle(
          //                   color: Colors.white,
          //                   fontSize: 16,
          //                   fontFamily: 'Gilroy',
          //                   fontWeight: FontWeight.w600,
          //                 ),
          //               ),
          //               SizedBox(width: 6),
          //               Icon(
          //                 Icons.arrow_forward_ios,
          //                 size: 16,
          //                 color: Colors.white,
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
