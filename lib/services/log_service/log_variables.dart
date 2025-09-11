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

  // String click_chat_now = 'click_chat_now';
  // String click_recharge_custom = 'click_recharge_custom';
  // String click_recharge_pricing_button = 'click_recharge_pricing_button';
  // String click_help = 'click_help';
  // String click_home = 'click_home';
  // String click_call_now_recharge_alert = 'click_call_now_recharge_alert';
  // String login_sucess_google='login_sucess_google';

  LogEventsName._privateConstructor();
  static LogEventsName instance(){
    return LogEventsName._privateConstructor();
  }
}