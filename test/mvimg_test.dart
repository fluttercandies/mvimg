import 'package:buff/buff_io.dart';
import 'package:mvimg/mvimg.dart';
import 'package:test/test.dart';

void main() {
  group('Test for img', () {
    final pathList = [
      'assets/test.jpg',
      'assets/test.MP.jpg',
    ];
    for (final path in pathList) {
      test('Test img $path', () {
        final mvimg = Mvimg(FileBufferInput.fromPath(path));
        mvimg.decode();

        expect(mvimg.isMvimg(), equals(true));

        final img = mvimg.getImageBytes();
        final video = mvimg.getVideoBytes();

        expect(img.length, isNonZero);
        expect(video.length, isNonZero);

        print('img: ${img.length}, video: ${video.length}');

        mvimg.dispose();
      });
    }
  });
}
