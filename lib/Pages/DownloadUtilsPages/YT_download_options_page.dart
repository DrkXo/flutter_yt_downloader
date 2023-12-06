import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../Providers/youtube_expose_provider.dart';
import 'YT_download_progress_page.dart';

class YTDownloadOptionsPage extends ConsumerStatefulWidget {
  const YTDownloadOptionsPage({
    super.key,
    required this.video,
    required this.ytManifest,
  });

  final Video video;
  final StreamManifest ytManifest;

  @override
  ConsumerState createState() => _YTDownloadOptionsPageState();
}

class _YTDownloadOptionsPageState extends ConsumerState<YTDownloadOptionsPage> {
  Directory? _downloadsDirectory;

  @override
  void initState() {
    super.initState();
    _requestDownloadsDirectory();
  }

  void _requestDownloadsDirectory() async {
    /*_downloadsDirectory =
        await getExternalStorageDirectories(type: StorageDirectory.downloads)
            .then((value) => Directory('/storage/emulated/0/Download'));*/

    _downloadsDirectory = await getDownloadsDirectory()
        .then((value) => Directory('/storage/emulated/0/Download'));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ytVideoDownloadOptionSelectorWidget(),
    );
  }

  Widget ytVideoDownloadOptionSelectorWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.select_all),
        const Text('Please select video quality from below'),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.ytManifest.muxed.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Text('${index + 1}'),
                    title: Text(
                        "Resolution : ${widget.ytManifest.muxed[index].videoResolution}"),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Bitrate: ${widget.ytManifest.muxed[index].bitrate}'),
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () async {
                        /*final taskId = await FlutterDownloader.enqueue(
                          url:
                              '${ref.read(youtubeExposeProvider).videos.streamsClient.get(widget.ytManifest.muxed[index])}',
                          headers: {}, // optional: header send with url (auth token etc)
                          fileName: 'help1.dart',
                          savedDir: '${_downloadsDirectory!.path}',
                          showNotification:
                              true, // show download progress in status bar (for Android)
                          openFileFromNotification:
                              true, // click on notification to open downloaded file (for Android)
                        );*/

                        /* await saveVideo(
                          widget.ytManifest.muxed[index],
                          widget.video,
                          widget.ytManifest,
                        );*/

                        Navigator.pop(context);
                        await showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            builder: (context) => DownloadProgressWidget(
                                  ytManifest: widget.ytManifest,
                                  video: widget.video,
                                  selectedMux: widget.ytManifest.muxed[index],
                                ));
                      },
                      icon: const Icon(Icons.download),
                      label: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Download'),
                          Text('${widget.ytManifest.video[index].size}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> saveVideo(
    MuxedStreamInfo selectedMux,
    Video video,
    StreamManifest ytManifest,
  ) async {
    log('Starting to save video......');

    final yt = ref.read(youtubeExposeProvider);

    var stream = yt.videos.streamsClient.get(selectedMux);

    // Generate and format File Name
    var audioName = ytManifest.audioOnly.first.container.name;

    final fileName = '${video.title}.$audioName'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');

    // Progress variables

    double totalBytes = selectedMux.size.totalMegaBytes;

    double currentProgress = 0.0;

    // Create the message and set the cursor position.
    final msg = 'Downloading ${video.title}.$audioName';
    stdout.writeln(msg);

    // Create a file for writing.
    var file = File('${_downloadsDirectory!.path}/$fileName');

    // Delete the file if exists.
    if (file.existsSync()) {
      file.deleteSync();
    }

    // Open the file in writeAppend.
    final output = file.openWrite(mode: FileMode.writeOnlyAppend);

    await for (final data in stream) {
      // Keep track of the current downloaded data.
      currentProgress += data.length;

      // Calculate the current progress.
      final progress = ((currentProgress / totalBytes) * 100).ceil();
      log('$progress');

      // Update the progressbar.
      //progressBar.update(progress);

      // Write to file.
      output.add(data);
    }

    await output.close();

    log('Video saving complete......');
  }
}
