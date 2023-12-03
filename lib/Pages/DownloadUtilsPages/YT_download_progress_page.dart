import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_yt_downloader/Services/utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../Providers/youtube_expose_provider.dart';

class DownloadProgressWidget extends ConsumerStatefulWidget {
  const DownloadProgressWidget({
    super.key,
    required this.ytManifest,
    required this.video,
    required this.selectedMux,
  });

  final MuxedStreamInfo selectedMux;
  final Video video;
  final StreamManifest ytManifest;

  @override
  ConsumerState createState() => _DownloadProgressWidgetState();
}

class _DownloadProgressWidgetState
    extends ConsumerState<DownloadProgressWidget> {
  @override
  Widget build(BuildContext context) {
    final ytXposeSingleMuxVideoDownload = ref.watch(
      youtubeExposeVideoMuxDownload(
        (
          ytManifest: widget.ytManifest,
          video: widget.video,
          selectedMux: widget.selectedMux,
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ytXposeSingleMuxVideoDownload.when(
          data: (data) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.horizontal_rule_outlined),
                  Text(
                    'Note : Closing ths window will cause unfinished downloads',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.video_file_outlined),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Status : '),
                        Text(data.status.name.toTitleCase),
                      ],
                    ),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${data.filename}'),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(data.savedDir),
                      ],
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.bounceInOut,
                    tween: Tween<double>(
                      begin: 0,
                      end: (data.progress / 100),
                    ),
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: LinearProgressIndicator(
                                value: value,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                minHeight: 15,
                                backgroundColor: Colors.white,
                                valueColor: const AlwaysStoppedAnimation(
                                    Colors.deepPurple),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text('${data.progress}%'),
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
          error: (error, s) {
            return ListTile(
              title: Text('$error'),
            );
          },
          loading: () {
            return const ListTile(
              title: Text('Please wait...'),
              subtitle: LinearProgressIndicator(),
            );
          },
        ),
      ],
    );
  }
}
