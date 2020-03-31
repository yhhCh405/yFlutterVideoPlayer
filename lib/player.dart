import 'package:demo_video_player/fullscreenview.dart';
import 'package:demo_video_player/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class Player extends StatefulWidget {
  static const routeName = "/Player";
  BuildContext c;
  bool isFullscreen;
  Player({this.isFullscreen: false, this.c});
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        PlayerVillain(
          isFullscreen: widget.isFullscreen,
          c: widget.c,
        ),
      ],
    ));
  }
}

class PlayerVillain extends StatefulWidget {
  String url;
  BuildContext c;
  bool isFullscreen;
  PlayerVillain({this.c, this.isFullscreen});

  @override
  _PlayerVillainState createState() => _PlayerVillainState();
}

class _PlayerVillainState extends State<PlayerVillain> {
  VideoPlayerController _controller;

  List<String> streamUrls = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
  ];

  List<VideoPlayerController> _vCtrls = [];

  int index = 0;

  playnext() {
    if (index == streamUrls.length - 1) {
      print('No More Videos');
    } else {
      if (_controller != null) {
        index = ++index;
        if (_controller.value.isPlaying) _controller.pause();

        _controller = null;
        _controller = _vCtrls[index];
        setState(() {});

        _controller.addListener(() {
          setState(() {});
        });
        _controller.setLooping(true);
        _controller.initialize();
        setState(() {});
      }
    }
  }

  playPrev() {
    if (index == 0) {
      print('No More Videos');
    } else {
      index = --index;
      if (_controller.value.isPlaying) _controller.pause();

      _controller = null;
      _controller = _vCtrls[index];
      setState(() {});

      _controller.addListener(() {
        setState(() {});
      });
      _controller.setLooping(true);
      _controller.initialize();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    streamUrls.forEach((v) {
      _controller = VideoPlayerController.network(v);
      _vCtrls.add(_controller);
    });

    _controller = _vCtrls[index];
    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  showFullScreen() {
    if (widget.isFullscreen) {
      print(widget.isFullscreen);

      Navigator.pop(widget.c);

      widget.isFullscreen = false;
      setState(() {});
    } else {
      print(widget.isFullscreen);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FullscreenView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          !widget.isFullscreen
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_controller),
                      ClosedCaption(text: _controller.value.caption.text),
                      _PlayPauseOverlay(
                          controller: _controller,
                          isFullscreen: widget.isFullscreen,
                          onNextPressed: () {
                            playnext();
                          },
                          onPrevPressed: () {
                            playPrev();
                          },
                          onFullscreenPressed: () {
                            showFullScreen();
                          }),
                      VideoProgressIndicator(_controller, allowScrubbing: true),
                    ],
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_controller),
                      ClosedCaption(text: _controller.value.caption.text),
                      _PlayPauseOverlay(
                          controller: _controller,
                          isFullscreen: widget.isFullscreen,
                          onNextPressed: () {
                            playnext();
                          },
                          onPrevPressed: () {
                            playPrev();
                          },
                          onFullscreenPressed: () {
                            showFullScreen();
                          }),
                      VideoProgressIndicator(_controller, allowScrubbing: true),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

class _PlayPauseOverlay extends StatefulWidget {
  VoidCallback onPrevPressed;
  VoidCallback onNextPressed;
  VoidCallback onFullscreenPressed;
  bool isFullscreen;
  bool shouldDisplayButtons = true;
  VideoPlayerController controller;
  _PlayPauseOverlay(
      {Key key,
      this.controller,
      this.onPrevPressed,
      this.onNextPressed,
      this.isFullscreen,
      this.onFullscreenPressed})
      : super(key: key);
  @override
  __PlayPauseOverlayState createState() => __PlayPauseOverlayState();
}

class __PlayPauseOverlayState extends State<_PlayPauseOverlay> {
  onTapVideo() {
    print('tap');

    if (widget.shouldDisplayButtons) {
      widget.shouldDisplayButtons = false;
    } else if (widget.shouldDisplayButtons == false) {
      widget.shouldDisplayButtons = true;
      setState(() {
        print(widget.shouldDisplayButtons);
      });
      // Future.delayed(Duration(seconds: 3)).then((v) {
      //   setState(() {
      //     print('hide');
      //     if (widget.shouldDisplayButtons) widget.shouldDisplayButtons = false;
      //   });
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTapVideo();
        print('tap');
      },
      child: Container(
        child: Stack(
          children: <Widget>[
            widget.shouldDisplayButtons
                ? Center(
                    child: Container(
                      alignment: Alignment.center,
                      height: 80,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              color: Colors.black26,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.skip_previous),
                                  iconSize: 80,
                                  color: Colors.white,
                                  onPressed: widget.onPrevPressed,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.black26,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(
                                    widget.controller.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                  ),
                                  iconSize: 80,
                                  color: Colors.white,
                                  onPressed: () {
                                    widget.controller.value.isPlaying
                                        ? widget.controller.pause()
                                        : widget.controller.play();
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.black26,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.skip_next),
                                  iconSize: 80,
                                  color: Colors.white,
                                  onPressed: widget.onNextPressed,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            widget.shouldDisplayButtons
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        color: Colors.black26,
                        child: IconButton(
                          icon: Icon(widget.isFullscreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen),
                          iconSize: 30,
                          color: Colors.white,
                          onPressed: widget.onFullscreenPressed,
                        ),
                      ),
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
