import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

bool _isFullScreen = false;
bool isOverlayVisible = false;

class VideoComplex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        key: const ValueKey<String>('home_page'),
        child: _BumbleBeeRemoteVideo(),
      ),
    );
  }
}

class _BumbleBeeRemoteVideo extends StatefulWidget {
  @override
  _BumbleBeeRemoteVideoState createState() => _BumbleBeeRemoteVideoState();
}

class _BumbleBeeRemoteVideoState extends State<_BumbleBeeRemoteVideo> {
  late VideoPlayerController _controller;
  bool _muted = false;
  late double _origVolume;
  bool startedPlaying = false;
  bool _isPlayerReady = false;

  Future<ClosedCaptionFile> _loadCaptions() async {
    final String fileContents = await DefaultAssetBundle.of(context)
        .loadString('assets/bumble_bee_captions.vtt');
    return WebVTTCaptionFile(
        fileContents); // For vtt files, use WebVTTCaptionFile
  }

  @override
  void initState() {
    super.initState();

    _isFullScreen = false;
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      //closedCaptionFile: _loadCaptions(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.initialize();
    _controller.addListener(() {
      setState(() {});
    }); //addListener {}
    _controller.setLooping(true);
    _controller.play();
    _isPlayerReady = true;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _origVolume = _controller.value.volume;
    return Scaffold(
      appBar: _isFullScreen ? null : AppBar(title: const Text('Video Demo')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: _isFullScreen ? 1 : 0,
            child: Container(
              padding: _isFullScreen
                  ? const EdgeInsets.all(0)
                  : const EdgeInsets.only(bottom: 20),
              child: AspectRatio(
                aspectRatio: _isFullScreen
                    ? MediaQuery.of(context).size.width /
                        MediaQuery.of(context).size.height
                    : _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    VideoPlayer(_controller),
                    ClosedCaption(text: _controller.value.caption.text),
                    _ControlsOverlay(controller: _controller),
                    VideoProgressIndicator(_controller, allowScrubbing: true),
                    isOverlayVisible
                        ? VideoOverlay(controller: _controller)
                        : const SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ),
          _isFullScreen
              ? const SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: _isPlayerReady
                          ? () => _controller.seekTo(Duration.zero)
                          : null,
                    ),
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: _isPlayerReady
                          ? () {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                              setState(() {});
                            }
                          : null,
                    ),
                    IconButton(
                      icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                      onPressed: _isPlayerReady
                          ? () {
                              _muted
                                  ? _controller.setVolume(_origVolume)
                                  : _controller.setVolume(0);
                              setState(() {
                                _muted = !_muted;
                              });
                            }
                          : null,
                    ),
                    IconButton(
                        icon: const Icon(
                          Icons.fullscreen,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          _isFullScreen = !_isFullScreen;
                          if (_isFullScreen) {
                            SystemChrome.setPreferredOrientations(
                                [DeviceOrientation.landscapeLeft]);
                          } else {
                            SystemChrome.setPreferredOrientations(
                                [DeviceOrientation.portraitUp]);
                          }
                          setState(() {});
                        }),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: _isPlayerReady
                          ? () => {
                                _controller.seekTo(Duration.zero)
                              } // _videoPlayerController .load(videoID)
                          : null,
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  Future setToolbarVisibility() async {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
    });
    Future.delayed(
        const Duration(seconds: 10),
        () => {
              if (isOverlayVisible)
                {
                  setState(() {
                    isOverlayVisible = false;
                  })
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            setToolbarVisibility();
          },
        ),
      ],
    );
  }
}

class VideoOverlay extends StatefulWidget {
  const VideoOverlay({
    Key? key,
    required this.controller, //required this.setSpeed
  }) : super(key: key);
  final VideoPlayerController controller;
  //final Function setSpeed;

  @override
  State<VideoOverlay> createState() => _VideoOverlayState();
}

class _VideoOverlayState extends State<VideoOverlay> {
  final TextStyle _style = const TextStyle(fontSize: 16, color: Colors.white);
  late Duration currentDuration;
  late Duration totalDuration;
  String startText = '';
  double sliderPosition = 0.0;
  double sliderTotal = 0.0;

  static const List<double> playbackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  @override
  void initState() {
    super.initState();
    currentDuration = const Duration(seconds: 0);
    totalDuration = const Duration(seconds: 0);

    _getData();
  }

  Future<void> _getData() async {
    currentDuration =
        await widget.controller.position ?? const Duration(seconds: 0);
    totalDuration = widget.controller.value.duration;
    if (widget.controller.value.isPlaying) {
      startText = ((currentDuration.inSeconds / totalDuration.inSeconds) * 100)
              .round()
              .toString() +
          ' %';
    }
    sliderPosition = currentDuration.inSeconds.toDouble();
    sliderTotal = totalDuration.inSeconds.toDouble();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _getData();
    return Positioned(
        bottom: 0,
        child: Container(
          color: Colors.grey.withOpacity(0.5),
          width: MediaQuery.of(context).size.width * .9,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(startText, style: _style),
              IconButton(
                onPressed: () {
                  if (widget.controller.value.isPlaying) {
                    widget.controller.pause();
                  } else {
                    widget.controller.play();
                  }
                  setState(() {});
                },
                icon: (widget.controller.value.isPlaying
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow)),
                color: Colors.white,
              ),
              PopupMenuButton<double>(
                  initialValue: widget.controller.value.playbackSpeed,
                  tooltip: 'Playback speed',
                  onSelected: (double speed) {
                    widget.controller.setPlaybackSpeed(speed);
                    setState(() {});
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuItem<double>>[
                      for (final double speed in playbackRates)
                        PopupMenuItem<double>(
                          value: speed,
                          child: Text(
                            '${speed}x',
                            style: TextStyle(color: Colors.black),
                          ),
                          onTap: () {
                            widget.controller.setPlaybackSpeed(speed);
                            setState(() {});
                          },
                        )
                    ];
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                        // Using less vertical padding as the text is also longer
                        // horizontally, so it feels like it would need more spacing
                        // horizontally (matching the aspect ratio of the video).
                        vertical: 12,
                        horizontal: 40,
                      ),
                      child: Row(children: [
                        const Icon(
                          Icons.speed,
                          color: Colors.white,
                        ),
                        Text(
                          '${widget.controller.value.playbackSpeed}x',
                          style: _style,
                        )
                      ]))),
              IconButton(
                  onPressed: () {
                    _isFullScreen = !_isFullScreen;
                    if (_isFullScreen) {
                      SystemChrome.setPreferredOrientations(
                          [DeviceOrientation.landscapeLeft]);
                    } else {
                      SystemChrome.setPreferredOrientations(
                          [DeviceOrientation.portraitUp]);
                    }
                    setState(() {});
                  },
                  icon: _isFullScreen
                      ? const Icon(Icons.fullscreen_exit, color: Colors.white)
                      : const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                        ))
            ],
          ),
        ));
  }
}
