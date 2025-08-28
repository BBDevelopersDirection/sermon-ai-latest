import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sermon/reusable/my_scaffold_widget.dart';
import 'package:sermon/reusable/progress_indicator.dart';
import 'package:sermon/services/token_check_service/login_check_cubit.dart';

import '../../../../../models/playlist_and_episode_model_old.dart';
import '../../../../../reusable/pulsing_icon_anim.dart';

class EpisodeListPage extends StatefulWidget {
  String series_name;
  String author;
  List<EpisodeModel> model;
  EpisodeListPage(
      {super.key,
      required this.series_name,
      required this.model,
      required this.author});

  @override
  State<EpisodeListPage> createState() => _EpisodeListPageState();
}

class _EpisodeListPageState extends State<EpisodeListPage> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Series',
            style: TextStyle(
              color: Color(0xFF3A3A3A),
              fontSize: 20,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w500,
              height: 1.20,
            ),
          ),
          centerTitle: false,
          titleSpacing: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: AutoSizeText(
                widget.series_name,
                maxLines: 1,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color(0xFF3A3A3A),
                  fontSize: 18,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.12,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: AutoSizeText(
                widget.author,
                maxLines: 1,
                style: TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 12,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.12,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return _episode_cards(
                      thumbnailUrl: widget.model[index].episodeThumbnail,
                      name: widget.model[index].episodeName,
                      fun: (index) {
                        context.read<LoginCheckCubit>().validate_and_redirect(
                            url: widget.model[index].episodeUrl,
                            context: context);
                      },
                      index: index);
                },
                itemCount: widget.model.length,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _episode_cards(
      {required String thumbnailUrl,
      required String name,
      required int index,
      required Function(int index) fun}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          leading: SizedBox(
              width: 56,
              height: 56,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                      color: Colors.grey.shade200,
                      child: CachedNetworkImage(
                        imageUrl: thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Center(
                              child: PulsingIconAnim(
                                  appLogoColor: Colors
                                      .black45), // Show progress indicator
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )))),
          title: Text(
            name,
            style: TextStyle(
              color: Color(0xFF3A3A3A),
              fontSize: 20,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w600,
              height: 1.20,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios_outlined),
          onTap: () => fun(index),
        ),
      ],
    );
  }
}
