import 'dart:io';

import 'package:buff/buff_io.dart';
import 'package:mvimg/mvimg.dart';
import 'package:mvimg/src/xmp.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('Test for img', () {
    test('Test img', () {
      final mvimg = Mvimg(FileBufferInput.fromPath('assets/test.jpg'));
      mvimg.decode();

      final img = mvimg.getImageBytes();
      final video = mvimg.getVideoBytes();

      mvimg.dispose();
    });
  });
}
