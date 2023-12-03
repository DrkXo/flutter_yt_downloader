import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../DownloadUtilsPages/YT_download_options_page.dart';
import 'my_home_page.dart';
import 'package:flutter/material.dart';

mixin MyHomePageMixin on State<MyHomePage> {
  Future<void> showDownloadPage(
      ({StreamManifest streamManifest, Video videoData}) data) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => YTDownloadOptionsPage(
              ytManifest: data.streamManifest,
              video: data.videoData,
            ));
  }

  Future<bool> showExitConfirmation() async {
    bool value = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Do you want to exit ?'),
       // content: const Text('Do you want to exit ?'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            //yes button
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    ).then((value) => value ?? false);
    return value;
  }
}
