import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../DownloadUtilsPages/YT_download_options_page.dart';
import 'my_home_page.dart';
import 'package:flutter/material.dart';

mixin MyHomePageMixin on State<MyHomePage> {
  // list of ad URL filters to be used to block ads from loading
  final adUrlFilters = [
    ".*.doubleclick.net/.*",
    ".*.ads.pubmatic.com/.*",
    ".*.googlesyndication.com/.*",
    ".*.google-analytics.com/.*",
    ".*.adservice.google.*/.*",
    ".*.adbrite.com/.*",
    ".*.exponential.com/.*",
    ".*.quantserve.com/.*",
    ".*.scorecardresearch.com/.*",
    ".*.zedo.com/.*",
    ".*.adsafeprotected.com/.*",
    ".*.teads.tv/.*",
    ".*.outbrain.com/.*"
  ];
  final List<ContentBlocker> contentBlockers = [];

  void initializeAddFilters() {
    for (final adUrlFilter in adUrlFilters) {
      contentBlockers.add(ContentBlocker(
          trigger: ContentBlockerTrigger(
            urlFilter: adUrlFilter,
          ),
          action: ContentBlockerAction(
            type: ContentBlockerActionType.BLOCK,
          )));
    } // apply the "display: none" style to some HTML elements
    contentBlockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: ".*",
        ),
        action: ContentBlockerAction(
            type: ContentBlockerActionType.CSS_DISPLAY_NONE,
            selector: ".banner, .banners, .ads, .ad, .advert")));
  }

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
