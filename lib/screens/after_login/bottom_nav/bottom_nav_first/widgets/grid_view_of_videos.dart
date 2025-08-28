import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../models/playlist_and_episode_model_old.dart';
import '../../../../../reusable/pulsing_icon_anim.dart';
import '../../../../../services/token_check_service/login_check_cubit.dart';

class GridViewOfVideos extends StatelessWidget {
  const GridViewOfVideos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          childAspectRatio: 9 / 16,
          mainAxisSpacing: 16,
        ),
        padding: const EdgeInsets.all(16),
        itemCount: playList.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTap: () {
                context.read<LoginCheckCubit>().redirect_user_to_episode_page(
                    context: context, index: index);
              },
              child: CachedNetworkImage(
                imageUrl: playList[index].thumbnail,
                fit: BoxFit.fitHeight,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade300,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: PulsingIconAnim(
                        appLogoColor: Colors.black26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
