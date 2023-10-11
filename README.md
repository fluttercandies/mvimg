# mvimg

A library for handle mvimg.

The file type used in some android device.
It like livephoto in iphone.

The file is composed of two files, jpg and mp4.

Usually, the jpg name is `MVIMG_XXXXX.jpg`.
Or, the name is `xxxx.MP.jpg`.

For information about their differences, please refer [here][issue], or view the [xap file in assets][xap].

## Usage

### Add dependency

```yaml
dependencies:
  mvimg: ^1.0.0
```

### Code

```dart
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

```

## License

Apache License 2.0

[issue]: https://github.com/SimpleMobileTools/Simple-Gallery/issues/1426#issuecomment-982855006
[xap]: https://github.com/CaiJingLong/mvimg/tree/main/assets
