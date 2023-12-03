import 'dart:developer';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final flutterDownloaderTaskSProvider = FutureProvider.autoDispose((ref) async {
  final tasks = await FlutterDownloader.loadTasks();


  log('tasks->>>>>>>>>>  $tasks');

  return tasks;
});

final flutterDownloaderTaskSByQueryProvider =
    FutureProvider.family.autoDispose((ref, String query) async {
  final tasks = await FlutterDownloader.loadTasksWithRawQuery(query: query);
  return tasks;
});

/*CREATE TABLE `task` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`task_id`	VARCHAR ( 256 ),
	`url`	TEXT,
	`status`	INTEGER DEFAULT 0,
	`progress`	INTEGER DEFAULT 0,
	`file_name`	TEXT,
	`saved_dir`	TEXT,
	`resumable`	TINYINT DEFAULT 0,
	`headers`	TEXT,
	`show_notification`	TINYINT DEFAULT 0,
	`open_file_from_notification`	TINYINT DEFAULT 0,
	`time_created`	INTEGER DEFAULT 0
);*/
