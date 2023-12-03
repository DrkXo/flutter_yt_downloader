import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Providers/flutter_downloader_provider.dart';

class DownloadManager extends ConsumerStatefulWidget {
  const DownloadManager({super.key});

  @override
  ConsumerState createState() => _DownloadManagerState();
}

class _DownloadManagerState extends ConsumerState<DownloadManager> {
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus.undefined;
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(flutterDownloaderTaskSProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Manager'),
      ),
      body: tasks.when(
        data: (data) {
          return data != null
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: Text('${index + 1}.'),
                      title: Text(
                        '${data[index].filename}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${data[index].status} || ${data[index].progress}'),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          FlutterDownloader.remove(taskId: data[index].taskId)
                              .then((value) {
                            ref.invalidate(flutterDownloaderTaskSProvider);
                          });
                          setState(() {});
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    );
                  },
                )
              : const SizedBox.shrink();
        },
        error: (err, s) {
          return Center(
            child: Text(err.toString()),
          );
        },
        loading: () {
          return const LinearProgressIndicator();
        },
      ),
    );
  }
}
