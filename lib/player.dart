import 'package:demo_video_player/Modal.dart';
import 'package:demo_video_player/fullscreenview.dart';
import 'package:demo_video_player/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class Player extends StatefulWidget {
  static const routeName = "/Player";

  CurrentPlayingInfo playingInfo = CurrentPlayingInfo();

  bool isFullscreen = false;
  Player({this.playingInfo});
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        PlayerVillain(playingInfo: widget.playingInfo),
      ],
    ));
  }
}

class PlayerVillain extends StatefulWidget {
  String url;
  bool isFullscreen;
  CurrentPlayingInfo playingInfo;
  PlayerVillain({this.playingInfo});

  @override
  _PlayerVillainState createState() => _PlayerVillainState();
}

class _PlayerVillainState extends State<PlayerVillain> {
  VideoPlayerController _controller;

  List<String> streamUrls = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
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

        if (widget.playingInfo != null) {
      widget.isFullscreen = widget.playingInfo.isFullScreen ?? false;
      index = widget.playingInfo.indexOfUrl ?? 0;
      if(widget.playingInfo.position != null) _controller.seekTo(widget.playingInfo.position);
      setState(() {
        
      });
    } else {
      if (widget.isFullscreen == null) widget.isFullscreen = false;
      setState(() {
        
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  showFullScreen() async {

      

    if (widget.isFullscreen) {
      print(widget.isFullscreen);
      
      _controller.pause();
      widget.playingInfo = CurrentPlayingInfo(indexOfUrl: index,position: await _controller.position,isFullScreen: false);
      // widget.playingInfo.position = await _controller.position;
      // widget.playingInfo.indexOfUrl = index;
      // widget.playingInfo.isFullScreen = false;
      widget.isFullscreen = false;
      setState(() {});
      Navigator.pop(context);
    } else {
      print(widget.isFullscreen);
      _controller.pause();
      widget.playingInfo = CurrentPlayingInfo(indexOfUrl: index,position: await _controller.position,isFullScreen: true);
      // widget.playingInfo.position = await _controller.position;
      // widget.playingInfo.indexOfUrl = index;
      // widget.playingInfo.isFullScreen = true;
      setState(() {});
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FullscreenView(widget.playingInfo)));
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
                      // VideoProgressIndicator(_controller, allowScrubbing: true),
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
                      // VideoProgressIndicator(_controller, allowScrubbing: true),
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
      child: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.transparent,
                ),
              )
            ],
          ),
          widget.shouldDisplayButtons
              ? Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 80,
                    child: Column(
                      children: <Widget>[
                        VideoProgressIndicator(
                          widget.controller,
                          allowScrubbing: true,
                        ),
                        Container(
                          height: 65,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  color: Colors.black26,
                                  child: Center(
                                    child: IconButton(
                                      icon: Icon(Icons.skip_previous),
                                      iconSize: 40,
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
                                      icon: Icon(Icons.fast_rewind),
                                      iconSize: 40,
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
                                      icon: Icon(
                                        widget.controller.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                      ),
                                      iconSize: 40,
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
                                      icon: Icon(Icons.fast_forward),
                                      iconSize: 40,
                                      color: Colors.white,
                                      onPressed: () {
                                        if (widget.controller.value.position <
                                            widget.controller.value.duration) {
                                          widget.controller.seekTo(
                                              widget.controller.value.position +
                                                  Duration(seconds: 2));
                                        }
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
                                      iconSize: 40,
                                      color: Colors.white,
                                      onPressed: widget.onNextPressed,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
              : Container(),
        ],
      ),
    );
  }
}
