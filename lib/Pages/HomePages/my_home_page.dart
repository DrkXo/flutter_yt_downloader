import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_yt_downloader/Services/utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../Providers/permissions_providers.dart';
import '../../Providers/yotube_link_observer.dart';
import '../../Providers/youtube_expose_provider.dart';
import '../../Services/flutter_local_notification_service.dart';
import '../DownloadManagerPages/download_manager.dart';
import '../DownloadUtilsPages/YT_download_options_page.dart';
import 'my_home_page_mixins.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> with MyHomePageMixin {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  late InAppWebViewGroupOptions options;

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    initializeAddFilters();

    options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        contentBlockers: contentBlockers,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ),
    );

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(permissionsProvider, (previous, next) {});

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        log('didPop -> $didPop ');

        await onPressedBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter YT"),
        ),
        body: Column(
          children: <Widget>[
            /*TextField(
              enabled: false,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
              controller: urlController,
              keyboardType: TextInputType.url,
              onSubmitted: (value) {
                var url = Uri.parse(value);
                if (url.scheme.isEmpty) {
                  url = Uri.parse("https://www.google.com/search?q=$value");
                }
                webViewController?.loadUrl(urlRequest: URLRequest(url: url));
              },
            ),*/

            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(
                      url: Uri.parse("https://m.youtube.com"),
                    ),
                    initialOptions: options,
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    androidOnPermissionRequest:
                        (controller, origin, resources) async {
                      return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT,
                      );
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      var uri = navigationAction.request.url!;

                      if (![
                        "http",
                        "https",
                        "file",
                        "chrome",
                        "data",
                        "javascript",
                        "about"
                      ].contains(uri.scheme)) {
                        /*if (await canLaunch(url)) {
                            // Launch the App
                            await launch(
                              url,
                            );
                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }*/
                      }

                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStop: (controller, url) async {
                      pullToRefreshController.endRefreshing();
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onLoadError: (controller, url, code, message) {
                      pullToRefreshController.endRefreshing();
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController.endRefreshing();
                      }
                      setState(() {
                        this.progress = progress / 100;
                        urlController.text = this.url;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      print(consoleMessage);
                    },
                  ),
                  progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: ref.watch(youtubeLinkObserverProvider(url)).when(
          data: (url) {
            if (url != null) {
              return ref.watch(youtubeExposeVideoStreamDataProvider(url)).when(
                data: (data) {
                  return FloatingActionButton(
                    onPressed: () async {
                      await showDownloadPage(data);
                    },
                    child: const Icon(Icons.download),
                  );
                  ;
                },
                error: (error, s) {
                  return const Center(child: Text('Something went wrong!'));
                },
                loading: () {
                  return const CircularProgressIndicator();
                },
              );
            } else {
              return null;
            }
          },
          error: (error, s) {
            return null;
          },
          loading: () {
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Future<void> onPressedBack() async {
    if (webViewController != null) {
      await webViewController!.canGoBack().then((value) async {
        if (value == true) {
          webViewController!.goBack();
        } else {
          await showExitConfirmation().then((wantToQuit) {
            if (wantToQuit == true) {
              exit(0);
            } else {}
          });
        }
      });
    } else {}
  }
}
