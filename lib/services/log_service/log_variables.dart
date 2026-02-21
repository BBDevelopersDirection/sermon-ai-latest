class LogEventsName{
  String install = 'install';
  String phoneNumberCorrectEntry = 'phoneNumberCorrectEntry';
  String phoneNumberIncorrectEntry = 'phoneNumberIncorrectEntry';

  String otpEntryIncorrect = 'otpEntryIncorrect';

  String registeredUserFirebase = 'registeredUserFirebase';
  String registeredUserTruecaller = 'registeredUserTruecaller';
  String registeredEmailTyped = 'registeredEmailTyped';

  String loginFirebase = 'loginFirebase';
  String loginTruecaller = 'loginTruecaller';

  String reelsScreenButton = 'reelsScreenButton';
  String homeScreenButton = 'homeScreenButton';
  String profileScreenButton = 'profileScreenButton';
  String logoutEvent = 'logoutEvent';

  String videoOfTheDayEvent = 'videoOfTheDayEvent';
  String videoOpenEvent = 'videoOpenedEvent';

  String subscribePageByReels = 'subscribePageByReels';
  String subscribePageByVideoPlay = 'subscribePageByVideoPlay';

  String subscribeNowButtonTap = 'subscriptionNowButtonTap';
  String subscriptionCompleteEvent = 'subscriptionCompleteEvent';
  String subscriptionFailEvent = 'subscriptionFailEvent';


  String chat_support = 'chatSupport';
  String privacy_policy = 'privacyPolicy';

  String watch_full_video_reel = 'watchFullVideoReel';
  String reel_watched = 'reelWatched';
  String reelsShareButton = 'reelsShareButton';
  String shared_reel_watched = 'sharedReelWatched';

  // Temporary event names for testing
  String splashscreenStart = 'splashScreenStart';
  String splashscreenEnd = 'splashScreenEnd';
  String loginReelPageOpen = 'loginReelPageOpen';
  String loginScreenOpen = 'loginScreenOpen';

  // Otp Events Logs
  String invalidVerificationCode = 'invalidVerificationCode';
  String sessionExpired = 'sessionExpired';
  String tooManyRequests = 'tooManyRequests';
  String quotaExceeded = 'otpSmsQuotaExceeded';
  String unknownError = 'unknownError';

  LogEventsName._privateConstructor();
  static LogEventsName instance(){
    return LogEventsName._privateConstructor();
  }
}