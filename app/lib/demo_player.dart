// --- Dart/Flutter libraries ---
import 'package:flutter/material.dart';

// --- Miscellaneous Libraries
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class DemoVideo extends StatelessWidget {
  final String name;

  const DemoVideo({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: DemoVideoPlayerScreen(videoName: name));
  }
}

class DemoVideoPlayerScreen extends StatefulWidget {
  final String videoName;

  const DemoVideoPlayerScreen({super.key, required this.videoName});

  @override
  State<DemoVideoPlayerScreen> createState() => _DemoVideoState();
}

class _DemoVideoState extends State<DemoVideoPlayerScreen> {
  late var videoName = "/demo_videos/${widget.videoName}";

  late VideoPlayerController videoPlayerController = VideoPlayerController.asset(videoName);
  late ChewieController chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 1.33,
      autoPlay: true,
      looping: false);
  late Chewie playerWidget = Chewie(controller: chewieController);

  // Customized AppBar
  PreferredSizeWidget get topBar {
    return AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        title: Center(
            child:
                Text(widget.videoName, style: TextStyle(color: Colors.white))));
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: topBar, body: playerWidget);
  }
}
