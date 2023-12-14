import 'dart:developer';
import 'dart:io';
import 'package:flutter_yt_downloader/Services/utils.dart';
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
