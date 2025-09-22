import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/services/plan_service/plan_purchase_screen.dart';
import 'package:sermon/reusable/pulsing_icon_anim.dart';
import 'package:sermon/services/firebase/utils_management/utils_functions.dart';
import 'package:sermon/reusable/logger_service.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/log_service/log_service.dart';
import '../services/log_service/log_variables.dart';
import '../services/plan_service/plan_purchase_cubit.dart';

class VideoPlayerUsingId extends StatefulWidget {
  String url;
  bool isCaraousel;
  VideoPlayerUsingId({super.key, required this.url, this.isCaraousel = false});

  @override
  State<VideoPlayerUsingId> createState() => _VideoPlayerUsingIdState();
}

class _VideoPlayerUsingIdState extends State<VideoPlayerUsingId> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Keep screen on and hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Enable wakelock to prevent screen from turning off
    WakelockPlus.enable();
    initialize();
  }

  Future<void> initialize() async {
    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );

    UtilsFunctions().canUseVideo().then((canUseVideo) async {
      AppLogger.d('I can use video: $canUseVideo');

      if (!canUseVideo) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => PlanPurchaseCubit(),
              child: SubscriptionTrialScreen(),
            ),
          ),
        );
        return;
      }

      Future.wait([
        MyAppAmplitudeAndFirebaseAnalitics().logEvent(
          event: LogEventsName.instance().videoOpenEvent,
        ),
        UtilsFunctions().increaseVideoCount(),
        if (widget.isCaraousel)
          MyAppAmplitudeAndFirebaseAnalitics().logEvent(
            event: LogEventsName.instance().videoOfTheDayEvent,
          ),
      ]);

      await videoPlayerController.initialize();

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: true,
        showOptions: false,
        // autoInitialize: true,
        // aspectRatio: 16/9,
        allowFullScreen: true,
        // maxScale: 1,
        allowMuting: true,
        fullScreenByDefault: false,
        zoomAndPan: true,
        // pauseOnBackgroundTap:true,
        customControls: CupertinoControls(
          backgroundColor: Colors.black54,
          iconColor: Colors.white,
        ),
      );

      // i want chewieController video to be vertical
      chewieController?.play();

      // Refresh the UI after the ChewieController is initialized
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Disable wakelock when leaving the screen
    WakelockPlus.disable();
    // Restore normal system UI mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return a placeholder or loading spinner while the controller is not initialized
    if (chewieController == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.5,
            child: PulsingIconAnim(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Chewie(controller: chewieController!),
            Container(
              color: Colors.black,
              child: IconButton(
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
