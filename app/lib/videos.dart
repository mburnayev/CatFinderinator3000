// --- Dart/Flutter libraries ---
import 'package:flutter/material.dart';
import 'dart:ui';

// --- Miscellaneous Libraries
import 'package:firebase_storage/firebase_storage.dart';

// --- Local Package Files ---
import 'package:cat_finderinator_threethousand/video_player.dart';

class Videos extends StatefulWidget {
  final String username;

  const Videos({super.key, required this.username});

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  late var username = widget.username;
  final storageRef = FirebaseStorage.instance.ref().child("videos");

  List<String> yearsList = [];

  // Maps to track selected items and loaded children
  Map<String, List<String>> yearMonths = {};
  Map<String, List<String>> monthDays = {};
  Map<String, List<String>> dayVideos = {};

  // Retrieves year directories from Firebase Cloud Storage bucket
  Future<void> getYears() {
    return storageRef.listAll().then((listResult) {
      for (var item in listResult.prefixes) {
        yearsList.add(item.name);
      }
    });
  }

  // Retrieves month directories for given year from Firebase Cloud Storage bucket
  Future<List<String>> getMonths(String year) async {
    if (yearMonths.containsKey(year)) {
      return yearMonths[year]!;
    }

    List<String> months = [];
    final yearRef = storageRef.child(year);
    final listResult = await yearRef.listAll();

    for (var prefix in listResult.prefixes) {
      months.add(prefix.name);
    }

    yearMonths[year] = months;
    return months;
  }

  // Retrieves day directories for given month from Firebase Cloud Storage bucket
  Future<List<String>> getDays(String year, String month) async {
    final key = '$year/$month';
    if (monthDays.containsKey(key)) {
      return monthDays[key]!;
    }

    List<String> days = [];
    final monthRef = storageRef.child(year).child(month);
    final listResult = await monthRef.listAll();

    for (var prefix in listResult.prefixes) {
      days.add(prefix.name);
    }
    days.sort((a, b) => int.parse(b).compareTo(int.parse(a)));

    monthDays[key] = days;
    return days;
  }

  // Retrieves videos for given day from Firebase Cloud Storage bucket
  Future<List<String>> getVideos(String year, String month, String day) async {
    final key = '$year/$month/$day';
    if (dayVideos.containsKey(key)) {
      return dayVideos[key]!;
    }

    List<String> videos = [];
    final dayRef = storageRef.child(year).child(month).child(day);
    final listResult = await dayRef.listAll();

    for (var item in listResult.items) {
      videos.add(item.name);
    }

    dayVideos[key] = videos;
    return videos;
  }

  Future<void> refreshHelper() async {
    setState(() {
      yearsList = [];
      yearMonths.clear();
      monthDays.clear();
      dayVideos.clear();
    });
  }

  // Customized AppBar
  PreferredSizeWidget get topBar {
    return AppBar(
      backgroundColor: Colors.deepPurple,
      title: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth;
          double fontSize = availableWidth * 0.015;
          fontSize = fontSize.clamp(12.0, 32.0);
          return Center(
              child: Text(
            "Welcome ${widget.username}, here are the available cat videos:",
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
            ),
          ));
        },
      ),
    );
  }

  // Scaffold that is used when no year folders are (but effectively nothing is) present in Cloud Storage
  Widget get noVideosScaffold {
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          physics: const BouncingScrollPhysics(),
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad},
        ),
        child: RefreshIndicator(
            onRefresh: refreshHelper,
            child: Scaffold(
                appBar: topBar,
                body: ListView(children: [
                  Center(
                      heightFactor: 15,
                      child: Text(
                        "No recent cat detections — stay tuned!",
                        style: TextStyle(color: Colors.blue, fontSize: 30),
                        textAlign: TextAlign.center,
                      ))
                ]))));
  }

  // Scaffold for when directories that may contain videos are present
  // Users are redirected to a corresponding video on press
  //
  // File navigator-esque structure accomplished through the use of nested
  // ExpansionTiles with FutureBuilders to pull the Cloud Storage data as the
  // tiles are expanded
  Widget get videoDirectoryScaffold {
    return Scaffold(
        appBar: topBar,
        body: ListView.builder(
            itemCount: yearsList.length,
            itemBuilder: (context, index) {
              final year = yearsList[index];
              return ExpansionTile(title: Text(year), controlAffinity: ListTileControlAffinity.leading, children: [
                FutureBuilder<List<String>>(
                    future: getMonths(year),
                    builder: (context, snapshot) {
                      return Column(
                          children: snapshot.data!.map((month) {
                        return ExpansionTile(
                            tilePadding: const EdgeInsets.only(left: 40.0),
                            title: Text(month),
                            controlAffinity: ListTileControlAffinity.leading,
                            children: [
                              FutureBuilder<List<String>>(
                                  future: getDays(year, month),
                                  builder: (context, snapshot) {
                                    return Column(
                                        children: snapshot.data!.map((day) {
                                      return ExpansionTile(
                                          tilePadding: const EdgeInsets.only(left: 80.0),
                                          title: Text(day),
                                          controlAffinity: ListTileControlAffinity.leading,
                                          children: [
                                            FutureBuilder<List<String>>(
                                                future: getVideos(year, month, day),
                                                builder: (context, snapshot) {
                                                  return Column(
                                                      children: snapshot.data!.map((video) {
                                                    return ListTile(
                                                        contentPadding: const EdgeInsets.only(left: 120.0),
                                                        title: Text(video),
                                                        onTap: () {
                                                          final videoPath = '$year/$month/$day/$video';
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => Video(
                                                                        name: videoPath,
                                                                      )));
                                                        });
                                                  }).toList());
                                                })
                                          ]);
                                    }).toList());
                                  })
                            ]);
                      }).toList());
                    })
              ]);
            }));
  }

  // Buffers then retrieves correct Scaffold depending on number of videos
  Widget get homeApp {
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          physics: const BouncingScrollPhysics(),
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad},
        ),
        child: RefreshIndicator(
            onRefresh: refreshHelper,
            child: FutureBuilder<void>(
              future: getYears(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  Widget finalScaffold = const Scaffold();
                  finalScaffold = (yearsList.isEmpty) ? noVideosScaffold : videoDirectoryScaffold;
                  return finalScaffold;
                }
              },
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: homeApp);
  }
}
