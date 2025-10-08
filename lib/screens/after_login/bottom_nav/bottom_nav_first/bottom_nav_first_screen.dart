import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:sermon/models/video_data_model.dart';
import 'package:sermon/reusable/logger_service.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav/bottom_nav_cubit.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav_first/widgets/carasol_slider.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav_first/widgets/grid_view_of_videos.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav_first/widgets/section_to_show.dart';
import 'package:sermon/services/firebase/models/user_models.dart';
import 'package:sermon/services/firebase/video_management/video_functions.dart';
import 'package:sermon/services/hive_box/hive_box_functions.dart';
import 'package:sermon/services/token_check_service/login_check_cubit.dart';
import '../../../../reusable/my_scaffold_widget.dart';
import '../../../../utils/app_color.dart';

class BottomNavFirstScreen extends StatefulWidget {
  const BottomNavFirstScreen({super.key});

  @override
  State<BottomNavFirstScreen> createState() => _BottomNavFirstScreenState();
}

class _BottomNavFirstScreenState extends State<BottomNavFirstScreen> {
  @override
  void initState() {
    // FirebaseUser user = HiveBoxFunctions().getLoginDetails()!;
    // AppLogger.i(user.createdDate.toString());
    context.read<LoginCheckCubit>().checkForUpdate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      child: Scaffold(
        backgroundColor: MyAppColor.background,
        body: SafeArea(
          child: Container(
            color: Colors.transparent,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12),
                  child: Text(
                    'Hello there,',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: AutoSizeText(
                    'Serman\'s suniye aur aapke spiritual life ko grow kare.',
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Divider(),
                StreamBuilder<List<SectionDetail>>(
                  stream: VideoFunctions().getSectionsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final sections = snapshot.data!;
                    return ListView.builder(
                      itemCount: sections.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return PropheticCarousel(
                        videoDataModelList: sections[0].videos,
                      ); // Skip the first item as it's already shown in the carousel
                        } else {
                          return SectionToShow(sectionDetail: sections[index]);
                        }
                      },
                    );
                  },
                ),

                // Container(
                //   child: Center(
                //     child: CircularProgressIndicator(),
                //   ),
                // ):
                // ListView.builder(
                //   itemCount: _sliderVideos.length,
                //   physics: NeverScrollableScrollPhysics(),
                //   shrinkWrap: true,
                //   itemBuilder: (context, index) {
                //     if(index == 0) {
                //       return SizedBox.shrink(); // Skip the first item as it's already shown in the carousel
                //     }else {
                //       return SectionToShow(
                //         sectionDetail: _sliderVideos[index],
                //       );
                //     }
                //   },
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
