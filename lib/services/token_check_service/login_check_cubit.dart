import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/reusable/my_app_firebase_analytics/analytic_logger.dart';
import 'package:sermon/reusable/my_app_firebase_analytics/event_name.dart';
import 'package:sermon/reusable/recharge_page.dart';
import 'package:sermon/services/firebase/transictions_management/transistion_function.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import '../../main.dart';
import '../../models/playlist_and_episode_model_old.dart';
import '../../reusable/app_dialogs.dart';
import '../../reusable/video_player_using_id.dart';
import '../../screens/after_login/bottom_nav/bottom_nav_first/widgets/episode_list_page.dart';
import '../app_opner_service.dart';
import '../firebase/firestore_variables.dart';
import '../firebase/models/utility_model.dart';
import '../firebase/utils_management/utils_functions.dart';
import '../log_service/log_service.dart';
import '../log_service/log_variables.dart';
import '../shared_pref/shared_preference.dart';
import 'login_check_screen.dart';
import 'login_check_state.dart';

class LoginCheckCubit extends Cubit<LoginCheckState> {
  LoginCheckCubit()
  : super(LoginCheckState(showRechargePage: false, showPaymentInProgress: false, currentPlan: 0));

  /// Show or hide the payment-in-progress overlay.
  void emit_show_payment_in_progress({required bool isShow}) {
    emit(state.copyWith(showPaymentInProgress: isShow));
  }

  void freshInstallEventLog(){
    if(SharedPreferenceLogic.isFreshInstall()){
      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
                  event: LogEventsName.instance().install,
      );
    }
  }

  Future<void> checkToken() async {
    try {
      // SharedPreferenceLogic.setLoginFalse();
      // HiveBoxFunctions().removeLoginDetails();
      bool isLogin = HiveBoxFunctions().isLoginPresent();
      if (isLogin) {
        // emit(state.copyWith(loading: false, isTokenPresent: true));
        emit(state.copyWith(loading: false, isTokenPresent: true));
        createUtilityData();
        checkPlanExpire();
      } else {
        emit(state.copyWith(loading: false, isTokenPresent: false));
      }
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> createUtilityData() async {
    await UtilsFunctions().createFirebaseUtilityData(
      utilityModel: UtilityModel(
        userId:
            FirebaseAuth.instance.currentUser?.uid ??
            HiveBoxFunctions().getUuid(),
        totalVideoCount: 0,
        isRecharged: false,
        videoCountToCheckSub: 0,
      ),
    );
  }

  Future<void> checkPlanExpire() async {
    await UtilsFunctions().setRechargeFalseIfRechargeExpires();
    // await UtilsFunctions().setRechargeTrue();
  }

  void log_out({required BuildContext context}) {
    MyAppDialogs().conf_dialog(
      context: context,
      title: 'Info',
      body: 'Are you sure you want to log out?',
      onOkCallback: () async {
        Navigator.of(context).pop(); // Close the dialog first
        Future.wait([
          MyAppAmplitudeAndFirebaseAnalitics().logEvent(
            event: LogEventsName.instance().logoutEvent,
          ),
          HiveBoxFunctions().removeLoginDetails(),
        ]);

        // Wait for the dialog pop to complete
        await Future.delayed(Duration(milliseconds: 100));

        // Perform the navigation
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginCheckScreen()),
          (Route<dynamic> route) => false,
        );
      },
    );
    return;
  }

  void validate_and_redirect({
    required String url,
    required BuildContext context,
  }) {
    SharedPreferenceLogic.increaseWatchVideoCounter();

    if (SharedPreferenceLogic.canWatchVideo()) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => VideoPlayerUsingId(url: url)),
      );
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              RechargePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Simply return the child widget with no transition
            return child;
          },
        ),
      );
    }
  }

  void emit_show_recharge_page({required bool isShow}) {
    if (isShow) {
      emit(state.copyWith(showRechargePage: true));
    } else {
      emit(state.copyWith(showRechargePage: false));
    }
  }

  void emit_change_plan({
    required int updateInt,
    required BuildContext context,
  }) {
    if (context.read<LoginCheckCubit>().state.currentPlan == 0) {
      MyAppAnalitics.instanse().logEvent(event: 'monthly_plan_card_clicked');
    } else {
      MyAppAnalitics.instanse().logEvent(event: 'yearly_plan_card_clicked');
    }
    emit(state.copyWith(currentPlan: updateInt));
  }

  void increase_three_days({required BuildContext context}) {
    MyAppDialogs().info_dialog(
      context: context,
      title: 'Recharge Done',
      body: 'You can now watch 3 more videos',
      onOkCallback: () {
        SharedPreferenceLogic.resetWatchVideoCounter();
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> redirect_user_to_episode_page({
    required BuildContext context,
    required int index,
  }) async {
    String? analytic_name;
    if (index == 0) {
      analytic_name = MyAppLogEventsName.instance().series1;
    } else if (index == 1) {
      analytic_name = MyAppLogEventsName.instance().series2;
    } else if (index == 2) {
      analytic_name = MyAppLogEventsName.instance().series3;
    } else if (index == 3) {
      analytic_name = MyAppLogEventsName.instance().series4;
    } else if (index == 4) {
      analytic_name = MyAppLogEventsName.instance().series5;
    } else if (index == 5) {
      analytic_name = MyAppLogEventsName.instance().series6;
    } else if (index == 6) {
      analytic_name = MyAppLogEventsName.instance().series7;
    } else if (index == 7) {
      analytic_name = MyAppLogEventsName.instance().series8;
    } else if (index == 8) {
      analytic_name = MyAppLogEventsName.instance().series9;
    } else if (index == 9) {
      analytic_name = MyAppLogEventsName.instance().series10;
    } else if (index == 10) {
      analytic_name = MyAppLogEventsName.instance().series11;
    } else if (index == 11) {
      analytic_name = MyAppLogEventsName.instance().series12;
    } else if (index == 12) {
      analytic_name = MyAppLogEventsName.instance().series13;
    } else if (index == 13) {
      analytic_name = MyAppLogEventsName.instance().series14;
    } else if (index == 14) {
      analytic_name = MyAppLogEventsName.instance().series15;
    } else if (index == 15) {
      analytic_name = MyAppLogEventsName.instance().series16;
    } else if (index == 16) {
      analytic_name = MyAppLogEventsName.instance().series17;
    } else if (index == 17) {
      analytic_name = MyAppLogEventsName.instance().series18;
    } else if (index == 18) {
      analytic_name = MyAppLogEventsName.instance().series19;
    } else if (index == 19) {
      analytic_name = MyAppLogEventsName.instance().series20;
    } else {
      analytic_name = 'Unknown Series';
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EpisodeListPage(
          series_name: playList[index].name,
          model: playList[index].episodeModel,
          author: playList[index].author,
        ),
      ),
    );

    await MyAppAnalitics.instanse().logEvent(event: analytic_name);
  }

  Future<void> reportOnWhatsapp() async {
    // Format the message to be sent on WhatsApp
    String formattedMessage = Uri.encodeComponent(
      "Hey, There's some error in my application. Please look into it:-\n\n",
    );

    MyAppAmplitudeAndFirebaseAnalitics().logEvent(
      event: LogEventsName.instance().chat_support,
    );

    // Construct the WhatsApp URL with the formatted message
    String whatsappUrl = 'https://wa.me/+917993478539?text=$formattedMessage';

    // Launch WhatsApp with the message
    await AppOpener.launchAppUsingUrl(link: whatsappUrl);
  }

  void otp_ver_screen({required String number}) {}
}
