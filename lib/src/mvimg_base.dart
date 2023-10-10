import 'dart:convert';

import 'package:buff/buff.dart';
import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

class _Range {
  final int start;
  final int end;

  _Range(this.start, this.end);
}

/// Just support jpeg + mp4
class Mvimg {
  final BufferInput input;

  Mvimg(this.input);

  bool _isMvImg = false;

  _Range? _videoRange;

  void decode() {
    try {
      _readContent();
    } catch (e) {
      print(e);
    }
  }

  void _readContent() {
    var offset = 0;

    final header = input.getBytes(0, 2);

    offset += 2;

    if (header[0] != 0xFF || header[1] != 0xD8) {
      throw Exception('Not a jpeg file');
    }

    // load app1 type, for get xmp
    while (true) {
      final marker = input.getBytes(offset, offset + 2);
      if (marker[0] != 0xFF) {
        throw Exception(
            'Can not find exif, offset: $offset, marker: ${marker[0]}');
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

        _isMvImg = true;

        _readVideoRange(content);

        break;
      } else {
        offset += lengthInt - 2;
      }
    }
  }

  void _readVideoRange(List<int> xapContent) {
    final text = ascii.decode(xapContent);
    final document = XmlDocument.parse(text);
    final root = document.rootElement;

    final infoElement = root.firstElementChild?.firstElementChild;

    final videoOffset = infoElement?.getAttribute('GCamera:MicroVideoOffset');

    if (videoOffset == null) {
      throw Exception('Can not find video offset');
    }

    final videoOffsetInt = int.parse(videoOffset);

    final fileLength = input.length;

    _videoRange = _Range(fileLength - videoOffsetInt, fileLength);
  }

  void dispose() {
    input.close();
  }

  bool isMvimg() {
    return _isMvImg;
  }

  int get videoStartOffset => _videoRange?.start ?? 0;
  int get videoEndOffset => _videoRange?.end ?? input.length;

  List<int> getImageBytes() {
    return input.getBytes(0, videoStartOffset);
  }

  List<int> getVideoBytes() {
    if (_isMvImg) {
      return input.getBytes(videoStartOffset, videoEndOffset);
    }
    throw Exception('Not a mvimg file');
  }
}
