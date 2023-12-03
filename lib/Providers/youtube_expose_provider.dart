import 'dart:developer';
import 'dart:io';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Models/flutter_downloader_download_item_model.dart';

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
  DownloadingTaskModel currentTask = DownloadingTaskModel(
    taskId: '',
    status: DownloadTaskStatus.enqueued,
    progress: 0,
    url: data.video.url,
    filename: '',
    savedDir: '',
    timeCreated: DateTime.now().millisecondsSinceEpoch,
    allowCellular: true,
  );

  try {
    Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');
    currentTask = currentTask.copyWith(
      savedDir: downloadsDirectory.path,
    );

    yield currentTask;

    final yt = ref.read(youtubeExposeProvider);

    var stream = yt.videos.streamsClient.get(data.selectedMux);

    // Generate and format File Name
    var audioName = data.ytManifest.audioOnly.first.container.name;

    final fileName = '${data.video.title}.$audioName'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');

    currentTask = currentTask.copyWith(
      filename: fileName,
    );

    yield currentTask;

    // Progress variables

    int totalBytes = data.selectedMux.size.totalBytes;

    int currentProgress = 0;

    currentTask = currentTask.copyWith(
      progress: currentProgress,
    );
    yield currentTask;

    // Create the message and set the cursor position.
    final msg = 'Downloading ${data.video.title}.$audioName';
    stdout.writeln(msg);

    // Create a file for writing.
    var file = File('${downloadsDirectory.path}/$fileName');

    // Delete the file if exists.
    if (file.existsSync()) {
      file.deleteSync();

      //throw Exception('File with same name already exist!');
    }

    // Open the file in writeAppend.
    final output = file.openWrite(mode: FileMode.writeOnlyAppend);

    log('Starting to download video......');

    await for (final data in stream) {
      // Keep track of the current downloaded data.
      currentProgress += data.length;

      // Calculate the current progress.
      final progress = ((currentProgress / totalBytes) * 100).ceil();
      //log('$progress');
      currentTask = currentTask.copyWith(
        progress: progress,
        status: DownloadTaskStatus.running,
      );
      yield currentTask;

      // Update the progressbar.
      //progressBar.update(progress);

      // Write to file.
      output.add(data);
    }

    await output.close();

    yield currentTask.copyWith(
      status: DownloadTaskStatus.complete,
    );

    log('Video download complete......');
  } catch (e) {
    log('unable to download video......');
    throw Exception('$e');
  }
});
