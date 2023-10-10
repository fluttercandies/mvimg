import 'package:buff/buff_io.dart';
import 'package:mvimg/mvimg.dart';
import 'package:test/test.dart';

void main() {
  group('Test for img', () {
    test('Test img', () {
      final mvimg = Mvimg(FileBufferInput.fromPath('assets/test.jpg'));
      mvimg.decode();

      expect(mvimg.isMvimg(), equals(true));

      final img = mvimg.getImageBytes();
      final video = mvimg.getVideoBytes();

      expect(img.length, equals(5336359));
      expect(video.length, equals(3507133));

      mvimg.dispose();
    });
  });
}
