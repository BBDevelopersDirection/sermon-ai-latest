import 'dart:io';

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
import 'package:sermon/services/reel_video_download.dart';
import 'package:sermon/utils/app_assets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
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
  bool _isScrollLocked = false;
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
    final ctrl = _controllers[index];
    if (ctrl != null && ctrl.value.isInitialized) ctrl.pause();
  }

  void _setScrollLock(bool value) {
    if (_isScrollLocked == value) return;

    setState(() {
      _isScrollLocked = value;
    });
  }

  void _playController(int index) {
    final ctrl = _controllers[index];
    if (ctrl != null && ctrl.value.isInitialized) ctrl.play();
  }

  VideoPlayerController _getOrCreateController(int index, String url) {
    if (!_controllers.containsKey(index)) {
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
      ctrl.setLooping(true);
      ctrl.initialize().then((_) {
        if (mounted) setState(() {});
        if (index == _currentPage) ctrl.play();
      });
      _controllers[index] = ctrl;
    }
    return _controllers[index]!;
  }

  void _disposeAllControllers() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
  }

  @override
  void didPushNext() {
    final ctrl = _controllers[_currentPage];
    if (ctrl != null && ctrl.value.isInitialized) {
      ctrl.pause();
      ctrl.setVolume(0);
    }
  }

  @override
  void didPopNext() {
    final ctrl = _controllers[_currentPage];
    if (ctrl != null && ctrl.value.isInitialized) {
      ctrl.play();
      ctrl.setVolume(0.5);
    }
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
            _disposeAllControllers();
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
                physics: _isScrollLocked
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
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
                  final ctrl = _getOrCreateController(index, reel.reelLink);
                  return ReelVideoPlayer(
                    key: ValueKey('${reel.id}_$index'),
                    reelsModel: reel,
                    index: index,
                    controller: ctrl,
                    onDownloadStateChanged: _setScrollLock,
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
  final int index;
  final VideoPlayerController controller;
  final Function(bool) onDownloadStateChanged;

  const ReelVideoPlayer({
    super.key,
    required this.reelsModel,
    required this.index,
    required this.controller,
    required this.onDownloadStateChanged,
  });

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  bool _showPlayPause = false;

  File? _cachedVideo;
  bool _isDownloading = false;

  bool get _showShareLoader => _isDownloading;

  Future<void> _onShareTap() async {
    if (_cachedVideo != null) {
      _shareWithVideo();
      return;
    }

    widget.onDownloadStateChanged(true); // 🔒 LOCK SCROLL
    context.read<BottomNavCubit>().setVideoCaching(value: true);

    setState(() {
      _isDownloading = true;
    });

    try {
      final file = await ReelVideoDownloader().getReel(
        widget.reelsModel.id,
        widget.reelsModel.reelLink,
      );

      if (!mounted) return;

      setState(() {
        _cachedVideo = file;
      });

      _shareWithVideo();
    } catch (e) {
      if (!mounted) return;

      _shareLinkOnly();
    } finally {
      if (!mounted) return;

      setState(() {
        _isDownloading = false;
      });
      widget.onDownloadStateChanged(false); // 🔓 UNLOCK SCROLL
      context.read<BottomNavCubit>().setVideoCaching(value: false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }

    setState(() => _showPlayPause = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showPlayPause = false);
    });
  }

  Future<void> _shareWithVideo() async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(_cachedVideo!.path, mimeType: 'video/mp4')],
        text:
            '${FirebaseRemoteConfigService().shareButtonMessageText}\n'
            'https://sermontv.usedirection.com/${widget.reelsModel.id}',
      ),
    );

    if (result.status == ShareResultStatus.success) {
      AppLogger.i("User selected a share target");
      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().reelsShareButton,
      );
    } else if (result.status == ShareResultStatus.dismissed) {
      AppLogger.e("User dismissed share sheet");
    }
  }

  Future<void> _onWatchFullVideoTap() async {
    // 🚫 Block if downloading
    if (_isDownloading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please wait, video is downloading..."),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ✅ Otherwise proceed
    await MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: LogEventsName.instance().watch_full_video_reel,
    );

    widget.controller.pause();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            VideoPlayerUsingId(url: widget.reelsModel.fullVideoLink),
      ),
    );
  }

  void _shareLinkOnly() {
    SharePlus.instance.share(
      ShareParams(
        text:
            '${FirebaseRemoteConfigService().shareButtonMessageText}\n'
            'https://sermontv.usedirection.com/${widget.reelsModel.id}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
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
              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: widget.controller.value.size.width,
                  height: widget.controller.value.size.height,
                  child: VideoPlayer(widget.controller),
                ),
              ),

              if (_showPlayPause)
                Center(
                  child: Icon(
                    widget.controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 70,
                  ),
                ),

              /// SHARE + WATCH BUTTONS
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
                        onTap: _isDownloading ? null : _onShareTap,
                        child: Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _showShareLoader
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.white.withOpacity(0.3),
                                      highlightColor: Colors.white.withOpacity(
                                        0.8,
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 30,
                                            width: 30,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            height: 12,
                                            width: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: SvgPicture.asset(
                                            MyAppAssets.svg_whatsapp,
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 52),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                _onWatchFullVideoTap();
                              },
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Watch Full Video',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Gilroy',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
