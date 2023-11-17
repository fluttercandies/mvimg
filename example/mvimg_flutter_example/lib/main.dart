import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvimg/mvimg.dart';
import 'package:buff/buff.dart';
import 'package:mvimg_example/const/resource.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PreviewMvimgPage(),
    );
  }
}

class PreviewMvimgPage extends StatefulWidget {
  const PreviewMvimgPage({super.key});

  @override
  State<PreviewMvimgPage> createState() => _PreviewMvimgPageState();
}

class _PreviewMvimgPageState extends State<PreviewMvimgPage> {
  late VideoPlayerController controller;

  Uint8List? _imageBytes;
  Uint8List? _videoBytes;

  bool playing = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    final data = await rootBundle.load(R.ASSETS_TEST_JPG);
    final list = data.buffer.asUint8List();
    final mvImage = Mvimg(BufferInput.memory(list));
    mvImage.decode();

    if (!mvImage.isMvimg()) {
      return;
    }

    final imageBytes = mvImage.getImageBytes();
    final videoBytes = mvImage.getVideoBytes();

    print('videoBytes length: ${videoBytes.length}');

    _imageBytes = Uint8List.fromList(imageBytes);
    _videoBytes = Uint8List.fromList(videoBytes);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('preview mvimg'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return VideoAutoPreviewWidget(
      videoBytes: _videoBytes!,
      previewBytes: _imageBytes!,
    );
  }
}

class VideoAutoPreviewWidget extends StatefulWidget {
  const VideoAutoPreviewWidget({
    super.key,
    required this.videoBytes,
    required this.previewBytes,
  });

  final Uint8List videoBytes;
  final Uint8List previewBytes;

  @override
  State<VideoAutoPreviewWidget> createState() => _VideoAutoPreviewWidgetState();
}

class _VideoAutoPreviewWidgetState extends State<VideoAutoPreviewWidget> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  Future<void> initVideo() async {
    final cachePath = await getApplicationCacheDirectory();
    final file = File('${cachePath.path}/test.mp4');
    await file.writeAsBytes(widget.videoBytes);
    final controller = VideoPlayerController.file(file);
    this.controller = controller;
    await controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return buildVideoWidget(controller);
  }

  Widget buildVideoWidget(VideoPlayerController? controller) {
    if (controller == null) {
      return Image.memory(widget.previewBytes);
    }
    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      },
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, w) {
          return Stack(
            children: [
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              Visibility(
                visible: !controller.value.isPlaying,
                child: Image.memory(widget.previewBytes),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
