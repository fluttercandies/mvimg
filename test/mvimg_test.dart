import 'package:buff/buff_io.dart';
import 'package:mvimg/mvimg.dart';
import 'package:mvimg/mvimg_io.dart';
import 'package:test/test.dart';

void main() {
  const testDataList = [
    _TestData(
      path: 'assets/test.MP.jpg',
      expectImgLength: 1939586,
      expectVideoLength: 2708598,
    ),
    _TestData(
      path: 'assets/test.jpg',
      expectImgLength: 5336359,
      expectVideoLength: 3507133,
    ),
    _TestData(
      path: 'assets/test2.jpg',
      expectImgLength: 5422184,
      expectVideoLength: 7788607,
    ),
  ];

  group('Test for img', () {
    for (final testData in testDataList) {
      final path = testData.path;
      test('Test img $path', () {
        final mvimg = Mvimg(FileBufferInput.fromPath(path));
        mvimg.decode();

        expect(mvimg.isMvimg(), equals(true));

        final img = mvimg.getImageBytes();
        final video = mvimg.getVideoBytes();

        expect(img.length, equals(testData.expectImgLength));
        expect(video.length, equals(testData.expectVideoLength));

        print('img: ${img.length}, video: ${video.length}');

        mvimg.dispose();
      });
    }
  });

  group('Test for MvimgIO', () {
    for (final testData in testDataList) {
      final path = testData.path;
      test('Test from $path to write image and video to file', () {
        final mvimg = MvimgIO(FileBufferInput.fromPath(path));
        mvimg.decode();

        final imgFile = mvimg.writeImageToFile('test_img.jpg');
        expect(imgFile.existsSync(), isTrue);
        expect(imgFile.lengthSync(), equals(testData.expectImgLength));

        print('image file length: ${imgFile.lengthSync()}');

        final videoFile = mvimg.writeVideoToFile('test_video.mp4');
        expect(videoFile.existsSync(), isTrue);
        expect(videoFile.lengthSync(), equals(testData.expectVideoLength));

        print('video file length: ${videoFile.lengthSync()}');

        mvimg.dispose();

        imgFile.deleteSync();
        videoFile.deleteSync();
      });
    }
  });
}

// assets/split/test.MP.jpg:
// total 9096
// -rw-r--r--  1 cai  staff  1939586 11  7 11:11 output.jpg
// -rw-r--r--  1 cai  staff  2708598 11  7 11:11 output.mp4
// -rw-r--r--  1 cai  staff     1235 11  7 11:11 output.xml
//
// assets/split/test.jpg:
// total 17288
// -rw-r--r--  1 cai  staff  5336359 11  7 11:11 output.jpg
// -rw-r--r--  1 cai  staff  3507133 11  7 11:11 output.mp4
// -rw-r--r--  1 cai  staff      584 11  7 11:11 output.xml
//
// assets/split/test2.jpg:
// total 25816
// -rw-r--r--  1 cai  staff  5422184 11  7 11:11 output.jpg
// -rw-r--r--  1 cai  staff  7788607 11  7 11:11 output.mp4

class _TestData {
  /// The path of the test file.
  final String path;

  /// expect image length
  final int expectImgLength;

  /// expect video length
  final int expectVideoLength;

  const _TestData({
    required this.path,
    required this.expectImgLength,
    required this.expectVideoLength,
  });
}
