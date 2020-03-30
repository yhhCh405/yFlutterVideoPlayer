import 'package:demo_video_player/fullscreenview.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Player extends StatefulWidget {
  bool isFullscreen;
  Player({this.isFullscreen: false});
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PlayerVillain(widget.isFullscreen),
    );
  }
}

class PlayerVillain extends StatefulWidget {
  bool isFullscreen;
  PlayerVillain(this.isFullscreen);

  @override
  _PlayerVillainState createState() => _PlayerVillainState();
}

class _PlayerVillainState extends State<PlayerVillain> {
  VideoPlayerController _controller;
  List<String> streamUrls = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
  ];

  int index = 0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(streamUrls.first
        //closedCaptionFile: _loadCaptions(),
        );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  playnext() {
    if (index == streamUrls.length) {
      print('No More Videos');
    } else {
      _controller.dispose();

      _controller = VideoPlayerController.network(streamUrls[index++]
          //closedCaptionFile: _loadCaptions(),
          );

      _controller.addListener(() {
        setState(() {});
      });
      _controller.setLooping(true);
      _controller.initialize();
      setState(() {});
    }
  }

  playPrev() {
    if (index == 0) {
      print('No More Videos');
    } else {
      _controller.dispose();

      _controller = VideoPlayerController.network(streamUrls[index--]
          //closedCaptionFile: _loadCaptions(),
          );

      _controller.addListener(() {
        setState(() {});
      });
      _controller.setLooping(true);
      _controller.initialize();
      setState(() {});
    }
  }

  showFullScreen() {
    if (widget.isFullscreen) {
      Navigator.pop(context);
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FullscreenView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width:
                widget.isFullscreen ? MediaQuery.of(context).size.width : null,
            height:
                widget.isFullscreen ? MediaQuery.of(context).size.height : null,
            child: AspectRatio(
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
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            print('tap');
            
            widget.shouldDisplayButtons
                ? widget.shouldDisplayButtons = false
                : widget.shouldDisplayButtons = true;
            setState(() {
              print(widget.shouldDisplayButtons);
            });
          },
        ),
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
    );
  }
}
