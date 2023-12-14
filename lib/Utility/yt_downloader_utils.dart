extension StringExtension on String {
  String get toTitleCase {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String get cleanUpYoutubeVideoTitle {
    return replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');
  }
}

class YoutubeUtils {
  final youtubeLinkDetectorRegex = RegExp(
    r".*\?v=(.+?)($|[\&])",
    caseSensitive: false,
  );

  String? getYoutubeVideoIdByURL(String url) {
    if (url.contains('https://www.youtube.com/') ||
        url.contains('https://m.youtube.com')) {
      try {
        if (youtubeLinkDetectorRegex.hasMatch(url)) {
          return youtubeLinkDetectorRegex.firstMatch(url)!.group(1);
        }
      } catch (e) {
        return null;
      }
      return null;
    } else {
      return null;
    }
  }
}
