import 'dart:io';

import 'package:buff/buff_io.dart';
import 'package:mvimg/mvimg.dart';
import 'package:test/test.dart';

void main() {
  group('Mvimg Performance Tests', () {
    late File testFile;
    late List<int> testData;
    
    setUpAll(() async {
      // 注意：需要准备一个测试用的运动照片文件
      testFile = File('assets/test.jpg');
      testData = await testFile.readAsBytes();
    });

    test('解码性能测试', () {
      final stopwatch = Stopwatch()..start();
      
      for (var i = 0; i < 100; i++) {
        final mvimg = Mvimg(BufferInput.memory(testData));
        mvimg.decode();
        mvimg.dispose();
      }
      
      stopwatch.stop();
      print('100次解码操作耗时: ${stopwatch.elapsedMilliseconds}ms');
      print('平均每次解码耗时: ${stopwatch.elapsedMilliseconds / 100}ms');
      
      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
          reason: '100次解码操作应在5秒内完成');
    });

    test('提取图片和视频性能测试', () {
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
      print('50次提取图片和视频耗时: ${stopwatch.elapsedMilliseconds}ms');
      print('平均每次提取耗时: ${stopwatch.elapsedMilliseconds / 50}ms');
      
      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
          reason: '50次提取操作应在3秒内完成');
      
      mvimg.dispose();
    });

    test('XAP 元数据读取性能测试', () {
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
      print('100次读取 XAP 元数据耗时: ${stopwatch.elapsedMilliseconds}ms');
      print('平均每次读取耗时: ${stopwatch.elapsedMilliseconds / 100}ms');
      
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
          reason: '100次 XAP 读取操作应在1秒内完成');
      
      mvimg.dispose();
    });

    test('全流程性能测试', () async {
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
        

        mvimg.dispose();
      }

      stopwatch.stop();
      print('100次全流程操作耗时: ${stopwatch.elapsedMilliseconds}ms');
      print('平均每次操作耗时: ${stopwatch.elapsedMilliseconds / 100}ms');
    });
  });
} 