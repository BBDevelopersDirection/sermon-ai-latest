import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:sermon/models/video_data_model.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav/reusable/bottom_nav_container.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav_first/bottom_nav_first_cubit.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav_first/widgets/bottom_nav_first_screen_old.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav_second/bottom_nav_second_cubit.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav_second/bottom_nav_second_screen.dart';
import '../../../../services/log_service/log_service.dart';
import '../../../../services/log_service/log_variables.dart';
import '../../../../utils/app_assets.dart';
import '../../../../utils/app_color.dart';
import '../../../../services/firebase_notification_mine.dart';
import '../bottom_nav_first/bottom_nav_first_screen.dart';
import 'bottom_nav_cubit.dart';
import 'bottom_nav_state.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late SectionDetail? _sliderVideos;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List of screen widgets to show based on the index
  final List<Widget> _screens = [
    BlocProvider(
      create: (context) => BottomNavFirstCubit(),
      child: BottomNavFirstScreen(),
    ),
    BlocProvider(
      create: (context) => BottomNavSecondCubit(),
      child: BottomNavSecondScreen(),
    ),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == 0) {
      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().homeScreenButton,
      );
    } else {
      MyAppAmplitudeAndFirebaseAnalitics().logEvent(
        event: LogEventsName.instance().profileScreenButton,
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    NotificationService.instance.requestPermissionAndGetToken();
    context.read<BottomNavCubit>().saveKeyBottomNav(
      bottomNavScaffoldKey: _scaffoldKey,
    );
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  bool _isKeyboardVisible = false;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;

    if (newValue != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newValue;
      });

      if (_isKeyboardVisible) {
        // ✅ Call your function when keyboard appears
        context.read<BottomNavCubit>().hideBottomNavBar();
      } else {
        context.read<BottomNavCubit>().unhideBottomNavBar();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(splashFactory: NoSplash.splashFactory),
      child: BlocBuilder<BottomNavCubit, BottomNavState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: MyAppColor.background,
            key: _scaffoldKey,
            body: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _screens[_selectedIndex],
            ),
            bottomNavigationBar: state.hideBottomBar
                ? null
                : BottomNavigationBar(
                    backgroundColor: MyAppColor.BOTTOM_NAVBACKGROUND,
                    elevation: 0,
                    selectedFontSize: 0,
                    unselectedFontSize: 0,
                    currentIndex: _selectedIndex,
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    onTap: _onItemTapped,
                    items: [
                      BottomNavigationBarItem(
                        icon: _selectedIndex == 0
                            ? BottomNavContainer(asset: IconlyBold.home)
                            : BottomNavContainer(asset: IconlyLight.home),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: _selectedIndex == 1
                            ? BottomNavContainer(asset: IconlyBold.profile)
                            : BottomNavContainer(asset: IconlyLight.profile),
                        label: '',
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
