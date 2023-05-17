import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:cat_finderinator_threethousand/home.dart';

class Video extends StatelessWidget {
  final String name;
  const Video({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //     title: "Video $name",
    //     home: VideoPlayerScreen(name: name)
    // );
    return Scaffold(body: VideoPlayerScreen(name: name));
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String name;
  const VideoPlayerScreen({super.key, required this.name});

  @override
  State<VideoPlayerScreen> createState() => _VideoState();
}

class _VideoState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initVPFuture;

  @override
  void initState(){
    super.initState();
    _controller = VideoPlayerController.network("gs://catfinderinator3000.appspot.com/videos/${widget.name}");
    _initVPFuture = _controller.initialize();
    _controller.setLooping(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return singleVideo;
  }

  Widget get singleVideo {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: backButtonBox
      ),
      appBar: AppBar(title: Text(widget.name)),
      body: FutureBuilder(
        future: _initVPFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller)
            );
          } else {
            return const Center(
              child: CircularProgressIndicator()
            );
          }
        }
      ),
      floatingActionButton: playPauseButton,
    );
  }

  Widget get backButtonBox {
    return SizedBox(
        height: 80.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [backButton],
        )
    );
  }

  Widget get playPauseButton {
    return FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow
        )
    );
  }

  Widget get backButton {
    return SizedBox(
        height: 50.0,
        width: 175.0,
        child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => Navigator.pop(context), // Navigate back to home page
          label: const Text("Back to videos"),
          icon: const Icon(Icons.arrow_left),
          backgroundColor: Colors.black,
        )
    );
  }

}
