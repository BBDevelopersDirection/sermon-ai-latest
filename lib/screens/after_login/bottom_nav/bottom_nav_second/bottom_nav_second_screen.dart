import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:sermon/reusable/my_scaffold_widget.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav_second/bottom_nav_second_cubit.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav_second/bottom_nav_second_state.dart';
import 'package:sermon/services/app_opner_service.dart';
import 'package:sermon/services/firebase/models/utility_model.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import 'package:sermon/services/token_check_service/login_check_cubit.dart';

import '../../../../services/log_service/log_service.dart';
import '../../../../services/log_service/log_variables.dart';

class BottomNavSecondScreen extends StatefulWidget {
  const BottomNavSecondScreen({super.key});

  @override
  State<BottomNavSecondScreen> createState() => _BottomNavSecondScreenState();
}

class _BottomNavSecondScreenState extends State<BottomNavSecondScreen> {
  @override
  void initState() {
    context.read<BottomNavSecondCubit>().initProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UtilityModel? utilityModel = context
        .watch<BottomNavSecondCubit>()
        .state
        .utilityModel;
    return MyScaffold(
      child: Scaffold(
        backgroundColor: Color(0xFF0F0F11),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFF2C2C35),
                  child: Icon(IconlyBold.profile, color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  HiveBoxFunctions().getLoginDetails()?.name ?? '',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Center(
                child: Text(
                  HiveBoxFunctions().getLoginDetails()?.phoneNumber ?? '',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
      
              // const SizedBox(height: 16),
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Color(0xFF2C2C35),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     minimumSize: const Size(double.infinity, 48),
              //   ),
              //   onPressed: () {},
              //   child: const Text(
              //     'Edit Profile',
              //     style: TextStyle(color: Colors.white),
              //   ),
              // ),
              // const SizedBox(height: 22),
              sectionHeader('Personal Information'),
              profileItem(
                'Name',
                HiveBoxFunctions().getLoginDetails()?.name ?? '',
              ),
              (HiveBoxFunctions().getLoginDetails()?.email ?? '').isNotEmpty
                  ? profileItem(
                      'Email',
                      HiveBoxFunctions().getLoginDetails()!.email,
                    )
                  : SizedBox.shrink(),
      
              profileItem(
                'Phone Number',
                HiveBoxFunctions().getLoginDetails()?.phoneNumber ?? '',
              ),
      
              sectionHeader('Billing Information'),
              BlocBuilder<BottomNavSecondCubit, BottomNavSecondState>(
                builder: (context, state) {
                  return profileItem(
                    'Subscription Status',
                    utilityModel?.isRecharged == true
                        ? 'Active'
                        : 'Inactive',
                  );
                },
              ),
      
              // BlocBuilder<BottomNavSecondCubit, BottomNavSecondState>(
              //   builder: (context, state) {
              //     final endDate = utilityModel?.rechargeEndDate;
              //     final formattedDate = endDate != null
              //         ? DateFormat('dd/MM/yyyy (HH:mm)').format(endDate)
              //         : 'N/A';
              
              //     return profileItem(
              //       'Subscription Expiry Date',
              //       formattedDate,
              //     );
              //   },
              // ),
      
              BlocBuilder<BottomNavSecondCubit, BottomNavSecondState>(
                builder: (context, state) {
                  final endDate = utilityModel?.rechargeEndDate;
      
                  // If null, return an empty SizedBox (i.e., don't show anything)
                  if (endDate == null) return const SizedBox.shrink();
      
                  final formattedDate = DateFormat('dd/MM/yyyy (HH:mm)').format(endDate);
      
                  return profileItem(
                    'Subscription Expiry Date',
                    formattedDate,
                  );
                },
              ),
      
      
              sectionHeader('Privacy & Security'),
              arrowItem(
                title: 'Privacy Policy',
                fun: () {
                  MyAppAmplitudeAndFirebaseAnalitics().logEvent(
                    event: LogEventsName.instance().privacy_policy,
                  );
                  AppOpener.launchPrivacyPolicy();
                },
              ),
      
              //
              // sectionHeader('Manage Subscription'),
              // arrowItem('Manage Subscription'),
              // arrowItem('Redeem a Gift Card'),
              sectionHeader('Support'),
              arrowItem(
                title: 'Contact Us',
                fun: () {
                  // Navigate to contact us page
                  context.read<LoginCheckCubit>().reportOnWhatsapp();
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(112, 35, 54, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () {
                  context.read<LoginCheckCubit>().log_out(context: context);
                },
                child: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget profileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget arrowItem({required String title, required Function fun}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.white,
      ),
      onTap: () {
        fun();
      },
    );
  }
}
