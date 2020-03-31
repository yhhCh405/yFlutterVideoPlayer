import 'package:demo_video_player/player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(
    MaterialApp(
      home: App(),
      routes: {
        App.routeName: (BuildContext context) => App(),
        Player.routeName: (BuildContext context) => Player()
      },
    ),
  );
}

class App extends StatelessWidget {
  static const routeName = '/Main';
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        key: const ValueKey<String>('home_page'),
        appBar: AppBar(
          title: const Text('Testing video player'),
          actions: <Widget>[],
        ),
        body: Player(),
      ),
    );
  }
}
