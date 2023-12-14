import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final youtubeExposeProvider = Provider.autoDispose((ref) {
  final ytXpose = YoutubeExplode();
  return ytXpose;
});

final youtubeExposeVideoStreamDataProvider =
    FutureProvider.family.autoDispose((ref, String url) async {
  final yt = ref.watch(youtubeExposeProvider);
  try {
    final videoData = await yt.videos.get(url);
    StreamManifest streamManifest =
        await yt.videos.streamsClient.getManifest(videoData.id);

    var record = (videoData: videoData, streamManifest: streamManifest);
    return record;
  } catch (e) {
    throw Exception('Unable to get video data !');
  }
});
