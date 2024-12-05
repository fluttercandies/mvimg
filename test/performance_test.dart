import 'dart:convert';
import 'dart:io';

import 'package:buff/buff_io.dart';
import 'package:mvimg/mvimg.dart';
import 'package:test/test.dart';

void main() {
  group('Performance Tests (Mvimg 性能测试)', () {
    late File testFile;
    late List<int> testData;

    setUpAll(() async {
      // Note: Prepare a test motion photo file (需要准备一个测试用的运动照片文件)
      testFile = File('assets/test.jpg');
      testData = await testFile.readAsBytes();
    });

    test('Decoding Performance Test (解码性能测试)', () {
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 100; i++) {
        final mvimg = Mvimg(BufferInput.memory(testData));
        mvimg.decode();
        mvimg.dispose();
      }

      stopwatch.stop();
      print('Time for 100 decoding operations (100次解码操作耗时): ${stopwatch.elapsedMilliseconds}ms');
      print('Average time per decode (平均每次解码耗时): ${stopwatch.elapsedMilliseconds / 100}ms');

      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
          reason: '100 decoding operations should complete within 5 seconds (100次解码操作应在5秒内完成)');
    });

    test('Image and Video Extraction Performance Test (提取图片和视频性能测试)', () {
      final mvimg = Mvimg(BufferInput.memory(testData));
      mvimg.decode();

      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 50; i++) {
        if (mvimg.isMvimg()) {
          final imageBytes = mvimg.getImageBytes();
          final videoBytes = mvimg.getVideoBytes();

          expect(imageBytes.length, greaterThan(0));
          expect(videoBytes.length, greaterThan(0));
        }
      }

      stopwatch.stop();
      print('Time for 50 extraction operations (50次提取图片和视频耗时): ${stopwatch.elapsedMilliseconds}ms');
      print('Average time per extraction (平均每次提取耗时): ${stopwatch.elapsedMilliseconds / 50}ms');

      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
          reason: '50 extraction operations should complete within 3 seconds (50次提取操作应在3秒内完成)');

      mvimg.dispose();
    });

    test('XAP Metadata Reading Performance Test (XAP 元数据读取性能测试)', () {
      final mvimg = Mvimg(BufferInput.memory(testData));
      mvimg.decode();

      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 100; i++) {
        if (mvimg.isMvimg()) {
          final xapBytes = mvimg.getXapBytes();
          expect(xapBytes.length, greaterThan(0));
        }
      }

      stopwatch.stop();
      print('Time for 100 XAP metadata reads (100次读取 XAP 元数据耗时): ${stopwatch.elapsedMilliseconds}ms');
      print('Average time per read (平均每次读取耗时): ${stopwatch.elapsedMilliseconds / 100}ms');

      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
          reason: '100 XAP reading operations should complete within 1 second (100次 XAP 读取操作应在1秒内完成)');

      mvimg.dispose();
    });

    final testOutputFileList = <File>[];

    test('End-to-End Performance Test (全流程性能测试)', () async {
      final stopwatch = Stopwatch()..start();

      final file = File('assets/test.jpg');

      for (var i = 0; i < 100; i++) {
        final mvimg = Mvimg(FileBufferInput(file));
        mvimg.decode();
        final imageBytes = mvimg.getImageBytes();
        final videoBytes = mvimg.getVideoBytes();
        final xapBytes = mvimg.getXapBytes();

        expect(imageBytes.length, greaterThan(0));
        expect(videoBytes.length, greaterThan(0));
        expect(xapBytes.length, greaterThan(0));

        final tempDir = Directory.systemTemp;
        final outputFile = File('${tempDir.path}/test_output_image_$i.jpg');
        final outputVideoFile =
            File('${tempDir.path}/test_output_video_$i.mp4');
        final outputXapFile = File('${tempDir.path}/test_output_xap_$i.json');
        testOutputFileList.add(outputFile);
        testOutputFileList.add(outputVideoFile);
        testOutputFileList.add(outputXapFile);
        outputFile.writeAsBytesSync(imageBytes);
        outputVideoFile.writeAsBytesSync(videoBytes);
        outputXapFile.writeAsStringSync(utf8.decode(xapBytes));

        mvimg.dispose();
      }

      stopwatch.stop();
      print('Time for 100 end-to-end operations (100次全流程操作耗时): ${stopwatch.elapsedMilliseconds}ms');
      print('Average time per operation (平均每次操作耗时): ${stopwatch.elapsedMilliseconds / 100}ms');

      for (final file in testOutputFileList) {
        file.deleteSync();
      }
    });
  });
}
