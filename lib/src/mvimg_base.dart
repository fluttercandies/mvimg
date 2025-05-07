import 'dart:convert';

import 'package:buff/buff.dart';
import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

import 'mime_type.dart';

class _Range {
  final int start;
  final int end;

  _Range(this.start, this.end);
}

/// A mixin for callback methods of [Mvimg].
///
/// See also:
/// [MvImgCallbackAdapter]
mixin MvImgCallback {
  /// The method called when the decoding starts.
  void onDecodeStart(Mvimg mvimg);

  /// The method called when the decoding ends.
  void onDecodeEnd(Mvimg mvimg);

  /// The method called when an error occurs during decoding.
  void onError(Mvimg mvimg, dynamic e, StackTrace? stackTrace);

  /// The method called when the [Mvimg] is disposed.
  void onDispose(Mvimg mvimg);
}

/// A default implementation of [MvImgCallback].
///
/// Every method is empty.
class MvImgCallbackAdapter implements MvImgCallback {
  @override
  void onDecodeStart(Mvimg mvimg) {}

  @override
  void onDecodeEnd(Mvimg mvimg) {}

  @override
  void onError(Mvimg mvimg, dynamic e, StackTrace? stackTrace) {}

  @override
  void onDispose(Mvimg mvimg) {}
}

/// A class for decoding motion photo files,
/// which are composed of a jpeg image and an mp4 video.
///
/// Support like this:
/// - `MVIMG_XXXX.jpg`
/// - `XXXX.MP.jpg`
///
/// About Motion photo for Android:
/// - [Motion photo](https://developer.android.com/media/platform/motion-photo-format)
class Mvimg {
  MvImgCallback? callback;

  /// The input buffer.
  ///
  /// See also:
  /// [BufferInput] of `buff` package.
  final BufferInput input;

  /// Creates a [Mvimg] from a [BufferInput].
  Mvimg(this.input);

  bool _isMvImg = false;

  _Range? _videoRange;

  /// The range of the xap in the file.
  ///
  /// The xap is a xml file that contains the metadata of the motion photo file.
  _Range? _xapRange;

  /// The mime type of the video.
  String? _videoMimeType;

  /// The mime type of the video.
  MvimgMimeType? get videoMimeType {
    if (_videoMimeType == null) {
      return null;
    }
    return MvimgMimeTypes.stringToMimeType(_videoMimeType!);
  }

  void setCallback(MvImgCallback callback) {
    this.callback = callback;
  }

  void removeCallback() {
    callback = null;
  }

  /// Decodes the mvimg file.
  ///
  /// Just call this method after, the [isMvimg], [getImageBytes] or [getVideoBytes] is valid.
  void decode() {
    try {
      callback?.onDecodeStart(this);
      _readContent();
      callback?.onDecodeEnd(this);
    } catch (e, stackTrace) {
      callback?.onError(this, e, stackTrace);
    }
  }

  void _readContent() {
    var offset = 0;

    final header = input.getBytes(0, 2);

    offset += 2;

    if (header[0] != 0xFF || header[1] != 0xD8) {
      final e = Exception('Not a jpeg file');
      callback?.onError(this, e, null);
      throw e;
    }

    // load app1 type, for get xmp
    while (true) {
      final marker = input.getBytes(offset, offset + 2);
      if (marker[0] != 0xFF) {
        final e = Exception(
            'Can not find exif, offset: $offset, marker: ${marker[0]}');
        callback?.onError(this, e, null);
        throw e;
      }
      offset += 2;

      final typeBytes = marker[1];
      final isApp1Type = typeBytes == 0xE1;

      final length = input.getBytes(offset, offset + 2);
      final lengthInt = (length[0] << 8) + length[1];

      offset += 2;

      final type = input.getBytes(offset, offset + 29);
      final xap = ascii.encode('http://ns.adobe.com/xap/1.0/') + [0];

      if (isApp1Type && ListEquality().equals(type, xap)) {
        // find the xmp

        int contentOffset = offset + 29;
        final contentLength = lengthInt - 2 - 29;
        int end = contentOffset + contentLength;

        final content = input.getBytes(contentOffset, end);

        _xapRange = _Range(contentOffset, end);

        _isMvImg = true;

        _readVideoRange(content);

        break;
      } else {
        offset += lengthInt - 2;
      }
    }
  }

  void _readVideoRange(List<int> xapContent) {
    try {
      final fileLength = input.length;

      final text = ascii.decode(xapContent);
      final document = XmlDocument.parse(text);
      final root = document.rootElement;
      final infoElement = root.firstElementChild?.firstElementChild;
      final videoOffset = infoElement?.getAttribute('GCamera:MicroVideoOffset');

      if (videoOffset != null) {
        final videoOffsetInt = int.parse(videoOffset);

        _videoRange = _Range(fileLength - videoOffsetInt, fileLength);
        return;
      }

      final isMotionPhoto =
          infoElement?.getAttribute('GCamera:MotionPhoto') == '1';

      if (isMotionPhoto) {
        final children =
            infoElement?.firstElementChild?.firstElementChild?.childElements;

        if (children != null) {
          for (final item in children) {
            final container = item.firstElementChild;
            final mimeType = container?.getAttribute('Item:Mime');

            if (mimeType == null) {
              continue;
            }

            if (MvimgMimeTypes.isVideoSupported(mimeType)) {
              final length = container?.getAttribute('Item:Length');

              if (length == null) {
                throw Exception('Can not find video length');
              }

              final videoOffsetInt = int.parse(length);
              _videoRange = _Range(fileLength - videoOffsetInt, fileLength);
              _videoMimeType = mimeType;
              return;
            }
          }
        }
      }
    } catch (e, stackTrace) {
      final e = Exception('Can not find video range');
      callback?.onError(this, e, stackTrace);
      throw e;
    }
  }

  /// Closes the input buffer.
  ///
  /// Must call this method after use.
  void dispose() {
    callback?.onDispose(this);
    input.close();
  }

  /// Returns true if the file is a mvimg or motion photo file.
  bool isMvimg() {
    return _isMvImg;
  }

  /// Returns the offset of the start of the video in the file.
  int get videoStartOffset => _videoRange?.start ?? 0;

  /// Returns the offset of the end of the video in the file.
  int get videoEndOffset => _videoRange?.end ?? input.length;

  /// Returns the offset of the start of the xap in the file.
  int get xapStartOffset => _xapRange?.start ?? 0;

  /// Returns the offset of the end of the xap in the file.
  int get xapEndOffset => _xapRange?.end ?? input.length;

  /// Returns the bytes of the jpeg image in the file.
  List<int> getImageBytes() {
    return input.getBytes(0, videoStartOffset);
  }

  /// Returns the bytes of the mp4 video in the file.
  List<int> getVideoBytes() {
    if (_isMvImg) {
      return input.getBytes(videoStartOffset, videoEndOffset);
    }
    throw Exception('Not a mvimg file');
  }

  /// Returns the bytes of the xap in the file.
  List<int> getXapBytes() {
    return input.getBytes(xapStartOffset, xapEndOffset);
  }
}
