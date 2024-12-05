import 'dart:io';

import 'package:buff/buff_io.dart';
import 'package:mvimg/mvimg.dart';

class ExampleMvImgCallbackAdapter extends MvImgCallbackAdapter {
  @override
  void onDecodeStart(Mvimg mvimg) {
    print('onDecodeStart');
  }

  @override
  void onDecodeEnd(Mvimg mvimg) {
    print('onDecodeEnd');
  }

  @override
  void onError(Mvimg mvimg, dynamic e, StackTrace? stackTrace) {
    print('onError: $e');
    print('stackTrace: $stackTrace');
  }

  @override
  void onDispose(Mvimg mvimg) {
    print('onDispose');
  }
}

void main() {
  final assetList = [
    'assets/test.jpg',
    'assets/test2.jpg',
    'assets/test.MP.jpg',
  ];

  for (final asset in assetList) {
    final fileName = asset.split('/').last;
    final mvimg = Mvimg(FileBufferInput.fromPath(asset));
    mvimg.setCallback(ExampleMvImgCallbackAdapter());
    mvimg.decode();
    try {
      if (!mvimg.isMvimg()) {
        print('not mvimg');
        return;
      }

      final img = mvimg.getImageBytes();
      final video = mvimg.getVideoBytes();

      final imgOffsetStart = 0;
      final imgOffsetEnd = mvimg.videoStartOffset;

      final videoOffsetStart = mvimg.videoStartOffset;
      final videoOffsetEnd = mvimg.videoEndOffset;

      print('imgOffsetStart: $imgOffsetStart');
      print('imgOffsetEnd: $imgOffsetEnd');
      print('videoOffsetStart: $videoOffsetStart');
      print('videoOffsetEnd: $videoOffsetEnd');

      final videoOutputPath = 'assets/split/$fileName/output.mp4';
      final imgOutputPath = 'assets/split/$fileName/output.jpg';
      final xapOutputPath = 'assets/split/$fileName/output.xml';

      final videoFile = File(videoOutputPath);
      final imgFile = File(imgOutputPath);
      final xapFile = File(xapOutputPath);
      videoFile.createSync(recursive: true);
      imgFile.createSync(recursive: true);
      xapFile.createSync(recursive: true);

      videoFile.writeAsBytesSync(video);
      imgFile.writeAsBytesSync(img);
      xapFile.writeAsBytesSync(mvimg.getXapBytes());
    } finally {
      mvimg.dispose();
    }
  }
}
