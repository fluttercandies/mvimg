/// The mime types utils for motion photo
class MvimgMimeTypes {
  static const String _jpeg = 'image/jpeg';
  static const String _heic = 'image/heic';
  static const String _avif = 'image/avif';
  static const String _mp4 = 'video/mp4';
  static const String _quicktime = 'video/quicktime';

  /// All type for motion photo
  static const Set<String> all = {
    _jpeg,
    _heic,
    _avif,
    _mp4,
    _quicktime,
  };

  /// Check if the mime type is supported
  static bool isSupported(String mime) => all.contains(mime);

  /// Check if the video mime type is supported
  static bool isVideoSupported(String mime) => [
        _mp4,
        _quicktime,
      ].contains(mime);

  /// Get the mime type by enum
  static String mimeTypeToString(MvimgMimeType type) {
    switch (type) {
      case MvimgMimeType.jpeg:
        return _jpeg;
      case MvimgMimeType.heic:
        return _heic;
      case MvimgMimeType.avif:
        return _avif;
      case MvimgMimeType.mp4:
        return _mp4;
      case MvimgMimeType.quicktime:
        return _quicktime;
      default:
        throw Exception('Unknown mime type');
    }
  }

  /// Get the enum by mime type
  static MvimgMimeType stringToMimeType(String mime) {
    switch (mime) {
      case _jpeg:
        return MvimgMimeType.jpeg;
      case _heic:
        return MvimgMimeType.heic;
      case _avif:
        return MvimgMimeType.avif;
      case _mp4:
        return MvimgMimeType.mp4;
      case _quicktime:
        return MvimgMimeType.quicktime;
      default:
        throw Exception('Unknown mime type');
    }
  }
}

/// The mime type of motion photo
enum MvimgMimeType {
  /// The mime type of jpeg image
  jpeg,

  /// The mime type of heic image
  heic,

  /// The mime type of avif image
  avif,

  /// The mime type of mp4 video
  mp4,

  /// The mime type of quicktime video
  quicktime,
}

/// Extension for [MvimgMimeType]
extension MvimgMimeTypeExtension on MvimgMimeType {
  /// Get the mime type by enum
  String get mimeType => MvimgMimeTypes.mimeTypeToString(this);
}
