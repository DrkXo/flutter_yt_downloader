import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../DownloadUtilsPages/YT_download_options_page.dart';
import 'my_home_page.dart';
import 'package:flutter/material.dart';

mixin MyHomePageMixin on State<MyHomePage>{

  Future<void> showDownloadPage(({StreamManifest streamManifest, Video videoData}) data)async{
    await showModalBottomSheet(
        context: context,
        builder: (context) => YTDownloadOptionsPage(
          ytManifest: data.streamManifest,
          video: data.videoData,
        ));
  }

}