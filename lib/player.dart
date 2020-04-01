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
  bool isFullscreen = false;
  CurrentPlayingInfo playingInfo;
  PlayerVillain({this.playingInfo});

  @override
  _PlayerVillainState createState() => _PlayerVillainState();
}

class _PlayerVillainState extends State<PlayerVillain> {
  VideoPlayerController _controller;

  List<Map<String, dynamic>> streamUrls = [
    {
      'title': 'Bees',
      'url':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    },
    {
      'title': 'Butterfly',
      'url':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    },
    {
      'title': 'Big Buck Bunny',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    },
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

    if (widget.playingInfo != null) {
      widget.isFullscreen = widget.playingInfo.isFullScreen ?? false;
      index = widget.playingInfo.indexOfUrl ?? 0;
      setState(() {});
    }

    if (widget.isFullscreen == null) widget.isFullscreen = false;

    streamUrls.forEach((v) {
      _controller = VideoPlayerController.network(v['url']);
      _vCtrls.add(_controller);
    });

    _controller = _vCtrls[index];
    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((v) {
      if (widget.playingInfo != null) {
        if (widget.playingInfo.position != null) {
          _controller.play().then((v) {
            _controller.seekTo(
                _controller.value.position + widget.playingInfo.position);
          });
        }
        setState(() {});
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  showFullScreen() async {
    if (widget.isFullscreen) {
      print(widget.isFullscreen);

      await _controller.pause();
      widget.playingInfo = CurrentPlayingInfo(
          indexOfUrl: index,
          position: await _controller.position,
          isFullScreen: false);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => App(playingInfo: widget.playingInfo)));
      widget.isFullscreen = false;
      setState(() {});
    } else {
      print(widget.isFullscreen);
      await _controller.pause();
      widget.playingInfo = CurrentPlayingInfo(
          indexOfUrl: index,
          position: await _controller.position,
          isFullScreen: true);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => FullscreenView(widget.playingInfo)));
      widget.isFullscreen = true;
      setState(() {});
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
                          streamUrls: streamUrls,
                          index: index,
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
                          streamUrls: streamUrls,
                          index: index,
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
  List<Map<String, dynamic>> streamUrls;
  int index;
  bool shouldDisplayButtons = true;
  VideoPlayerController controller;
  _PlayPauseOverlay({
    Key key,
    this.controller,
    this.onPrevPressed,
    this.onNextPressed,
    this.streamUrls,
    this.index,
    this.isFullscreen,
    this.onFullscreenPressed,
  }) : super(key: key);
  @override
  __PlayPauseOverlayState createState() => __PlayPauseOverlayState();
}

class __PlayPauseOverlayState extends State<_PlayPauseOverlay> {
  onTapVideo() {
    print('tap');

    // if(widget.controller.value.isPlaying){
    //   widget.shouldDisplayButtons = true;
    //   setState(() {

    //   });
    // }

    if (widget.shouldDisplayButtons) {
      widget.shouldDisplayButtons = false;
      setState(() {});
    } else {
      // Future.delayed(Duration(seconds: 3)).then((v) {
      //   setState(() {
      //     print('hide');
      //     if (widget.shouldDisplayButtons) widget.shouldDisplayButtons = false;
      //   });
      // });
      widget.shouldDisplayButtons = true;
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.shouldDisplayButtons == null) {
    //   if (widget.controller.value.isPlaying) {
    //     widget.shouldDisplayButtons = true;
    //     Future.delayed(Duration(seconds: 3)).then((v) {
    //        widget.shouldDisplayButtons = false;
    //     });
    //   } else {
    //     widget.shouldDisplayButtons = true;

    //   }
    // }

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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.4, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                    height: 80,
                    child: Column(
                      children: <Widget>[
                        VideoProgressIndicator(
                          widget.controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                              backgroundColor: Colors.black45,
                              playedColor: Colors.white,
                              bufferedColor: Colors.white30),
                        ),
                        Container(
                          height: 68,
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
                                        if (widget.controller.value.position >
                                            Duration.zero) {
                                          widget.controller.seekTo(
                                              widget.controller.value.position -
                                                  Duration(seconds: 4));
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
                                                  Duration(seconds: 4));
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
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.black, Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.8],
                        tileMode: TileMode.clamp),
                  ),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          color: Colors.black26,
                          height: 45,
                          child: Text(
                            widget.streamUrls[widget.index]['title'],
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.black26,
                        height: 45,
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
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
