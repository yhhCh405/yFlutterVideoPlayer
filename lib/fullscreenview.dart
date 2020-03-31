import 'package:demo_video_player/Modal.dart';
import 'package:demo_video_player/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullscreenView extends StatefulWidget {
  CurrentPlayingInfo playingInfo;
  FullscreenView(this.playingInfo);
  @override
  _FullscreenViewState createState() => _FullscreenViewState();
}

class _FullscreenViewState extends State<FullscreenView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown,DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    //With RotatedBox WORKED BUT NOT DESIRED

    // return Scaffold(
    //     body: Container(
    //   color: Colors.black,
    //   child: RotatedBox(
    //         child: Player(isFullscreen: true,),
    //         quarterTurns: 15,
    //       ),
    // ));

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Player(
          playingInfo: widget.playingInfo,
        ),
      ),
    );
  }
}
