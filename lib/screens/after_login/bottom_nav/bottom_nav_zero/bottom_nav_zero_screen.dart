import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:sermon/reusable/video_player_using_id.dart';
import 'package:sermon/services/firebase/models/meels_model.dart';
import 'package:video_player/video_player.dart';

import 'bottom_nav_zero_cubit.dart';
import 'bottom_nav_zero_state.dart';
import 'package:sermon/services/firebase/reels_management/reels_functions.dart';

class BottomNavZeroScreen extends StatefulWidget {
  const BottomNavZeroScreen({super.key});

  @override
  State<BottomNavZeroScreen> createState() => _BottomNavZeroScreenState();
}

class _BottomNavZeroScreenState extends State<BottomNavZeroScreen> {
  final PageController _pageController = PageController();
  late BottomNavZeroCubit _cubit;
  int _currentPage = 0;
  final Map<int, VideoPlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _cubit = BottomNavZeroCubit(firestoreFunctions: ReelsFirestoreFunctions());
    _cubit.fetchReels();

    _pageController.addListener(_onScroll);
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
  void dispose() {
    _pageController.dispose();
    _cubit.close();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<BottomNavZeroCubit, BottomNavZeroState>(
          builder: (context, state) {
            if (state.isLoading && state.reels.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.reels.isEmpty) {
              return const Center(
                child: Text("No Reels Found", style: TextStyle(color: Colors.white)),
              );
            }

            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: state.reels.length,
              onPageChanged: (index) {
                if (index == state.reels.length - 2 && state.hasMore) {
                  context.read<BottomNavZeroCubit>().fetchReels(loadMore: true);
                }
              },
              itemBuilder: (context, index) {
                final reel = state.reels[index];
                return ReelVideoPlayer(
                  reelsModel: reel,
                  index: index,
                  onControllerReady: _registerController,
                );
              },
            );
          },
        ),
      ),
    );
  }
}


class ReelVideoPlayer extends StatefulWidget {
  final ReelsModel reelsModel;
  final int index;
  final Function(int, VideoPlayerController) onControllerReady;

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
  late VideoPlayerController _controller;
  bool _showPlayPause = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.reelsModel.reelLink)
      ..initialize().then((_) {
        if (mounted) setState(() {});
        widget.onControllerReady(widget.index, _controller);
      })
      ..setLooping(true);
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
          /// Background video
          FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),

          /// Play/Pause overlay
          if (_showPlayPause)
            Center(
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
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
              child: GestureDetector(
                onTap: () {
                  _controller.pause(); // ⏸ Pause before pushing new screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerUsingId(
                        url: widget.reelsModel.fullVideoLink,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
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
                        'Watch Full Sermon',
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
          ),
        ],
      ),
    );
  }
}
