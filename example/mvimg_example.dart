import 'dart:io';

import 'package:buff/buff_io.dart';
import 'package:mvimg/mvimg.dart';

void main() {
  final mvimg = Mvimg(FileBufferInput.fromPath('assets/test.jpg'));
  mvimg.decode();
  try {
    if (!mvimg.isMvimg()) {
      print('not mvimg');
      return;
    }

    final img = mvimg.getImageBytes();
    final video = mvimg.getVideoBytes();

    final videoOutputPath = 'assets/split/output.mp4';
    final imgOutputPath = 'assets/split/output.jpg';

    final videoFile = File(videoOutputPath);
    final imgFile = File(imgOutputPath);

    videoFile.createSync(recursive: true);
    imgFile.createSync(recursive: true);

    videoFile.writeAsBytesSync(video);
    imgFile.writeAsBytesSync(img);
  } finally {
    mvimg.dispose();
  }
}
