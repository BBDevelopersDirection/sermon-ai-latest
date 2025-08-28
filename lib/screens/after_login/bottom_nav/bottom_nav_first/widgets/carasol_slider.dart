import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../models/video_data_model.dart';
import '../../../../../reusable/video_player_using_id.dart';

class PropheticCarousel extends StatefulWidget {
  List<VideoDataModel> videoDataModelList;
  PropheticCarousel({super.key, required this.videoDataModelList});

  @override
  State<PropheticCarousel> createState() => _PropheticCarouselState();
}

class _PropheticCarouselState extends State<PropheticCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 12),
          child: Text(
            "Videos Of The Day",
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
        SizedBox(height: 18),
        CarouselSlider.builder(
          itemCount: widget.videoDataModelList.length,
          itemBuilder: (context, index, realIdx) {
            var videoData = widget.videoDataModelList[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerUsingId(
                      url: videoData.video,
                      isCaraousel: true,
                    ),
                  ),
                );
              },
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: videoData.thumbnailUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            // height: 250,
            aspectRatio: 16 / 9,
            enlargeCenterPage: true,
            autoPlay: true,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() => _current = index);
            },
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: AnimatedSmoothIndicator(
            activeIndex: _current,
            count: widget.videoDataModelList.length,
            effect: ExpandingDotsEffect(
              dotHeight: 10,
              dotWidth: 10,
              activeDotColor: Color.fromRGBO(31, 32, 214, 1),
              dotColor: Color.fromRGBO(228, 228, 232, 0.5),
              expansionFactor: 3.0,
            ),
          ),
        ),
        SizedBox(height: 18),
      ],
    );
  }
}
