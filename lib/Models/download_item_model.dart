import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadingTaskModel {
  /// Creates a new [DownloadingTaskModel].

  /// Unique identifier of this task.
  final String taskId;

  /// Status of this task.
  final DownloadTaskStatus status;

  /// Progress between 0 (inclusive) and 100 (inclusive).
  final int progress;

  /// URL from which the file is downloaded.
  final String url;

  /// Local file name of the downloaded file.
  final String? filename;

  /// Absolute path to the directory where the downloaded file will saved.
  final String savedDir;

  /// Timestamp when the task was created.
  final int timeCreated;

  /// Whether downloads can use cellular data
  final bool allowCellular;




//<editor-fold desc="Data Methods">
  const DownloadingTaskModel({
    required this.taskId,
    required this.status,
    required this.progress,
    required this.url,
    this.filename,
    required this.savedDir,
    required this.timeCreated,
    required this.allowCellular,
  });

  DownloadingTaskModel copyWith({
    String? taskId,
    DownloadTaskStatus? status,
    int? progress,
    String? url,
    String? filename,
    String? savedDir,
    int? timeCreated,
    bool? allowCellular,
  }) {
    return DownloadingTaskModel(
      taskId: taskId ?? this.taskId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      url: url ?? this.url,
      filename: filename ?? this.filename,
      savedDir: savedDir ?? this.savedDir,
      timeCreated: timeCreated ?? this.timeCreated,
      allowCellular: allowCellular ?? this.allowCellular,
    );
  }

/*  Map<String, dynamic> toMap() {
    return {
      'taskId': this.taskId,
      'status': this.status,
      'progress': this.progress,
      'url': this.url,
      'filename': this.filename,
      'savedDir': this.savedDir,
      'timeCreated': this.timeCreated,
      'allowCellular': this.allowCellular,
    };
  }*/

  /* factory DownloadingTaskModel.fromMap(Map<String, dynamic> map) {
    return DownloadingTaskModel(
      taskId: map['taskId'] as String,
      status: map['status'] as DownloadTaskStatus,
      progress: map['progress'] as int,
      url: map['url'] as String,
      filename: map['filename'] as String,
      savedDir: map['savedDir'] as String,
      timeCreated: map['timeCreated'] as int,
      allowCellular: map['allowCellular'] as bool,
    );
  }*/

//</editor-fold>
}
