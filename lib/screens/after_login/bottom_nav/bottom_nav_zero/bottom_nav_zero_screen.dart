import 'package:apivideo_player/apivideo_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sermon/main.dart';
import 'package:sermon/reusable/hlc_video_player_using_id.dart';
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
  final Map<int, VideoPlayerController> _controllers = {};

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

  void _registerController(int index, VideoPlayerController controller) {
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

                        // Navigate to subscription
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (_) => PlanPurchaseCubit(),
                              child: SubscriptionTrialScreen(controller: ctrl),
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
                    // onControllerReady: _registerController,
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

class ReelVideoPlayer extends StatefulWidget {
  final ReelsModel reelsModel;

  const ReelVideoPlayer({super.key, required this.reelsModel});

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late ApiVideoPlayerController _videoController;
  bool _showPlayPause = false;

  @override
  void initState() {
    super.initState();

    _videoController = ApiVideoPlayerController(
      videoOptions: VideoOptions(videoId: widget.reelsModel.id),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _videoController.play();
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Stack(
          fit: StackFit.expand,
          children: [
            /// Background video
            Positioned.fill(
              child: ApiVideoPlayer(
                controller: _videoController,
                fit: BoxFit.cover,
                style: const PlayerStyle(
                  controlsBarStyle: null,
                  settingsBarStyle: null,
                  timeSliderStyle: null,
                ),
              ),
            ),

            /// Play/Pause overlay
            if (_showPlayPause)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() {
                    //       _isMuted = !_isMuted;
                    //       _controller.setVolume(
                    //         _isMuted ? 0 : 1,
                    //       ); // 🔊 Toggle
                    //     });
                    //   },
                    //   child: Container(
                    //     padding: const EdgeInsets.all(8),
                    //     decoration: BoxDecoration(
                    //       color: Colors.black54,
                    //       shape: BoxShape.circle,
                    //     ),
                    //     child: Icon(
                    //       _isMuted ? Icons.volume_off : Icons.volume_up,
                    //       color: Colors.white,
                    //       size: 28,
                    //     ),
                    //   ),
                    // ),
                    // Icon(
                    //   _controller.value.isPlaying
                    //       ? Icons.pause
                    //       : Icons.play_arrow,
                    //   color: Colors.white,
                    //   size: 70,
                    // ),
                  ],
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
                            child: SvgPicture.asset(
                              MyAppAssets.svg_whatsapp,
                              // size: 16,
                            ),
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
                              // _controller
                              //     .pause(); // ⏸ Pause before pushing new screen
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => HlcVideoPlayerUsingId(
                                    videoId: widget.reelsModel.id,
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
      ],
    );
  }
}
