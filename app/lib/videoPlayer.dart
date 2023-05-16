import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cat_finderinator_threethousand/home.dart';

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