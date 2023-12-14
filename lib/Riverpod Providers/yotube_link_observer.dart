import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_yt_downloader/Utility/yt_downloader_utils.dart';

final youtubeLinkObserverProvider =
    FutureProvider.family((ref, String? url) async {
  final util = YoutubeUtils();

  if (url == null) {
    return Future.value(null);
  } else {
    return Future.value(util.getYoutubeVideoIdByURL(url));
  }
});
