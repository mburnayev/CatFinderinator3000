import 'package:flutter/material.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  const Video({super.key});

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: singleVideo);
  }

  Widget get singleVideo {
    return const Scaffold();
  }
}