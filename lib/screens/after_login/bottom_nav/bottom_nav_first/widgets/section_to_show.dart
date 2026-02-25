import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sermon_tv/models/video_data_model.dart';

import '../../../../../reusable/progress_indicator.dart';
import '../../../../../reusable/video_player_using_id.dart';

class SectionToShow extends StatelessWidget {
  SectionDetail sectionDetail;
  SectionToShow({super.key, required this.sectionDetail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            sectionDetail.nameOfSection,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.12,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(sectionDetail.videos.length, (index) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => VideoPlayerUsingId(
                                  url: sectionDetail.videos[index].video,
                                )));
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width /
                            2.1, // 👈 Same width
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: Colors.black,
                            child: CachedNetworkImage(
                              imageUrl:
                                  sectionDetail.videos[index].thumbnailUrl,
                              placeholder: (context, url) => Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                  child: MyAppCircularProgressIndicator(),
                                ),
                              ),
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8), // Add some space between image and text
                    SizedBox(
                      width: MediaQuery.of(context).size.width /
                          2.1, // 👈 Same width as video
                      child: Text(
                        sectionDetail.videos[index].title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 12), // Add some space after the section
      ],
    );
  }
}
