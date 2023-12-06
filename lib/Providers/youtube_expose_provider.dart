
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Services/download_helper_service.dart';

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

final youtubeExposeVideoMuxDownload = StreamProvider.family.autoDispose((
  ref,
  ({
    MuxedStreamInfo selectedMux,
    Video video,
    StreamManifest ytManifest,
  }) data,
) async* {
  DownloadHelperService downloadHelperService = DownloadHelperService(
    ytXpose: ref.read(youtubeExposeProvider),
    selectedMux: data.selectedMux,
    video: data.video,
    ytManifest: data.ytManifest,
  );

  ref.onDispose(() {
    if (downloadHelperService.currentProgress !=
        downloadHelperService.totalBytes) {
      downloadHelperService.deleteFile();
    }
  });

  yield* downloadHelperService.startSavingFile();
});
