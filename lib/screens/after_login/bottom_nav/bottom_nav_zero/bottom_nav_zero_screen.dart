import 'package:apivideo_player/apivideo_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sermon/main.dart';
import 'package:sermon/reusable/video_player_using_id.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav/bottom_nav_cubit.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav/bottom_nav_state.dart';
import 'package:sermon/services/firebase/firebase_remote_config.dart';
import 'package:sermon/services/firebase/models/meels_model.dart';
import 'package:sermon/services/firebase/utils_management/utils_functions.dart';
import 'package:sermon/services/log_service/log_service.dart';
import 'package:sermon/services/log_service/log_variables.dart';
import 'package:sermon/services/plan_service/plan_purchase_cubit.dart';
import 'package:sermon/services/plan_service/plan_purchase_screen.dart';
import 'package:sermon/services/token_check_service/login_check_cubit.dart';
import 'package:sermon/utils/app_assets.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../reusable/logger_service.dart';
import 'bottom_nav_zero_cubit.dart';
import 'bottom_nav_zero_state.dart';
import 'package:sermon/services/firebase/reels_management/reels_functions.dart';

class BottomNavZeroScreen extends StatefulWidget {
  const BottomNavZeroScreen({super.key});

  @override
  State<BottomNavZeroScreen> createState() => _BottomNavZeroScreenState();
}

