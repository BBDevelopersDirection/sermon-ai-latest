class PlayListModelOld {
  String name;
  String author;
  String thumbnail;
  List<EpisodeModel> episodeModel;
  PlayListModelOld(
      {required this.name,
      required this.author,
      required this.thumbnail,
      required this.episodeModel});
}

class EpisodeModel {
  int episodeNum;
  String episodeName;
  String episodeUrl;
  String episodeThumbnail;

  EpisodeModel({
    required this.episodeNum,
    required this.episodeName,
    required this.episodeUrl,
    required this.episodeThumbnail,
  });
}

List<PlayListModelOld> playList = [
  //1
  PlayListModelOld(
    name: 'Untold Truth About Prayer',
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1wF7jiXBgrEVlwyBlxxthkJ4ZI3mlSYU9&export=download',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi4yWtNTrkchwLODZoBapyrU/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi4yWtNTrkchwLODZoBapyrU/thumbnail.jpg',
      ),
      EpisodeModel(
          episodeNum: 2,
          episodeName: 'Episode 2',
          episodeUrl: 'https://vod.api.video/vod/vi2xhVIaRwc5l3z19ozJyvl2/mp4/source.mp4',
          episodeThumbnail: 'https://vod.api.video/vod/vi2xhVIaRwc5l3z19ozJyvl2/thumbnail.jpg'),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/vi6z28yWwVFnREqHdiVAoViB/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi6z28yWwVFnREqHdiVAoViB/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 4,
        episodeName: 'Episode 4',
        episodeUrl: 'https://vod.api.video/vod/vi2Os0PQi61SWhirYPLQpx6X/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi2Os0PQi61SWhirYPLQpx6X/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 5,
        episodeName: 'Episode 5',
        episodeUrl: 'https://vod.api.video/vod/vi2KDBmT8GgvYpLhol6X6p0L/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi2KDBmT8GgvYpLhol6X6p0L/thumbnail.jpg',
      ),
    ],
    author: 'Bishop Samuel Patta',
  ),
  //2
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1uByi1vkdR1opUEOe9W8tVvLIJgB6tI5K&export=download',
    name: 'Deep Secret About Future',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi7CORqHm2emmM5awQ5hTy1i/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi7CORqHm2emmM5awQ5hTy1i/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi6rHmmPi7JtgI7jAbqJ5VBL/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi6rHmmPi7JtgI7jAbqJ5VBL/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/vi2WK2flr0ebDRHKwQVynNFC/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi2WK2flr0ebDRHKwQVynNFC/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 4,
        episodeName: 'Episode 4',
        episodeUrl: 'https://vod.api.video/vod/vi2F6aHzLNRVxV6SqvRqqRKU/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi2F6aHzLNRVxV6SqvRqqRKU/thumbnail.jpg',
      ),
    ],
    author: 'Bisop Samuel Patta',
  ),
  //3
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1uOVD3OGtSnpxaz7nKYvmicvXuN-nVZWL&export=download',
    name: 'Devils Vs Angles',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi7Y7BqQ0kILdKZEooLvZFq/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi7Y7BqQ0kILdKZEooLvZFq/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi7XpfsOAJQf6IWR4aqWcuC6/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi7XpfsOAJQf6IWR4aqWcuC6/thumbnail.jpg',
      ),
    ],
    author: 'Prophet Leon',
  ),
  //4
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1uOt0updHY3CD9kpG47Brvkh_7DeWOI1A&export=download',
    name: 'The Secrets Of Smith Wiggesorth',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi3q9ZatqYTxFeUnDYZzqq4O/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi3q9ZatqYTxFeUnDYZzqq4O/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi2gbcEkWFiSx5BfBgbLDNVf/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi2gbcEkWFiSx5BfBgbLDNVf/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/vi5Ueo3PJUNIgFeCm41BoD8r/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi5Ueo3PJUNIgFeCm41BoD8r/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 4,
        episodeName: 'Episode 4',
        episodeUrl: 'https://vod.api.video/vod/vi46cmuaVSUxNAI77ntAHsIM/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi46cmuaVSUxNAI77ntAHsIM/thumbnail.jpg',
      ),
    ],
    author: 'Unknown',
  ),
  //5
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1uUmnZhiJt1fKpb5RXGu0cKXwBAYqZ7sN&export=download',
    name: 'How To Know The Holy Spirit',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/viK4E26tWZ8r6xILQ1KgDce/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/viK4E26tWZ8r6xILQ1KgDce/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi5pNc2lwtkGT3LVazRhIOR9/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi5pNc2lwtkGT3LVazRhIOR9/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/vi2PcEuzf8m3pZZKwVfBF3oN/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi2PcEuzf8m3pZZKwVfBF3oN/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 4,
        episodeName: 'Episode 4',
        episodeUrl: 'https://vod.api.video/vod/vi3v0jMZXGgEc6hJ7zfHupw8/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi3v0jMZXGgEc6hJ7zfHupw8/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 5,
        episodeName: 'Episode 5',
        episodeUrl: 'https://vod.api.video/vod/vi63HhYpByETvm7zbZJjwDiS/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi63HhYpByETvm7zbZJjwDiS/thumbnail.jpg',
      ),
    ],
    author: 'Pastor Vlad',
  ),
  //6
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1uUnILPkKoF-mybtzbSA8x3gfLLWIAI2V&export=download',
    name: 'Who Is Jesus',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi3x8TRxLXvQdNhRYVDCxkNT/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi3x8TRxLXvQdNhRYVDCxkNT/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi7T5P2JgdWbEBo9uuE4AJ3h/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi7T5P2JgdWbEBo9uuE4AJ3h/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/vi5Xmd8VWvzou7bzWf2bMtzX/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi5Xmd8VWvzou7bzWf2bMtzX/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 4,
        episodeName: 'Episode 4',
        episodeUrl: 'https://vod.api.video/vod/vi37TQIZFYtlBiDDqIZDVmkJ/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi37TQIZFYtlBiDDqIZDVmkJ/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 5,
        episodeName: 'Episode 5',
        episodeUrl: 'https://vod.api.video/vod/vi1O8WqeKCNw0vwmvo9P9RFa/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi1O8WqeKCNw0vwmvo9P9RFa/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 6,
        episodeName: 'Episode 6',
        episodeUrl: 'https://vod.api.video/vod/vi4P8pgRypx6O0DuNhzWFdve/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi4P8pgRypx6O0DuNhzWFdve/thumbnail.jpg',
      ),
    ],
    author: 'Evangelish Billy Graham',
  ),
  //7
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1uWDDxGJ0_B9r_XHQHhxp6IjuIDtXJqu3&export=download',
    name: 'Taking Controls Of Your Thoughts',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi5x4VyG4YqfG3851cBdCyhF/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi5x4VyG4YqfG3851cBdCyhF/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi6EpO9kmibs8YTRGKN9pYWa/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi6EpO9kmibs8YTRGKN9pYWa/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/vi5QeynrKWrAjdmGox8v7bnK/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi5QeynrKWrAjdmGox8v7bnK/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 4,
        episodeName: 'Episode 4',
        episodeUrl: 'https://vod.api.video/vod/vi62gBgVezkSiq6bBgRHobHo/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi62gBgVezkSiq6bBgRHobHo/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 5,
        episodeName: 'Episode 5',
        episodeUrl: 'https://vod.api.video/vod/vi1KXo2HYZrcSiQZuqK8D233/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi1KXo2HYZrcSiQZuqK8D233/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 6,
        episodeName: 'Episode 6',
        episodeUrl: 'https://vod.api.video/vod/vi7N8fABRN6D69v5fwaCeB75/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi7N8fABRN6D69v5fwaCeB75/thumbnail.jpg',
      ),
    ],
    author: 'Doctor Charles Stanley',
  ),
  //8
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1uTK3pOEzlCpu-z3kEqT7PWTDilHOdtak&export=download',
    name: 'God What Should I Do?',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi2CqZMyg0E7GijEGMfBY9rf/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi2CqZMyg0E7GijEGMfBY9rf/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi52fJpvHMdTCl0AqCxMZEOS/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi52fJpvHMdTCl0AqCxMZEOS/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/vi6RRgPBsIKyUR9Xbrpb6yZj/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi6RRgPBsIKyUR9Xbrpb6yZj/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 4,
        episodeName: 'Episode 4',
        episodeUrl: 'https://vod.api.video/vod/vi7RUbqBqMQfK66oVnbbvtZd/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi7RUbqBqMQfK66oVnbbvtZd/thumbnail.jpg',
      ),
    ],
    author: 'Pastor Joyce Meyer',
  ),
  //9
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1u4SBLEGyHJ-QyTTTsEdG1x6O-AuLnc4y&export=download',
    name: 'The Player Which Will Move God',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi10mluiCyS1cNiSzUTkiU6O/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi10mluiCyS1cNiSzUTkiU6O/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi2bDLXkqDXWByOfzQww0uwv/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi2bDLXkqDXWByOfzQww0uwv/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/vi6t6heXFHN318G2ExDKeBHz/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi6t6heXFHN318G2ExDKeBHz/thumbnail.jpg',
      ),
    ],
    author: 'Dr. Charles Stanley',
  ),
  //10
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1tmWmhf9j5hTwTWiFH4UlkayQNjUbfRoj&export=download',
    name: 'The Ultimate Guide To Letting Go',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi3ZJ8J1UaEoDRzw0Z2ll8Bo/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi3ZJ8J1UaEoDRzw0Z2ll8Bo/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi6usrs2TVgd17z7v6ijr4Aj/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi6usrs2TVgd17z7v6ijr4Aj/thumbnail.jpg',
      ),
    ],
    author: 'Pastor Steven Furtick',
  ),
  //11
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1txrc9wnh2q7B1MuP4_wM_9jWgqAd_0Eq&export=download',
    name: '10 Signs You Have A Demon',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi01ghnATLBZKf8w8JyGKufV/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi01ghnATLBZKf8w8JyGKufV/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi6PhzZmFceLT9v0Ph3yrelM/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi6PhzZmFceLT9v0Ph3yrelM/thumbnail.jpg',
      ),
    ],
    author: 'Pastor Vlad',
  ),
  //12
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1ugZjP8Th41YtpVYJFTyJXtEExQTaijRn&export=download',
    name: 'How To Find A Shouse With God\'S Help',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi4X7AFyR999AI1banquXkfV/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi4X7AFyR999AI1banquXkfV/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi7TAAQyeNs8Ww9Qv5vjc3Az/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi7TAAQyeNs8Ww9Qv5vjc3Az/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/vi39aGdkFv9mVyNgsXQGw31F/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi39aGdkFv9mVyNgsXQGw31F/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 4,
        episodeName: 'Episode 4',
        episodeUrl: 'https://vod.api.video/vod/vi6JMrmBtDOxhjO44cYLSyxM/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi6JMrmBtDOxhjO44cYLSyxM/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 5,
        episodeName: 'Episode 5',
        episodeUrl: 'https://vod.api.video/vod/vi4jM1QCqDx79oxtX63jUjc/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi4jM1QCqDx79oxtX63jUjc/thumbnail.jpg',
      ),
    ],
    author: 'Pastor Shan',
  ),
  //13
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1W5U78e_6e-zyodpqRyywR7jJE-Redg4I&export=download',
    name: 'Only Your Faith Can Make You Victorious',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi2r6NESV8etVmbRx8G5O4gm/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi2r6NESV8etVmbRx8G5O4gm/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi5M1W9Yo6Hd4k0Hm4SWc0hy/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi5M1W9Yo6Hd4k0Hm4SWc0hy/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/vi3EwciP1CnxKJOraNdIRnpy/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi3EwciP1CnxKJOraNdIRnpy/thumbnail.jpg',
      ),
    ],
    author: 'Pastor Joel Osteen',
  ),
  //14
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1Xvez1Qc3hfM_MThbnWpZSzyj8RSVRnJ0&export=download',
    name: 'God Wants You Healed',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi24X1YnN6VDAiMzQqMRQ16Q/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi24X1YnN6VDAiMzQqMRQ16Q/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi17ircouXTmY2exaH0fHlsJ/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi17ircouXTmY2exaH0fHlsJ/thumbnail.jpg',
      ),
    ],
    author: 'Pastor Jospeh Prince',
  ),
  //15
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1pJQ_XV1qk9nErml-KvsjCM59ATjsAgTG&export=download',
    name: 'God Wants You To Know These 5 Things',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi3irdUMrmCOE63P0rjFg0Ds/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi3irdUMrmCOE63P0rjFg0Ds/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi6qaOcfXnvi7MejTIh2l3aX/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi6qaOcfXnvi7MejTIh2l3aX/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/vi4aama5WswrNgDkHu1ffQiH/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi4aama5WswrNgDkHu1ffQiH/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 4,
        episodeName: 'Episode 4',
        episodeUrl: 'https://vod.api.video/vod/viUn9JGIA0n2CvnCadCD3V6/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/viUn9JGIA0n2CvnCadCD3V6/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 5,
        episodeName: 'Episode 5',
        episodeUrl: 'https://vod.api.video/vod/vi5dOJ0qAeRNqbiztEFBaWqK/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi5dOJ0qAeRNqbiztEFBaWqK/thumbnail.jpg',
      ),
    ],
    author: 'Brother Benny Hinn',
  ),

  //16
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1gYwnIEJPUo2A4Nejyrx4A3NO3-t02JwS&export=download',
    name: '5 Keys To Transform Your Prayer Life',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi2Ro4mYzOFyYKZMfl2BV9YW/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi2Ro4mYzOFyYKZMfl2BV9YW/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vicqRA0DqRkx1vgIhbsHBbh/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vicqRA0DqRkx1vgIhbsHBbh/thumbnail.jpg',
      ),
    ],
    author: 'Pastor Ankit Servan',
  ),

  //17
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1hEAlriWtmXs34CcqmQ95R_DulExKAU9w&export=download',
    name: 'Think Like A CEO',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/viZu0CHNBrWYn9zBXySbux5/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/viZu0CHNBrWYn9zBXySbux5/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vizmAFeSk4G0qar9eBT6HiK/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vizmAFeSk4G0qar9eBT6HiK/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/visFdel0Ik6FrK9IBoN9QXy/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/visFdel0Ik6FrK9IBoN9QXy/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 4,
        episodeName: 'Episode 4',
        episodeUrl: 'https://vod.api.video/vod/vi5lBM7q31X7ivSsCaSWnk7q/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi5lBM7q31X7ivSsCaSWnk7q/thumbnail.jpg',
      ),
    ],
    author: 'Pastor Sam Adeyemi',
  ),

  //18
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1r8Q4IPYIzj4vK1I92NJwvmJe-Id7lTP8&export=download',
    name: 'Speak His Word Daily',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi1fZReMiaztvwyNqwMHfn38/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi1fZReMiaztvwyNqwMHfn38/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi2pGZpTcaWZTgG9pG3Uswqy/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi2pGZpTcaWZTgG9pG3Uswqy/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 3,
        episodeName: 'Episode 3',
        episodeUrl: 'https://vod.api.video/vod/vi7iNWmU3i5erlbxG76P9ku3/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi7iNWmU3i5erlbxG76P9ku3/thumbnail.jpg',
      ),
    ],
    author: 'Pastor Priya Anand',
  ),

  //19
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=16sq9UQ6LozubXMDReONvy_w2-QsmAn5m&export=download',
    name: 'Get Healed As You Watch',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi53PJCnZi5byoygLxD0qJGw/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi53PJCnZi5byoygLxD0qJGw/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/viAtgNLDHItOWB46JDgekjV/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/viAtgNLDHItOWB46JDgekjV/thumbnail.jpg',
      ),
    ],
    author: 'Pastor Poul Dhinkaran',
  ),

  //20
  PlayListModelOld(
    thumbnail:
    'https://drive.usercontent.google.com/uc?id=1HNUx9royZ0Xopt4tGhKkLfreiy7-J1X2&export=download',
    name: 'Hidden Secret About Prayer You Must Know',
    episodeModel: [
      EpisodeModel(
        episodeNum: 1,
        episodeName: 'Episode 1',
        episodeUrl: 'https://vod.api.video/vod/vi3wmPuLy0uyPxxKthbBeSik/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi3wmPuLy0uyPxxKthbBeSik/thumbnail.jpg',
      ),
      EpisodeModel(
        episodeNum: 2,
        episodeName: 'Episode 2',
        episodeUrl: 'https://vod.api.video/vod/vi193Y8sqdqR1umU1geLC8FR/mp4/source.mp4',
        episodeThumbnail: 'https://vod.api.video/vod/vi193Y8sqdqR1umU1geLC8FR/thumbnail.jpg',
      ),
    ],
    author: 'Bishop Samuel Patta',
  ),

];
