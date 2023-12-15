import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Mixins/my_home_page_mixin.dart';
import '../Riverpod Providers/yotube_link_observer.dart';
import '../Riverpod Providers/youtube_expose_provider.dart';

class YtWebView extends ConsumerStatefulWidget {
  const YtWebView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _YtWebViewState();
}

class _YtWebViewState extends ConsumerState<YtWebView>
    with YtWebViewMixin, AutomaticKeepAliveClientMixin {
  final GlobalKey webViewKey = GlobalKey();
  late ScrollController scrollController;
  InAppWebViewController? webViewController;
  late InAppWebViewGroupOptions options;
  final Set<Factory<OneSequenceGestureRecognizer>> egarGestureRecognizers = {
    Factory(() => EagerGestureRecognizer()),
    Factory(() => VerticalDragGestureRecognizer())
  };

  final Set<Factory<OneSequenceGestureRecognizer>> verticalGestureRecognizers =
      {Factory(() => VerticalDragGestureRecognizer())};

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
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
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        log('didPop -> $didPop ');

        await onPressedBack();
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    key: webViewKey,
                    gestureRecognizers: verticalGestureRecognizers,
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
                        urlController.text = url;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      // log('$consoleMessage');
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
                      log('Found Youtube URL !');
                    },
                    child: const Icon(Icons.download),
                  );
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

  @override
  bool get wantKeepAlive => true;
}
