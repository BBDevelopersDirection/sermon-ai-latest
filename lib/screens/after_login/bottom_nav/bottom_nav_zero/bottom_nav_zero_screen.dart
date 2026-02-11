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
import 'package:apivideo_player/apivideo_player.dart';
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
  final Map<int, ApiVideoPlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _cubit = BottomNavZeroCubit(firestoreFunctions: ReelsFirestoreFunctions());
    _cubit.refreshUniqueReels();

    WakelockPlus.enable();

    // Hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pageController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  void _onScroll() {
    final page = _pageController.page ?? 0.0;
    final newPage = page.round();

    if (newPage != _currentPage) {
      _pauseController(_currentPage);
      _playController(newPage);
      _currentPage = newPage;
    }
  }

  void _pauseController(int index) {
    if (_controllers.containsKey(index)) {
      _controllers[index]!.pause();
    }
  }

  void _playController(int index) {
    if (_controllers.containsKey(index)) {
      _controllers[index]!.play();
    }
  }

  void _registerController(int index, ApiVideoPlayerController controller) {
    _controllers[index] = controller;
    if (index == _currentPage) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  @override
  void didPushNext() {
    _controllers[_currentPage]?.pause();
    _controllers[_currentPage]?.setVolume(0);
  }

  @override
  void didPopNext() {
    _controllers[_currentPage]?.play();
    _controllers[_currentPage]?.setVolume(0.5);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cubit.close();
    routeObserver.unsubscribe(this);
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();

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
                physics:
                    const PageScrollPhysics(), // Snap exactly one page at a time
                pageSnapping: true,
                itemCount: state.reels.length,
                onPageChanged: (index) async {
                  // Pause previous video
                  _pauseController(_currentPage);

                  // Play current video
                  _playController(index);
                  _currentPage = index;

                  // Check free/restricted index
                  // if (index > _maxFreeIndex) {
                  //   var canUseVideo = await UtilsFunctions().canUseReel(
                  //     index: index,
                  //   );

                  //   if (!canUseVideo) {
                  //     MyAppAmplitudeAndFirebaseAnalitics().logEvent(
                  //       event: LogEventsName.instance().subscribePageByReels,
                  //     );

                  //     // Snap back safely
                  //     Future.delayed(Duration.zero, () {
                  //       if (_pageController.hasClients) {
                  //         _pageController.animateToPage(
                  //           _maxFreeIndex,
                  //           duration: const Duration(milliseconds: 300),
                  //           curve: Curves.easeInOut,
                  //         );
                  //       }
                  //     });

                  //     // Pause and mute previous controller
                  //     _controllers[_maxFreeIndex]?.pause();
                  //     _controllers[_maxFreeIndex]?.setVolume(0);

                  //     if (context.mounted) {
                  //       Navigator.of(context).push(
                  //         MaterialPageRoute(
                  //           builder: (context) => BlocProvider(
                  //             create: (context) => PlanPurchaseCubit(),
                  //             child: SubscriptionTrialScreen(
                  //               controller: _controllers[_maxFreeIndex],
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     }
                  //     return;
                  //   }
                  // }

                  Future.microtask(() async {
                    if (index > 0) {
                      var canUseVideo = await UtilsFunctions().canUseReel(
                        index: index,
                      );
                      final shouldShowRechargePage =
                          FirebaseRemoteConfigService().shouldShowRechargePage;

                      if (!canUseVideo &&
                          shouldShowRechargePage &&
                          context.mounted) {
                        MyAppAmplitudeAndFirebaseAnalitics().logEvent(
                          event: LogEventsName.instance().subscribePageByReels,
                        );
                        int index =
                            FirebaseRemoteConfigService()
                                        .totalReelCountUserCanSee -
                                    1 <
                                0
                            ? 0
                            : FirebaseRemoteConfigService()
                                      .totalReelCountUserCanSee -
                                  1;
                        // Snap back safely
                        Future.delayed(Duration.zero, () {
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        });

                        // Pause and mute
                        final ctrl = _controllers[index];
                        ctrl?.pause();
                        ctrl?.setVolume(0);

                        // Navigate to subscription (reels use apivideo; resume via callback)
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (_) => PlanPurchaseCubit(),
                              child: SubscriptionTrialScreen(
                                onResumePlayback: () {
                                  ctrl?.play();
                                  ctrl?.setVolume(0.5);
                                },
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  });

                  // Fetch more reels if near end
                  if (index == state.reels.length - 2 && state.hasMore) {
                    context.read<BottomNavZeroCubit>().fetchReels(
                      loadMore: true,
                    );
                  }

                  // Log reel watch event
                  MyAppAmplitudeAndFirebaseAnalitics().logEvent(
                    event: LogEventsName.instance().reel_watched,
                  );
                },
                itemBuilder: (context, index) {
                  final reel = state.reels[index];
                  return ReelVideoPlayer(
                    key: ValueKey('${reel.id}_$index'), // ✅ unique key
                    reelsModel: reel,
                    index: index,
                    onControllerReady: _registerController,
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

/// Extracts api.video video ID from reel URL or returns [fallbackVideoId].
String _extractReelVideoId(String reelLink, String fallbackVideoId) {
  if (reelLink.contains('/vod/')) {
    return reelLink.split('/vod/')[1].split('/').first;
  }
  return fallbackVideoId;
}

class ReelVideoPlayer extends StatefulWidget {
  final ReelsModel reelsModel;
  final int index;
  final Function(int, ApiVideoPlayerController) onControllerReady;

  const ReelVideoPlayer({
    super.key,
    required this.reelsModel,
    required this.index,
    required this.onControllerReady,
  });

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late ApiVideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showPlayPause = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    AppLogger.d("video reel: ${widget.reelsModel.reelLink}");
    final videoId = _extractReelVideoId(
      widget.reelsModel.reelLink,
      widget.reelsModel.videoId,
    );
    _controller = ApiVideoPlayerController(
      videoOptions: VideoOptions(videoId: videoId),
      autoplay: false,
      onPlay: () {
        if (mounted) setState(() => _isPlaying = true);
      },
      onPause: () {
        if (mounted) setState(() => _isPlaying = false);
      },
    );
    _controller.initialize().then((_) async {
      if (!mounted) return;
      await _controller.setIsLooping(true);
      if (!mounted) return;
      widget.onControllerReady(widget.index, _controller);
      setState(() => _isInitialized = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
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
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// Background video (apivideo_player, no built-in controls)
              Positioned.fill(
                child: ApiVideoPlayer(
                  controller: _controller,
                  child: Container(),
                ),
              ),

              /// Play/Pause overlay
              if (_showPlayPause)
                Center(
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 70,
                  ),
                ),

              /// Watch full sermon button at bottom
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
                      SizedBox(height: 52),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await MyAppAmplitudeAndFirebaseAnalitics()
                                    .logEvent(
                                      event: LogEventsName.instance()
                                          .watch_full_video_reel,
                                    );
                                _controller.pause();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => VideoPlayerUsingId(
                                      url: widget.reelsModel.fullVideoLink,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 48,
                                decoration: ShapeDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
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
                          ),
                        ],
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
