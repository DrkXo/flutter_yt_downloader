import 'dart:developer';
import 'dart:io';

import 'package:flutter_yt_downloader/Utility/yt_downloader_utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Models/download_item_model.dart';

class DownloadHelperService {
  final YoutubeExplode ytXpose;
  final MuxedStreamInfo selectedMux;
  final Video video;
  final StreamManifest ytManifest;
  late String fileName;
  int totalBytes = 0;
  int currentProgress = 0;
  int progress = 0;
  late File saveFile;
  Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');
  late DownloadingTaskModel _currentTask;
  late Stream<List<int>> stream;

  DownloadHelperService({
    required this.ytXpose,
    required this.selectedMux,
    required this.video,
    required this.ytManifest,
  }) {
    _initializeVariables();
  }

  DownloadingTaskModel get currentTask => _currentTask;

  void deleteFile() {
    if (saveFile.existsSync()) {
      saveFile.deleteSync();
    }
  }

  Stream<DownloadingTaskModel> startSavingFile() async* {
    // Delete the file if exists.
    deleteFile();

    // Open the file in writeAppend.
    final output = saveFile.openWrite(mode: FileMode.writeOnlyAppend);

    log('Starting to download video......');

    try {
      await for (final data in stream) {
        // Keep track of the current downloaded data.
        currentProgress += data.length;

        // Calculate the current progress.
        final progress = ((currentProgress / totalBytes) * 100).ceil();
        //log('$progress');
        _currentTask = _currentTask.copyWith(
          progress: progress,
          status: DownloadTaskStatus.running,
        );
        yield _currentTask;

        // Update the progressbar.
        //progressBar.update(progress);

        // Write to file.
        output.add(data);
      }

      await output.close();

      yield _currentTask.copyWith(
        status: DownloadTaskStatus.complete,
      );
      log('Video download complete......');
    } catch (e) {
      await output.close();
      deleteFile();
      throw Exception(e.toString());
    }
  }

  void _initializeVariables() {
    // Generate and format File Name
    var audioName = ytManifest.audioOnly.first.container.name;

    fileName = '${video.title}.$audioName'.cleanUpYoutubeVideoTitle;

    // Create a file for writing.
    saveFile = File('${downloadsDirectory?.path}/$fileName');

    // Create Stream
    stream = ytXpose.videos.streamsClient.get(selectedMux);

    // Progress variables

    totalBytes = selectedMux.size.totalBytes;

    currentProgress = 0;

    // Create Task Skeleton
    _currentTask = DownloadingTaskModel(
      taskId: '',
      status: DownloadTaskStatus.enqueued,
      progress: currentProgress,
      url: video.url,
      filename: fileName,
      savedDir: downloadsDirectory!.path,
      timeCreated: DateTime.now().millisecondsSinceEpoch,
      allowCellular: true,
    );
  }
}

Future<void> download(String url) async {
  final yt = YoutubeExplode();

  // Get video metadata.
  final YtVideo = await yt.videos.get(url);

  // Get the video manifest.
  final manifest = await yt.videos.streamsClient.getManifest(url);
  final streams = manifest.videoOnly;

  // Get the audio track with the highest bitrate.
  final audio = streams.first;
  final audioStream = yt.videos.streamsClient.get(audio);

  // Get the audio track with the highest bitrate.
  final video = streams.last;
  final viedoStream = yt.videos.streamsClient.get(audio);

  // Compose the file name removing the unallowed characters in windows.

  final audioFileName =
      '${YtVideo.title}.${audio.container.name}'.cleanUpYoutubeVideoTitle;

  final videoFileName =
      '${YtVideo.title}.${video.container.name}'.cleanUpYoutubeVideoTitle;

  final audioFile = File(
      '/storage/emulated/0/Download/[${audio.qualityLabel}]Audio_$audioFileName');

  final videoFile = File(
      '/storage/emulated/0/Download/[${video.qualityLabel}]Video_$videoFileName');

  // Delete the file if exists.
  if (audioFile.existsSync()) {
    audioFile.deleteSync();
  }

  // Delete the file if exists.
  if (videoFile.existsSync()) {
    videoFile.deleteSync();
  }

  // Open the file in writeAppend.
  final outputAudioFile = audioFile.openWrite(mode: FileMode.writeOnlyAppend);

  final outputVideoFile = videoFile.openWrite(mode: FileMode.writeOnlyAppend);

  // Track the file download status.
  final len = audio.size.totalBytes;
  var count = 0;

  // Create the message and set the cursor position.
  final msg = 'Downloading Audio ${YtVideo.title}.${audio.container.name}';
  log(msg);

  // Listen for data received.
  await for (final data in audioStream) {
    // Keep track of the current downloaded data.
    count += data.length;

    // Calculate the current progress.
    final progress = ((count / len) * 100).ceil();

    log(progress.toStringAsFixed(2));

    // Write to file.
    outputAudioFile.add(data);
  }
  await outputAudioFile.close();

  // Track the file download status.
  final len1 = video.size.totalBytes;
  var count1 = 0;

  // Create the message and set the cursor position.
  final msg1 = 'Downloading Video ${YtVideo.title}.${audio.container.name}';
  log(msg1);

  // Listen for data received.
  await for (final data in viedoStream) {
    // Keep track of the current downloaded data.
    count1 += data.length;

    // Calculate the current progress.
    final progress = ((count1 / len1) * 100).ceil();

    log(progress.toStringAsFixed(2));

    // Write to file.
    outputVideoFile.add(data);
  }
  await outputVideoFile.close();
}