class _BottomNavZeroScreenState extends State<BottomNavZeroScreen>
    with RouteAware {
  final PageController _pageController = PageController();
  late BottomNavZeroCubit _cubit;
  int _currentPage = 0;

  ApiVideoPlayerController? _currentController;
  ApiVideoPlayerController? _prevController;
  ApiVideoPlayerController? _nextController;

  @override
  void initState() {
    super.initState();
    _cubit = BottomNavZeroCubit(firestoreFunctions: ReelsFirestoreFunctions());
    _cubit.refreshUniqueReels();

    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _onPageChanged(int index, List<ReelsModel> reels) {
    // Dispose old controller immediately
    _currentController?.dispose();
    _currentController = null;

    // Create ONLY one controller
    _currentController = ApiVideoPlayerController(
      autoplay: true,
      videoOptions: VideoOptions(
        videoId: reels[index].videoId,
        type: VideoType.vod,
      ),
    );

    setState(() {
      _currentPage = index;
    });
  }

  ApiVideoPlayerController _createController(ReelsModel reel) {
    return ApiVideoPlayerController(
      autoplay: false,
      videoOptions: VideoOptions(videoId: reel.videoId, type: VideoType.vod),
    );
  }

  @override
  void didPushNext() {
    _currentController?.pause();
    _currentController?.setVolume(0);
    _prevController?.pause();
    _prevController?.setVolume(0);
    _nextController?.pause();
    _nextController?.setVolume(0);
  }

  @override
  void didPopNext() {
    _currentController?.play();
    _currentController?.setVolume(0.5);
    _prevController?.play();
    _prevController?.setVolume(0.5);
    _nextController?.play();
    _nextController?.setVolume(0.5);
  }

  @override
  void dispose() {
    _cubit.close();
    routeObserver.unsubscribe(this);

    _prevController?.dispose();
    _currentController?.dispose();
    _nextController?.dispose();
    _pageController.dispose();

    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: BlocListener<BottomNavCubit, BottomNavState>(
        listenWhen: (previous, current) =>
            previous.selectedIndex != current.selectedIndex,
        listener: (context, navState) {
          if (navState.selectedIndex == 0) {
            _cubit.refreshUniqueReels();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: BlocBuilder<BottomNavZeroCubit, BottomNavZeroState>(
            builder: (context, state) {
              if (state.isLoading && state.reels.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.reels.isEmpty) {
                return const Center(
                  child: Text(
                    "No Reels Found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const PageScrollPhysics(),
                itemCount: state.reels.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });

                  // 🔁 Handle controller lifecycle safely
                  _onPageChanged(index, state.reels);

                  // 📦 Load more reels
                  if (index == state.reels.length - 2 && state.hasMore) {
                    context.read<BottomNavZeroCubit>().fetchReels(
                      loadMore: true,
                    );
                  }

                  // 📊 Analytics
                  MyAppAmplitudeAndFirebaseAnalitics().logEvent(
                    event: LogEventsName.instance().reel_watched,
                  );
                },
                itemBuilder: (context, index) {
                  final reel = state.reels[index];

                  // ❗ Only mount video for CURRENT page
                  if (index != _currentPage) {
                    return const SizedBox.expand(); // NO VIDEO SURFACE
                  }

                  return ReelVideoPlayer(
                    key: ValueKey(reel.id),
                    reelsModel: reel,
                    controller: _currentController,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// class ReelVideoPlayer extends StatefulWidget {
//   final ReelsModel reelsModel;
//   final int index;
//   final Function(int, VideoPlayerController) onControllerReady;

//   const ReelVideoPlayer({
//     super.key,
//     required this.reelsModel,
//     required this.index,
//     required this.onControllerReady,
//   });

//   @override
//   State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
// }

// class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
//   late VideoPlayerController _controller;
//   bool _showPlayPause = false;

//   @override
//   void initState() {
//     super.initState();
//     AppLogger.d("video reel: ${widget.reelsModel.reelLink}");
//     _controller =
//         VideoPlayerController.networkUrl(Uri.parse(widget.reelsModel.reelLink))
//           ..initialize().then((_) {
//             // if (widget.index == 0) {
//             //   _controller.setVolume(
//             //     0,
//             //   ); // 🔇 Mute before registering the controller
//             // }
//             widget.onControllerReady(widget.index, _controller);

//             if (mounted) setState(() {});
//           })
//           ..setLooping(true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _togglePlayPause() {
//     if (_controller.value.isPlaying) {
//       _controller.pause();
//     } else {
//       _controller.play();
//     }
//     setState(() => _showPlayPause = true);
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) setState(() => _showPlayPause = false);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_controller.value.isInitialized) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         GestureDetector(
//           onTap: _togglePlayPause,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               /// Background video
//               FittedBox(
//                 fit: BoxFit.contain,
//                 child: SizedBox(
//                   width: _controller.value.size.width,
//                   height: _controller.value.size.height,
//                   child: VideoPlayer(_controller),
//                 ),
//               ),

//               /// Play/Pause overlay
//               if (_showPlayPause)
//                 Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // GestureDetector(
//                       //   onTap: () {
//                       //     setState(() {
//                       //       _isMuted = !_isMuted;
//                       //       _controller.setVolume(
//                       //         _isMuted ? 0 : 1,
//                       //       ); // 🔊 Toggle
//                       //     });
//                       //   },
//                       //   child: Container(
//                       //     padding: const EdgeInsets.all(8),
//                       //     decoration: BoxDecoration(
//                       //       color: Colors.black54,
//                       //       shape: BoxShape.circle,
//                       //     ),
//                       //     child: Icon(
//                       //       _isMuted ? Icons.volume_off : Icons.volume_up,
//                       //       color: Colors.white,
//                       //       size: 28,
//                       //     ),
//                       //   ),
//                       // ),
//                       Icon(
//                         _controller.value.isPlaying
//                             ? Icons.pause
//                             : Icons.play_arrow,
//                         color: Colors.white,
//                         size: 70,
//                       ),
//                     ],
//                   ),
//                 ),

//               /// Watch full sermon button at bottom
//               Positioned(
//                 bottom: 40,
//                 left: 0,
//                 right: 0,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           context.read<LoginCheckCubit>().shareReel(
//                             widget.reelsModel.id,
//                           );
//                         },
//                         child: Column(
//                           children: [
//                             SizedBox(
//                               height: 30,
//                               width: 30,
//                               child: SvgPicture.asset(
//                                 MyAppAssets.svg_whatsapp,
//                                 // size: 16,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             const Text(
//                               'Share',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontFamily: 'Gilroy',
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 52),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () async {
//                                 await MyAppAmplitudeAndFirebaseAnalitics().logEvent(
//                                   event: LogEventsName.instance()
//                                       .watch_full_video_reel,
//                                 );
//                                 _controller
//                                     .pause(); // ⏸ Pause before pushing new screen
//                                 Navigator.of(context).push(
//                                   MaterialPageRoute(
//                                     builder: (context) => VideoPlayerUsingId(
//                                       url: widget.reelsModel.fullVideoLink,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: Container(
//                                 height: 48,
//                                 decoration: ShapeDecoration(
//                                   color: Colors.black.withOpacity(0.8),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: const [
//                                     Text(
//                                       'Watch Full Video',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontFamily: 'Gilroy',
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     SizedBox(width: 6),
//                                     Icon(
//                                       Icons.arrow_forward_ios,
//                                       size: 16,
//                                       color: Colors.white,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

class ReelVideoPlayer extends StatefulWidget {
  final ReelsModel reelsModel;
  final ApiVideoPlayerController? controller;

  const ReelVideoPlayer({
    super.key,
    required this.reelsModel,
    required this.controller,
  });

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  bool _showPlayPause = false;
  bool _isPlaying = true;

  Future<void> _togglePlayPause() async {
    final controller = widget.controller;
    if (controller == null) return;

    final playing = await controller.isPlaying;

    if (playing) {
      controller.pause();
    } else {
      controller.play();
    }

    setState(() {
      _isPlaying = !playing;
      _showPlayPause = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showPlayPause = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller == null) {
      // Offscreen pages (prev/next not yet ready)
      return const SizedBox.expand();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// 🎥 api.video player
              ApiVideoPlayer(controller: controller, fit: BoxFit.contain),

              /// ▶️ Play / Pause overlay
              if (_showPlayPause)
                Center(
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 70,
                  ),
                ),

              /// Bottom actions
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      /// Share
                      GestureDetector(
                        onTap: () {
                          context.read<LoginCheckCubit>().shareReel(
                            widget.reelsModel.id,
                          );
                        },
                        child: Column(
                          children: [
                            SizedBox(
                              height: 30,
                              width: 30,
                              child: SvgPicture.asset(MyAppAssets.svg_whatsapp),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Share',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 52),

                      /// Watch full video
                      GestureDetector(
                        onTap: () {
                          controller.pause();

                          MyAppAmplitudeAndFirebaseAnalitics().logEvent(
                            event:
                                LogEventsName.instance().watch_full_video_reel,
                          );

                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (_) => VideoPlayerUsingId(
                          //       videoId: widget.reelsModel.fullVideoId,
                          //     ),
                          //   ),
                          // );
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Watch Full Video',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
