import 'dart:io';

import 'package:buff/buff.dart';

import 'src/mvimg_base.dart';

/// A class that extends [Mvimg] and adds methods to write the image, video, and xap to files.
class MvimgIO extends Mvimg {
  /// A constructor that takes a [BufferInput] and initializes the [Mvimg] instance.
  MvimgIO(BufferInput input) : super(input);

  /// Writes the image bytes to a file at the given path.
  /// Returns a [File] object representing the written file.
  /// Throws an [IOException] if the file cannot be written.
  ///
  /// You need check [isMvimg] before calling this method.
  File writeImageToFile(String path) {
    final file = File(path);
    file.writeAsBytesSync(getImageBytes());
    return file;
  }

  /// Writes the video bytes to a file at the given path.
  /// Returns a [File] object representing the written file.
  /// Throws an [IOException] if the file cannot be written.
  ///
  /// You need check [isMvimg] before calling this method.
  File writeVideoToFile(String path) {
    final file = File(path);
    file.writeAsBytesSync(getVideoBytes());
    return file;
  }

  /// Writes the xap bytes to a file at the given path.
  /// Returns a [File] object representing the written file.
  /// Throws an [IOException] if the file cannot be written.
  ///
  /// You need check [isMvimg] before calling this method.
  File writeXapToFile(String path) {
    final file = File(path);
    file.writeAsBytesSync(getXapBytes());
    return file;
  }
}
