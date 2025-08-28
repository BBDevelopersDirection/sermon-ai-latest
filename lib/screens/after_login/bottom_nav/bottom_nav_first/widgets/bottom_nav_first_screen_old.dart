import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:sermon/screens/after_login/bottom_nav/bottom_nav_first/widgets/grid_view_of_videos.dart';
import 'package:sermon/utils/app_color.dart';

import '../../../../../reusable/my_scaffold_widget.dart';

class BottomNavFirstScreenOld extends StatelessWidget {
  const BottomNavFirstScreenOld({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      child: Scaffold(
        backgroundColor: MyAppColor.background,
        body: SafeArea(
          child: Container(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12),
                  child: Text(
                    'Sermons AI',
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
                    'Faith comes by hearing the word of god',
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
                SizedBox(
                  height: 12,
                ),
                Divider(),
                Expanded(child: GridViewOfVideos())
              ],
            ),
          ),
        ),
      ),
    );
  }
}
