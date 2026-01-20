import 'dart:async';
import 'package:apivideo_player/apivideo_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/services/firebase/firebase_remote_config.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:sermon/reusable/logger_service.dart';
import 'package:sermon/reusable/pulsing_icon_anim.dart';
import 'package:sermon/services/firebase/utils_management/utils_functions.dart';
import 'package:sermon/services/log_service/log_service.dart';
import 'package:sermon/services/log_service/log_variables.dart';
import 'package:sermon/services/plan_service/plan_purchase_cubit.dart';
import 'package:sermon/services/plan_service/plan_purchase_screen.dart';

class VideoPlayerUsingId extends StatefulWidget {
  final String url; // this will be the api.video videoId or video URL
  final bool isCaraousel;

  const VideoPlayerUsingId({
    super.key,
    required this.url,
    this.isCaraousel = false,
  });

  @override
  State<VideoPlayerUsingId> createState() => _VideoPlayerUsingIdState();
}

class _VideoPlayerUsingIdState extends State<VideoPlayerUsingId> {
  late ApiVideoPlayerController apiVideoController;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();

    initialize();
  }

  Future<void> initialize() async {
    if (widget.isCaraousel) {
      await MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().videoOfTheDayEvent,
      );
    }

    UtilsFunctions().canUseVideo().then((canUseVideo) async {
      AppLogger.d("I can use video: $canUseVideo");

      final shouldShowRechargePage =
                        FirebaseRemoteConfigService().shouldShowRechargePage;

      if (!canUseVideo && shouldShowRechargePage) {
        await MyAppAmplitudeAndFirebaseAnalitics().logEvent(
          event: LogEventsName.instance().subscribePageByVideoPlay,
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => PlanPurchaseCubit(),
              child: SubscriptionTrialScreen(),
            ),
          ),
        );
        return;
      }

      await Future.wait([
        MyAppAmplitudeAndFirebaseAnalitics().logEvent(
          event: LogEventsName.instance().videoOpenEvent,
        ),
        UtilsFunctions().increaseVideoCount(),
      ]);

      // ---------- NEW API VIDEO CONTROLLER -----------
      print('video url is: ${widget.url}');
      apiVideoController = ApiVideoPlayerController(
        autoplay: true,
        videoOptions: VideoOptions(videoId: extractVideoId(widget.url)),
      );

      // wait for player to be ready
      await apiVideoController.initialize();

      setState(() => isInitialized = true);
    });
  }

  String extractVideoId(String url) {
    return url.split("/vod/")[1].split("/").first;
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    apiVideoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
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
            // ------------------ API VIDEO PLAYER ------------------
            ApiVideoPlayer(
  controller: apiVideoController,
  style: PlayerStyle(
    timeSliderStyle: TimeSliderStyle(
      sliderTheme: SliderThemeData(
        activeTrackColor: Colors.white,    // Played portion
        inactiveTrackColor: Colors.black45,  // Remaining portion
        thumbColor: Colors.white,          // Circle handle
        overlayColor: Colors.white.withOpacity(0.2),
      ),
    ),
    controlsBarStyle: ControlsBarStyle(
      mainControlButtonStyle: ButtonStyle(
        iconColor: WidgetStateProperty.all(Colors.white), // Play / Pause
      ),
      seekForwardControlButtonStyle: ButtonStyle(
        iconColor: WidgetStateProperty.all(Colors.white), // Forward 10s
      ),
      seekBackwardControlButtonStyle: ButtonStyle(
        iconColor: WidgetStateProperty.all(Colors.white), // Backward 10s
      ),
    ),
    settingsBarStyle: SettingsBarStyle(
      // hide the speed button by giving it zero size
      buttonStyle: ButtonStyle(
        minimumSize: WidgetStateProperty.all(Size.zero),
        fixedSize: WidgetStateProperty.all(Size.zero),
        maximumSize: WidgetStateProperty.all(Size.zero),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
      ),
    ),
  ),
),

            // ------------------ BACK BUTTON ------------------
            Container(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
