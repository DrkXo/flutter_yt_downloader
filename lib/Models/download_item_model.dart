


enum DownloadTaskStatus {
  /// Status of the task is either unknown or corrupted.
  undefined,

  /// The task is scheduled, but is not running yet.
  enqueued,

  /// The task is in progress.
  running,

  /// The task has completed successfully.
  complete,

  /// The task has failed.
  failed,

  /// The task was canceled and cannot be resumed.
  canceled,

  /// The task was paused and can be resumed
  paused;

  /// Creates a new [DownloadTaskStatus] from an [int].
  factory DownloadTaskStatus.fromInt(int value) {
    switch (value) {
      case 0:
        return DownloadTaskStatus.undefined;
      case 1:
        return DownloadTaskStatus.enqueued;
      case 2:
        return DownloadTaskStatus.running;
      case 3:
        return DownloadTaskStatus.complete;
      case 4:
        return DownloadTaskStatus.failed;
      case 5:
        return DownloadTaskStatus.canceled;
      case 6:
        return DownloadTaskStatus.paused;
      default:
        throw ArgumentError('Invalid value: $value');
    }
  }
}

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
