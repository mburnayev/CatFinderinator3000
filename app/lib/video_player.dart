// --- Dart/Flutter libraries ---
import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// --- Miscellaneous Libraries
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Video extends StatelessWidget {
  final String name;

  const Video({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: VideoPlayerScreen(videoName: name));
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoName;

  const VideoPlayerScreen({super.key, required this.videoName});

  @override
  State<VideoPlayerScreen> createState() => _VideoState();
}

class _VideoState extends State<VideoPlayerScreen> {
  final storageRef = FirebaseStorage.instance.ref().child("videos");
  final videoCacheManager = DefaultCacheManager();

  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  late Chewie playerWidget;

// Initialize video controllers while asynchronously fetching video
  Future<void> init() async {
    final videoRef = storageRef.child(widget.videoName);
    final videoURL = await videoRef.getDownloadURL();
    FileInfo? videoInfo = await videoCacheManager.getFileFromCache(videoURL);

    // If we haven't accessed this widget earlier, get the video from network and cache it
    if (videoInfo == null) {
      final videoBytes = await videoRef.getData(10000000);
      await videoCacheManager.putFile(videoURL, videoBytes!);
    }

    // Second time is the charm (the video should definitely exist in cache now)
    videoInfo = await videoCacheManager.getFileFromCache(videoURL);
    if (videoInfo != null) {
      io.File videoFile = videoInfo.file;
      // Videos on Web DO get cached, it's just that the video_player package doesn't
      // support playing files on the Web, here's my Wall of Sadness after learning this:
      //
      // https://stackoverflow.com/questions/72747357/how-to-load-and-show-a-video-file-flutter-web
      // https://pub.dev/packages/video_player_web#dartio
      // https://stackoverflow.com/questions/54861467/unsupported-operation-namespace-while-using-dart-io-on-web
      //
      // Methods evaluated or tried to achieve caching:
      // Using video_player's file() -> UnimplementedError
      // Using path_finder's getTemporaryDirectory() -> MissingPluginException
      // Caching using IndexedDB -> necessitates completely different app structure
      // Using the browser's localStorage -> not large enough, only permits 5 MB

      // Methods tried to achieve storage within the scope of the app:
      // Using http package -> Unsupported operation: _Namespace
      // Using html/universal_html package -> Unsupported operation: _Namespace
      // Using Dio package -> Unsupported operation: _Namespace
      if (kIsWeb) {
        videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(videoURL), httpHeaders: {
          "Cache-Control": "max-age=7200",
        });
      } else {
        // Playing the file from cache works on Android though :)
        videoPlayerController = VideoPlayerController.file(videoFile);
      }
      chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          aspectRatio: 1.33,
          autoPlay: true,
          looping: false);
      playerWidget = Chewie(controller: chewieController);
    }
  }

  // Customized AppBar
  PreferredSizeWidget get topBar {
    var videoNameStart = (widget.videoName).indexOf("Video");
    var videoNameEnd = (widget.videoName).indexOf(".mp4");
    return AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        title: Center(
            child:
                Text((widget.videoName).substring(videoNameStart + 6, videoNameEnd), style: TextStyle(color: Colors.white))));
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: topBar,
        body: FutureBuilder(
            future: init(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                return playerWidget;
              }
            }));
  }
}
