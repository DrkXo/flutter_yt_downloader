// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_yt_downloader/Routes/downloads.dart';
import 'package:flutter_yt_downloader/Routes/yt_web_view.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage>
    with TickerProviderStateMixin {
  late TabController controller;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  snap: false,
                  pinned: true,
                  floating: true, //this make the work done.
                  title: const Text(
                    'Wanderer',
                  ),
                  actions: const [
                    IconButton(
                      onPressed: null,
                      icon: Icon(
                        Icons.more_vert,
                      ),
                    ),
                  ],
                  bottom: TabBar(
                    controller: controller,
                    tabs: [
                      Tab(
                        text: 'Browse',
                      ),
                      Tab(
                        text: 'Downloads',
                      ),
                    ],
                  ),
                ),
              ],
          body: TabBarView(
            controller: controller,
            children: [
              YtWebView(),
              Downloads(),
            ],
          )),
    );
  }
}
