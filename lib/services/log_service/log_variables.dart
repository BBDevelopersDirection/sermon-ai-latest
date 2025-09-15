class LogEventsName{
  String install = 'install';
  String phoneNumberCorrectEntry = 'phoneNumberCorrectEntry';
  String phoneNumberIncorrectEntry = 'phoneNumberIncorrectEntry';

  String otpEntryCorrect = 'otpEntryCorrect';
  String otpEntryIncorrect = 'otpEntryIncorrect';

  String regestrationName = 'regestrationName';
  String regestredUser = 'regestredUser';
  String regestrationEmail = 'regestrationEmail';

  String reelsScreenButton = 'reelsScreenButton';
  String homeScreenButton = 'homeScreenButton';
  String profileScreenButton = 'profileScreenButton';
  String logoutEvent = 'logoutEvent';

  String videoOfTheDayEvent = 'videoOfTheDayEvent';
  String videoOpenEvent = 'videoOpenedEvent';

  String transistionCompleteEvent = 'transistionCompleteEvent';
  String transistionFailEvent = 'transistionFailEvent';


  String chat_support = 'chatSupport';
  String privacy_policy = 'privacyPolicy';

  String watch_full_video_reel = 'watchFullVideoReel';
  String reel_watched = 'reelWatched';

  LogEventsName._privateConstructor();
  static LogEventsName instance(){
    return LogEventsName._privateConstructor();
  }
}